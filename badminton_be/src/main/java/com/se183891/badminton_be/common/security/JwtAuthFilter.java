package com.se183891.badminton_be.common.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.se183891.badminton_be.auth.entity.AuthSession;
import com.se183891.badminton_be.auth.repository.AuthSessionRepository;
import com.se183891.badminton_be.common.exception.AppException;
import com.se183891.badminton_be.common.exception.ErrorCode;
import com.se183891.badminton_be.common.response.ApiResponse;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    private static final String BEARER_PREFIX = "Bearer ";

    private final JwtService jwtService;
    private final AuthSessionRepository authSessionRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public JwtAuthFilter(JwtService jwtService, AuthSessionRepository authSessionRepository) {
        this.jwtService = jwtService;
        this.authSessionRepository = authSessionRepository;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith(BEARER_PREFIX)) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(BEARER_PREFIX.length()).trim();
        if (token.isEmpty()) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            AuthenticatedUser principal = jwtService.parseAccessToken(token);
            if (principal.sessionId() != null) {
                Optional<AuthSession> sessionOpt = authSessionRepository.findById(principal.sessionId());
                if (sessionOpt.isEmpty()
                        || sessionOpt.get().getRevokedAt() != null
                        || sessionOpt.get().getExpiresAt().isBefore(Instant.now())) {
                    throw new AppException(ErrorCode.UNAUTHORIZED, "Phien dang nhap da ket thuc hoac bi thu hoi");
                }
            }

            List<SimpleGrantedAuthority> authorities = new ArrayList<>();
            for (String role : principal.roles()) {
                authorities.add(new SimpleGrantedAuthority("ROLE_" + role.toUpperCase()));
            }
            for (String perm : principal.permissions()) {
                authorities.add(new SimpleGrantedAuthority(perm.toUpperCase()));
            }

            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(principal, null, authorities);
            SecurityContextHolder.getContext().setAuthentication(authentication);

            filterChain.doFilter(request, response);
        } catch (AppException ex) {
            SecurityContextHolder.clearContext();
            writeErrorResponse(response, ex.getErrorCode(), ex.getMessage());
        }
    }

    private void writeErrorResponse(HttpServletResponse response, ErrorCode code, String message) throws IOException {
        response.setStatus(code.getStatus().value());
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        ApiResponse<Void> body = ApiResponse.fail(code.name(), message, List.of());
        response.getWriter().write(objectMapper.writeValueAsString(body));
    }
}
