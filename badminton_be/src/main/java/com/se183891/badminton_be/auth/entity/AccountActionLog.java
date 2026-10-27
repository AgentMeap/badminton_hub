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
@Table(name = "account_action_log")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AccountActionLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "INTEGER")
    private Long id;

    @Column(name = "target_user_id", columnDefinition = "INTEGER", nullable = false)
    private Long targetUserId;

    @Column(name = "performed_by_user_id", columnDefinition = "INTEGER")
    private Long performedByUserId;

    @Column(name = "action_type", length = 64, nullable = false)
    private String actionType;

    @Column(name = "reason", length = 255)
    private String reason;

    @Column(name = "created_at", length = 64, nullable = false)
    private Instant createdAt;

    @PrePersist
    public void onCreate() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }
}
