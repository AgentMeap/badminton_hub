package com.se183891.badminton_be.auth.dto.response;

import java.util.Set;

public record UserSummaryResponse(
        Long id,
        String firebaseUid,
        String authProvider,
        String fullName,
        String email,
        String phone,
        String avatarUrl,
        String status,
        Set<String> roles,
        Set<String> permissions,
        String ownerApplicationStatus,
        String ownerRejectReason
) {
}
