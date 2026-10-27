package com.se183891.badminton_be.common.exception;

import org.springframework.http.HttpStatus;

public enum ErrorCode {
    VALIDATION_ERROR(HttpStatus.BAD_REQUEST, "Du lieu dau vao khong hop le"),
    BAD_REQUEST(HttpStatus.BAD_REQUEST, "Yeu cau khong hop le"),
    RESOURCE_NOT_FOUND(HttpStatus.NOT_FOUND, "Khong tim thay tai nguyen yeu cau"),
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "Loi he thong, vui long thu lai sau"),

    // Auth & Account
    EMAIL_ALREADY_EXISTS(HttpStatus.CONFLICT, "Email nay da duoc su dung"),
    EMAIL_REGISTERED_WITH_GOOGLE(HttpStatus.CONFLICT, "Email nay da dang ky qua Google. Vui long dang nhap bang Google hoac dung Quen mat khau de thiet lap mat khau rieng"),
    PHONE_ALREADY_EXISTS(HttpStatus.CONFLICT, "So dien thoai nay da duoc su dung"),
    AUTH_INVALID_CREDENTIALS(HttpStatus.UNAUTHORIZED, "Email hoac mat khau khong dung"),
    AUTH_EMAIL_NOT_VERIFIED(HttpStatus.FORBIDDEN, "Tai khoan chua xac thuc email"),
    ACCOUNT_LOCKED(HttpStatus.FORBIDDEN, "Tai khoan dang bi khoa tam thoi do nhap sai nhieu lan"),
    ACCOUNT_DISABLED(HttpStatus.FORBIDDEN, "Tai khoan da bi vo hieu hoa"),
    OWNER_NOT_APPROVED(HttpStatus.FORBIDDEN, "Ho so chu san dang cho Admin phe duyet"),
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "Chua dang nhap hoac phien dang nhap khong hop le"),
    TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED, "Access token da het han"),
    REFRESH_TOKEN_INVALID(HttpStatus.UNAUTHORIZED, "Refresh token khong hop le hoac da bi thu hoi"),
    FORBIDDEN(HttpStatus.FORBIDDEN, "Ban khong co quyen thuc hien thao tac nay"),

    // OTP
    OTP_INVALID(HttpStatus.BAD_REQUEST, "Ma OTP khong dung"),
    OTP_EXPIRED(HttpStatus.BAD_REQUEST, "Ma OTP da het han"),
    OTP_MAX_ATTEMPTS(HttpStatus.BAD_REQUEST, "Ban da nhap sai OTP qua so lan cho phep, vui long yeu cau ma moi"),
    OTP_COOLDOWN(HttpStatus.TOO_MANY_REQUESTS, "Vui long doi 60 giay truoc khi gui lai ma OTP"),
    OTP_HOURLY_LIMIT(HttpStatus.TOO_MANY_REQUESTS, "Ban da vuot qua gioi han 5 ma OTP trong 1 gio"),

    // Firebase
    FIREBASE_TOKEN_INVALID(HttpStatus.UNAUTHORIZED, "Firebase ID Token khong hop le hoac da het han"),
    FIREBASE_SYNC_FAILED(HttpStatus.BAD_GATEWAY, "Khong the dong bo tai khoan voi Firebase Authentication"),

    // Storage
    FILE_EMPTY(HttpStatus.BAD_REQUEST, "File tai len khong duoc de trong"),
    FILE_TOO_LARGE(HttpStatus.BAD_REQUEST, "Kich thuoc file vuot qua gioi han 5MB"),
    FILE_TYPE_NOT_ALLOWED(HttpStatus.BAD_REQUEST, "Chi chap nhan file dinh dang .jpg, .jpeg, .png hoac .pdf"),
    FILE_STORAGE_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "Khong the luu file tai len"),

    // Venue & Booking
    SLOT_ALREADY_BOOKED(HttpStatus.CONFLICT, "Khung gio vua co nguoi dat"),
    VENUE_NOT_OWNED(HttpStatus.FORBIDDEN, "Ban khong co quyen voi co so nay");

    private final HttpStatus status;
    private final String defaultMessage;

    ErrorCode(HttpStatus status, String defaultMessage) {
        this.status = status;
        this.defaultMessage = defaultMessage;
    }

    public HttpStatus getStatus() {
        return status;
    }

    public String getDefaultMessage() {
        return defaultMessage;
    }
}
