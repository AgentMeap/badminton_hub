package com.se183891.badminton_be.owner.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "bank_account")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BankAccount {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "INTEGER")
    private Long id;

    @Column(name = "user_id", columnDefinition = "INTEGER", nullable = false)
    private Long userId;

    @Column(name = "bank_code", length = 32, nullable = false)
    private String bankCode;

    @Column(name = "bank_name", length = 120, nullable = false)
    private String bankName;

    @Column(name = "account_number_encrypted", length = 255, nullable = false)
    private String accountNumberEncrypted;

    @Column(name = "account_holder_name", length = 120, nullable = false)
    private String accountHolderName;

    @Column(name = "is_verified", columnDefinition = "INTEGER", nullable = false)
    private int isVerified;

    @Column(name = "created_at", length = 64, nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", length = 64, nullable = false)
    private Instant updatedAt;

    @PrePersist
    public void onCreate() {
        Instant now = Instant.now();
        if (createdAt == null) {
            createdAt = now;
        }
        updatedAt = now;
    }

    @PreUpdate
    public void onUpdate() {
        updatedAt = Instant.now();
    }
}
