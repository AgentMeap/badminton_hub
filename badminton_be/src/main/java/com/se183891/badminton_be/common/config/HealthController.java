package com.se183891.badminton_be.common.config;

import com.se183891.badminton_be.common.response.ApiResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/health")
public class HealthController {

    @GetMapping
    public ApiResponse<Map<String, Object>> checkHealth() {
        return ApiResponse.ok(Map.of(
                "status", "UP",
                "service", "badminton_be",
                "database", "SQLite",
                "serverTime", Instant.now().toString()
        ));
    }
}
