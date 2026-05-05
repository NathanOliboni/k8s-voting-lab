package com.example.worker;

import redis.clients.jedis.Jedis;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.List;

public class WorkerApp {
    private static final String QUEUE_NAME = "votes";

    public static void main(String[] args) throws Exception {
        String redisHost = getEnv("REDIS_HOST", "redis-service");
        int redisPort = Integer.parseInt(getEnv("REDIS_PORT", "6379"));

        String dbHost = getEnv("POSTGRES_HOST", "postgres-service");
        String dbPort = getEnv("POSTGRES_PORT", "5432");
        String dbName = getEnv("POSTGRES_DB", "votes");
        String dbUser = getEnv("POSTGRES_USER", "vote");
        String dbPassword = getEnv("POSTGRES_PASSWORD", "vote");

        String jdbcUrl = String.format("jdbc:postgresql://%s:%s/%s", dbHost, dbPort, dbName);

        try (Connection conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
             Jedis jedis = new Jedis(redisHost, redisPort)) {
            ensureTable(conn);

            while (true) {
                List<String> result = jedis.brpop(0, QUEUE_NAME);
                if (result != null && result.size() == 2) {
                    String vote = result.get(1);
                    insertVote(conn, vote);
                }
            }
        }
    }

    private static void ensureTable(Connection conn) throws Exception {
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS votes (" +
                    "id SERIAL PRIMARY KEY, " +
                    "vote VARCHAR(255) NOT NULL, " +
                    "created_at TIMESTAMP DEFAULT NOW()" +
                    ")");
        }
    }

    private static void insertVote(Connection conn, String vote) throws Exception {
        try (PreparedStatement stmt = conn.prepareStatement("INSERT INTO votes (vote) VALUES (?)")) {
            stmt.setString(1, vote);
            stmt.executeUpdate();
        }
    }

    private static String getEnv(String key, String defaultValue) {
        String value = System.getenv(key);
        return value == null || value.isBlank() ? defaultValue : value;
    }
}

