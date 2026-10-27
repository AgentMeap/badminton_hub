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
@Table(name = "otp_code")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OtpCode {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "INTEGER")
    private Long id;

    @Column(name = "user_id", columnDefinition = "INTEGER", nullable = false)
    private Long userId;

    @Column(name = "ticket", length = 64, nullable = false, unique = true)
    private String ticket;

    @Column(name = "purpose", length = 32, nullable = false)
    private String purpose;

    @Column(name = "code_hash", length = 255, nullable = false)
    private String codeHash;

    @Column(name = "encrypted_pending_secret", length = 512)
    private String encryptedPendingSecret;

    @Column(name = "attempt_count", columnDefinition = "INTEGER", nullable = false)
    private int attemptCount;

    @Column(name = "expires_at", length = 64, nullable = false)
    private Instant expiresAt;

    @Column(name = "consumed_at", length = 64)
    private Instant consumedAt;

    @Column(name = "created_at", length = 64, nullable = false)
    private Instant createdAt;

    @PrePersist
    public void onCreate() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }
}
