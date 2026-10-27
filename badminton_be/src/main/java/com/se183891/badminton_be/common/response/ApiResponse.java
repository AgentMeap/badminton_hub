package com.se183891.badminton_be.common.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.se183891.badminton_be.common.util.TraceIdHolder;

import java.time.Instant;
import java.util.List;

@JsonInclude(JsonInclude.Include.ALWAYS)
public record ApiResponse<T>(
        boolean success,
        T data,
        ErrorBody error,
        Meta meta
) {

    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(
                true,
                data,
                null,
                new Meta(Instant.now().toString(), TraceIdHolder.getOrCreate())
        );
    }

    public static <T> ApiResponse<T> fail(String code, String message, List<FieldErrorDetail> details) {
        return new ApiResponse<>(
                false,
                null,
                new ErrorBody(code, message, details == null ? List.of() : details),
                new Meta(Instant.now().toString(), TraceIdHolder.getOrCreate())
        );
    }

    public record ErrorBody(
            String code,
            String message,
            List<FieldErrorDetail> details
    ) {
    }

    public record FieldErrorDetail(
            String field,
            String issue
    ) {
    }

    public record Meta(
            String timestamp,
            String traceId
    ) {
    }
}
