package com.se183891.badminton_be.auth.dto.request;

import jakarta.validation.constraints.NotBlank;

public record RefreshTokenRequest(
        @NotBlank(message = "Refresh token khong duoc de trong")
        String refreshToken,
        String deviceId
) {
}
