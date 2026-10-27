package com.se183891.badminton_be.auth.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record VerifyEmailOtpRequest(
        String email,
        String otpTicket,

        @NotBlank(message = "Ma OTP khong duoc de trong")
        @Size(min = 6, max = 6, message = "Ma OTP phai gom 6 chu so")
        String code,

        String deviceId,
        String deviceName
) {
}
