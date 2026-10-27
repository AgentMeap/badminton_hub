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
@Table(name = "trusted_device")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TrustedDevice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "INTEGER")
    private Long id;

    @Column(name = "user_id", columnDefinition = "INTEGER", nullable = false)
    private Long userId;

    @Column(name = "device_id", length = 128, nullable = false)
    private String deviceId;

    @Column(name = "device_name", length = 160)
    private String deviceName;

    @Column(name = "last_used_at", length = 64, nullable = false)
    private Instant lastUsedAt;

    @Column(name = "created_at", length = 64, nullable = false)
    private Instant createdAt;

    @PrePersist
    public void onCreate() {
        Instant now = Instant.now();
        if (createdAt == null) {
            createdAt = now;
        }
        if (lastUsedAt == null) {
            lastUsedAt = now;
        }
    }
}
