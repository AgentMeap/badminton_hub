package com.se183891.badminton_be.auth.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ResetPasswordRequest(
        String email,
        String otpTicket,

        @NotBlank(message = "Ma OTP khong duoc de trong")
        @Size(min = 6, max = 6, message = "Ma OTP phai gom 6 chu so")
        String code,

        @NotBlank(message = "Mat khau moi khong duoc de trong")
        @Size(min = 8, max = 72, message = "Mat khau moi phai tu 8 ky tu tro len")
        String newPassword
) {
}
