package com.se183891.badminton_be.auth.dto.response;

public record AuthTokenResponse(
        boolean otpRequired,
        String otpTicket,
        String accessToken,
        String refreshToken,
        int expiresInSeconds,
        UserSummaryResponse user
) {
}
