package com.se183891.badminton_be.auth.entity;

public enum OtpPurpose {
    VERIFY_EMAIL(15),
    LOGIN(5),
    RESET_PASSWORD(5),
    CHANGE_PASSWORD(5),
    BANK_ACCOUNT(5);

    private final int ttlMinutes;

    OtpPurpose(int ttlMinutes) {
        this.ttlMinutes = ttlMinutes;
    }

    public int getTtlMinutes() {
        return ttlMinutes;
    }
}
