package com.example.vote;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

@RestController
public class VoteController {
    private final JedisPool jedisPool;

    public VoteController(JedisPool jedisPool) {
        this.jedisPool = jedisPool;
    }

    @PostMapping("/vote")
    public ResponseEntity<String> vote(@RequestParam("option") String option) {
        if (option == null || option.isBlank()) {
            return ResponseEntity.badRequest().body("option is required");
        }

        try (Jedis jedis = jedisPool.getResource()) {
            jedis.lpush("votes", option.trim());
        }

        return ResponseEntity.ok("ok");
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("ok");
    }
}

