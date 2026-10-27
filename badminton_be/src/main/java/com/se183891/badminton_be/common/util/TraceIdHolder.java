package com.se183891.badminton_be.common.util;

import org.slf4j.MDC;

import java.util.UUID;

public final class TraceIdHolder {

    public static final String TRACE_ID_KEY = "traceId";
    public static final String TRACE_ID_HEADER = "X-Trace-Id";

    private TraceIdHolder() {
    }

    public static String getOrCreate() {
        String existing = MDC.get(TRACE_ID_KEY);
        if (existing != null && !existing.isBlank()) {
            return existing;
        }
        String generated = UUID.randomUUID().toString().replace("-", "").substring(0, 12);
        MDC.put(TRACE_ID_KEY, generated);
        return generated;
    }

    public static void set(String traceId) {
        MDC.put(TRACE_ID_KEY, traceId);
    }

    public static void clear() {
        MDC.remove(TRACE_ID_KEY);
    }
}
