package com.se183891.badminton_be.common.config;

import com.se183891.badminton_be.owner.entity.OwnerApplication;
import com.se183891.badminton_be.owner.repository.OwnerApplicationRepository;
import com.se183891.badminton_be.user.entity.Permission;
import com.se183891.badminton_be.user.entity.Role;
import com.se183891.badminton_be.user.entity.RoleCode;
import com.se183891.badminton_be.user.entity.User;
import com.se183891.badminton_be.user.repository.PermissionRepository;
import com.se183891.badminton_be.user.repository.RoleRepository;
import com.se183891.badminton_be.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Component
@RequiredArgsConstructor
public class DemoAccountSeeder implements CommandLineRunner {

    private final RoleRepository roleRepository;
    private final PermissionRepository permissionRepository;
    private final UserRepository userRepository;
    private final OwnerApplicationRepository ownerApplicationRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) {
        Role customerRole = ensureRoleWithPermissions(
                RoleCode.CUSTOMER.name(),
                "Khach dat san",
                List.of("BOOKING_CREATE", "BOOKING_VIEW_OWN", "CHAT_AI_USE")
        );
        Role ownerRole = ensureRoleWithPermissions(
                RoleCode.OWNER.name(),
                "Chu san",
                List.of("VENUE_MANAGE_OWN", "BOOKING_TIMELINE_MANAGE")
        );
        Role adminRole = ensureRoleWithPermissions(
                RoleCode.ADMIN.name(),
                "Quan tri vien",
                List.of("OWNER_APPLICATION_REVIEW", "VENUE_APPROVE", "USER_LOCK_MANAGE")
        );

        String defaultHash = passwordEncoder.encode("Badminton123");

        User adminUser = userRepository.findByEmailIgnoreCase("admin@badminton.vn")
                .orElseGet(() -> userRepository.save(User.builder()
                        .firebaseUid("firebase-demo-admin-001")
                        .authProvider("LOCAL")
                        .fullName("System Admin")
                        .email("admin@badminton.vn")
                        .phone("0900000001")
                        .passwordHash(defaultHash)
                        .status("ACTIVE")
                        .failedLoginCount(0)
                        .roles(new HashSet<>(Set.of(adminRole)))
                        .build()));

        if (userRepository.findByEmailIgnoreCase("customer@badminton.vn").isEmpty()) {
            userRepository.save(User.builder()
                    .firebaseUid("firebase-demo-customer-001")
                    .authProvider("LOCAL")
                    .fullName("Nguyen Van Khach")
                    .email("customer@badminton.vn")
                    .phone("0901234567")
                    .passwordHash(defaultHash)
                    .status("ACTIVE")
                    .failedLoginCount(0)
                    .roles(new HashSet<>(Set.of(customerRole)))
                    .build());
        }

        if (userRepository.findByEmailIgnoreCase("owner@badminton.vn").isEmpty()) {
            User savedOwner = userRepository.save(User.builder()
                    .firebaseUid("firebase-demo-owner-001")
                    .authProvider("LOCAL")
                    .fullName("Tran Chu San")
                    .email("owner@badminton.vn")
                    .phone("0909888777")
                    .passwordHash(defaultHash)
                    .status("ACTIVE")
                    .failedLoginCount(0)
                    .roles(new HashSet<>(Set.of(ownerRole)))
                    .build());

            ownerApplicationRepository.save(OwnerApplication.builder()
                    .userId(savedOwner.getId())
                    .businessName("Cum San Cau Long Phu Nhuan")
                    .taxCode("0312345678")
                    .address("15 Hoang Minh Giam, Phu Nhuan, TP.HCM")
                    .licenseFileUrl("/files/licenses/demo-license.pdf")
                    .status("APPROVED")
                    .reviewedByUserId(adminUser.getId())
                    .reviewedAt(Instant.now())
                    .submittedAt(Instant.now())
                    .build());
        }
    }

    private Role ensureRoleWithPermissions(String code, String name, List<String> permissionCodes) {
        Role role = roleRepository.findByCodeIgnoreCase(code)
                .orElseGet(() -> Role.builder()
                        .code(code)
                        .name(name)
                        .build());

        Set<Permission> perms = new HashSet<>();
        for (String permCode : permissionCodes) {
            permissionRepository.findByCodeIgnoreCase(permCode).ifPresent(perms::add);
        }
        role.setPermissions(perms);
        return roleRepository.save(role);
    }
}
