package com.se183891.badminton_be.user.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "INTEGER")
    private Long id;

    @Column(name = "firebase_uid", length = 128, unique = true)
    private String firebaseUid;

    @Column(name = "auth_provider", length = 32, nullable = false)
    private String authProvider;

    @Column(name = "full_name", length = 120, nullable = false)
    private String fullName;

    @Column(name = "email", length = 160, nullable = false, unique = true)
    private String email;

    @Column(name = "phone", length = 24)
    private String phone;

    @Column(name = "password_hash", length = 255)
    private String passwordHash;

    @Column(name = "avatar_url", length = 500)
    private String avatarUrl;

    @Column(name = "status", length = 32, nullable = false)
    private String status;

    @Column(name = "failed_login_count", columnDefinition = "INTEGER", nullable = false)
    private int failedLoginCount;

    @Column(name = "locked_until", length = 64)
    private Instant lockedUntil;

    @Column(name = "created_at", length = 64, nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", length = 64, nullable = false)
    private Instant updatedAt;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "user_role",
            joinColumns = @JoinColumn(name = "user_id", columnDefinition = "INTEGER"),
            inverseJoinColumns = @JoinColumn(name = "role_id", columnDefinition = "INTEGER")
    )
    @Builder.Default
    private Set<Role> roles = new HashSet<>();

    @PrePersist
    public void onCreate() {
        Instant now = Instant.now();
        if (createdAt == null) {
            createdAt = now;
        }
        updatedAt = now;
        if (authProvider == null) {
            authProvider = "LOCAL";
        }
        if (status == null) {
            status = "PENDING_VERIFICATION";
        }
    }

    @PreUpdate
    public void onUpdate() {
        updatedAt = Instant.now();
    }

    public boolean hasRole(RoleCode roleCode) {
        if (roles == null || roleCode == null) {
            return false;
        }
        return roles.stream().anyMatch(r -> roleCode.name().equalsIgnoreCase(r.getCode()));
    }

    public Set<String> getRoleCodes() {
        if (roles == null) {
            return Set.of();
        }
        return roles.stream().map(Role::getCode).collect(Collectors.toSet());
    }

    public Set<String> getPermissionCodes() {
        if (roles == null) {
            return Set.of();
        }
        return roles.stream()
                .filter(r -> r.getPermissions() != null)
                .flatMap(r -> r.getPermissions().stream())
                .map(Permission::getCode)
                .collect(Collectors.toSet());
    }
}
