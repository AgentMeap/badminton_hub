package com.se183891.badminton_be.common.config;

import com.se183891.badminton_be.common.util.TraceIdHolder;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class TraceIdFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        try {
            String incoming = request.getHeader(TraceIdHolder.TRACE_ID_HEADER);
            if (incoming != null && !incoming.isBlank()) {
                TraceIdHolder.set(incoming.trim());
            } else {
                TraceIdHolder.getOrCreate();
            }
            response.setHeader(TraceIdHolder.TRACE_ID_HEADER, TraceIdHolder.getOrCreate());
            filterChain.doFilter(request, response);
        } finally {
            TraceIdHolder.clear();
        }
    }
}
