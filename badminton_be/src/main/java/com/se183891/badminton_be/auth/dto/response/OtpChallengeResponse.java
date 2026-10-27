package com.se183891.badminton_be.auth.dto.response;

public record OtpChallengeResponse(
        boolean otpRequired,
        String otpTicket,
        String purpose,
        String email,
        String expiresAt,
        int cooldownSeconds,
        String message
) {
}
