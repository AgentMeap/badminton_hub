package com.se183891.badminton_be.auth.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record LoginRequest(
        @NotBlank(message = "Email khong duoc de trong")
        @Email(message = "Email khong dung dinh dang")
        String email,

        @NotBlank(message = "Mat khau khong duoc de trong")
        String password,

        String deviceId,
        String deviceName
) {
}
