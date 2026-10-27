package com.se183891.badminton_be.common.exception;

import com.se183891.badminton_be.common.response.ApiResponse;

import java.util.List;

public class AppException extends RuntimeException {

    private final ErrorCode errorCode;
    private final List<ApiResponse.FieldErrorDetail> details;

    public AppException(ErrorCode errorCode) {
        super(errorCode.getDefaultMessage());
        this.errorCode = errorCode;
        this.details = List.of();
    }

    public AppException(ErrorCode errorCode, String customMessage) {
        super(customMessage);
        this.errorCode = errorCode;
        this.details = List.of();
    }

    public AppException(ErrorCode errorCode, String customMessage, List<ApiResponse.FieldErrorDetail> details) {
        super(customMessage);
        this.errorCode = errorCode;
        this.details = details == null ? List.of() : details;
    }

    public ErrorCode getErrorCode() {
        return errorCode;
    }

    public List<ApiResponse.FieldErrorDetail> getDetails() {
        return details;
    }
}
