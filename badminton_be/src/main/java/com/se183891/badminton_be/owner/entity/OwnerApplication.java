package com.se183891.badminton_be.owner.entity;

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
@Table(name = "owner_application")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OwnerApplication {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "INTEGER")
    private Long id;

    @Column(name = "user_id", columnDefinition = "INTEGER", nullable = false)
    private Long userId;

    @Column(name = "business_name", length = 180, nullable = false)
    private String businessName;

    @Column(name = "tax_code", length = 64)
    private String taxCode;

    @Column(name = "address", length = 255, nullable = false)
    private String address;

    @Column(name = "license_file_url", length = 500, nullable = false)
    private String licenseFileUrl;

    @Column(name = "status", length = 32, nullable = false)
    private String status;

    @Column(name = "reject_reason", length = 500)
    private String rejectReason;

    @Column(name = "reviewed_by_user_id", columnDefinition = "INTEGER")
    private Long reviewedByUserId;

    @Column(name = "reviewed_at", length = 64)
    private Instant reviewedAt;

    @Column(name = "submitted_at", length = 64, nullable = false)
    private Instant submittedAt;

    @PrePersist
    public void onCreate() {
        if (submittedAt == null) {
            submittedAt = Instant.now();
        }
        if (status == null) {
            status = "PENDING";
        }
    }
}
