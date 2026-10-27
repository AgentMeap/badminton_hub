package com.se183891.badminton_be.auth.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "login_log")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "INTEGER")
    private Long id;

    @Column(name = "user_id", columnDefinition = "INTEGER")
    private Long userId;

    @Column(name = "role_code", length = 32, nullable = false)
    private String roleCode;

    @Column(name = "email", length = 160, nullable = false)
    private String email;

    @Column(name = "device_id", length = 128)
    private String deviceId;

    @Column(name = "ip_address", length = 64)
    private String ipAddress;

    @Column(name = "success", columnDefinition = "INTEGER", nullable = false)
    private int success;

    @Column(name = "failure_reason", length = 160)
    private String failureReason;

    @Column(name = "created_at", length = 64, nullable = false)
    private Instant createdAt;

    @PrePersist
    public void onCreate() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }
}
