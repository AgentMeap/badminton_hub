package com.se183891.badminton_be.auth.dto.request;

import jakarta.validation.constraints.NotBlank;

public record GoogleAuthRequest(
        @NotBlank(message = "Firebase idToken khong duoc de trong")
        String idToken,
        String deviceId,
        String deviceName
) {
}
