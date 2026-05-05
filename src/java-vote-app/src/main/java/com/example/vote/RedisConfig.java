package com.example.vote;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import redis.clients.jedis.JedisPool;

@Configuration
public class RedisConfig {
    @Bean
    public JedisPool jedisPool(
            @Value("${REDIS_HOST:redis-service}") String host,
            @Value("${REDIS_PORT:6379}") int port) {
        return new JedisPool(host, port);
    }
}

