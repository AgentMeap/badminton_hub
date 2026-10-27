package com.se183891.badminton_be.user.entity;

import com.se183891.badminton_be.common.exception.AppException;
import com.se183891.badminton_be.common.exception.ErrorCode;

import java.util.Locale;

public enum RoleCode {
    CUSTOMER,
    OWNER,
    ADMIN;

    public static RoleCode fromPathSegment(String segment) {
        if (segment == null) {
            throw new AppException(ErrorCode.BAD_REQUEST, "Role khong hop le");
        }
        return switch (segment.trim().toLowerCase(Locale.ROOT)) {
            case "customer" -> CUSTOMER;
            case "owner" -> OWNER;
            case "admin" -> ADMIN;
            default -> throw new AppException(ErrorCode.BAD_REQUEST, "Role phai la customer, owner hoac admin");
        };
    }
}
