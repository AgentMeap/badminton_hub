package com.se183891.badminton_be.auth.dto.request;

public record LogoutRequest(
        String refreshToken
) {
}
