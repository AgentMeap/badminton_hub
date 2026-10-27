package com.se183891.badminton_be.common.security;

import com.se183891.badminton_be.common.exception.AppException;
import com.se183891.badminton_be.common.exception.ErrorCode;
import com.se183891.badminton_be.user.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collection;
import java.util.Date;
import java.util.HexFormat;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class JwtService {

    private final SecretKey secretKey;
    private final int accessTokenMinutes;
    private final int refreshTokenDays;
    private final SecureRandom secureRandom = new SecureRandom();

    public JwtService(
            @Value("${app.jwt.secret}") String secret,
            @Value("${app.jwt.access-token-minutes:15}") int accessTokenMinutes,
            @Value("${app.jwt.refresh-token-days:7}") int refreshTokenDays
    ) {
        byte[] keyBytes = secret.getBytes(StandardCharsets.UTF_8);
        if (keyBytes.length < 32) {
            throw new IllegalArgumentException("app.jwt.secret must be at least 32 bytes long");
        }
        this.secretKey = Keys.hmacShaKeyFor(keyBytes);
        this.accessTokenMinutes = accessTokenMinutes;
        this.refreshTokenDays = refreshTokenDays;
    }

    public String generateAccessToken(User user, Long sessionId) {
        Instant now = Instant.now();
        Instant expiresAt = now.plus(accessTokenMinutes, ChronoUnit.MINUTES);

        return Jwts.builder()
                .subject(String.valueOf(user.getId()))
                .claim("email", user.getEmail())
                .claim("sid", sessionId)
                .claim("roles", new ArrayList<>(user.getRoleCodes()))
                .claim("permissions", new ArrayList<>(user.getPermissionCodes()))
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiresAt))
                .signWith(secretKey)
                .compact();
    }

    public AuthenticatedUser parseAccessToken(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            Long userId = Long.parseLong(claims.getSubject());
            String email = claims.get("email", String.class);
            Number sidNumber = claims.get("sid", Number.class);
            Long sessionId = sidNumber != null ? sidNumber.longValue() : null;

            Set<String> roles = toStringSet(claims.get("roles"));
            Set<String> permissions = toStringSet(claims.get("permissions"));

            return new AuthenticatedUser(userId, email, sessionId, roles, permissions);
        } catch (ExpiredJwtException ex) {
            throw new AppException(ErrorCode.TOKEN_EXPIRED);
        } catch (JwtException | IllegalArgumentException ex) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }
    }

    public String generateRawRefreshToken() {
        byte[] randomBytes = new byte[32];
        secureRandom.nextBytes(randomBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }

    public String hashRefreshToken(String rawRefreshToken) {
        if (rawRefreshToken == null || rawRefreshToken.isBlank()) {
            throw new AppException(ErrorCode.REFRESH_TOKEN_INVALID);
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(rawRefreshToken.trim().getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (Exception ex) {
            throw new IllegalStateException("Cannot hash refresh token", ex);
        }
    }

    public Instant calculateRefreshTokenExpiry() {
        return Instant.now().plus(refreshTokenDays, ChronoUnit.DAYS);
    }

    public int getAccessTokenMinutes() {
        return accessTokenMinutes;
    }

    private Set<String> toStringSet(Object rawClaim) {
        if (rawClaim instanceof Collection<?> collection) {
            return collection.stream()
                    .filter(item -> item != null)
                    .map(Object::toString)
                    .collect(Collectors.toSet());
        }
        return Set.of();
    }
}
