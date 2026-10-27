package com.se183891.badminton_be.owner.dto;

public record OwnerApplicationResponse(
        Long id,
        Long userId,
        String ownerName,
        String ownerEmail,
        String ownerPhone,
        String businessName,
        String taxCode,
        String address,
        String licenseFileUrl,
        String status,
        String rejectReason,
        Long reviewedByUserId,
        String reviewedAt,
        String submittedAt
) {
}
