package com.se183891.badminton_be.auth.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CustomerRegisterRequest(
        @NotBlank(message = "Ho ten khong duoc de trong")
        @Size(max = 120, message = "Ho ten toi da 120 ky tu")
        String fullName,

        @NotBlank(message = "Email khong duoc de trong")
        @Email(message = "Email khong dung dinh dang")
        String email,

        @NotBlank(message = "So dien thoai khong duoc de trong")
        @Size(min = 9, max = 15, message = "So dien thoai phai tu 9 den 15 ky tu")
        String phone,

        @NotBlank(message = "Mat khau khong duoc de trong")
        @Size(min = 8, max = 72, message = "Mat khau phai tu 8 ky tu tro len")
        String password
) {
}
