package com.se183891.badminton_be.auth.service;

import com.se183891.badminton_be.auth.entity.OtpCode;
import com.se183891.badminton_be.auth.entity.OtpPurpose;
import com.se183891.badminton_be.auth.repository.OtpCodeRepository;
import com.se183891.badminton_be.common.exception.AppException;
import com.se183891.badminton_be.common.exception.ErrorCode;
import com.se183891.badminton_be.common.security.SecretCipherService;
import com.se183891.badminton_be.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class OtpService {

    public static final int MAX_ATTEMPTS = 3;
    public static final int RESEND_COOLDOWN_SECONDS = 60;
    public static final int MAX_OTPS_PER_HOUR = 5;

    private final OtpCodeRepository otpCodeRepository;
    private final PasswordEncoder passwordEncoder;
    private final SecretCipherService secretCipherService;
    private final MailSenderService mailSenderService;
    private final SecureRandom secureRandom = new SecureRandom();

    public record IssuedOtp(
            String ticket,
            String rawCode,
            Instant expiresAt,
            int cooldownSeconds
    ) {
    }

    public record VerifiedOtpResult(
            OtpCode otpCode,
            String decryptedPendingSecret
    ) {
    }

    @Transactional
    public IssuedOtp issueAndSendOtp(User user, OtpPurpose purpose, String pendingPlainSecret) {
        Instant now = Instant.now();
        List<OtpCode> recentOtps = otpCodeRepository.findByUserIdOrderByCreatedAtDesc(user.getId());

        // 1. Check 60s cooldown on the most recent OTP of the same purpose
        recentOtps.stream()
                .filter(o -> purpose.name().equalsIgnoreCase(o.getPurpose()))
                .findFirst()
                .ifPresent(latestSamePurpose -> {
                    Instant cooldownEnd = latestSamePurpose.getCreatedAt().plusSeconds(RESEND_COOLDOWN_SECONDS);
                    if (now.isBefore(cooldownEnd)) {
                        throw new AppException(ErrorCode.OTP_COOLDOWN);
                    }
                });

        // 2. Check max 5 OTPs per hour across the account
        Instant oneHourAgo = now.minus(1, ChronoUnit.HOURS);
        long countLastHour = recentOtps.stream()
                .filter(o -> o.getCreatedAt() != null && o.getCreatedAt().isAfter(oneHourAgo))
                .count();
        if (countLastHour >= MAX_OTPS_PER_HOUR) {
            throw new AppException(ErrorCode.OTP_HOURLY_LIMIT);
        }

        // 3. Invalidate previous unconsumed OTPs of the same purpose
        String encryptedSecretToCarryOver = null;
        for (OtpCode oldOtp : recentOtps) {
            if (purpose.name().equalsIgnoreCase(oldOtp.getPurpose()) && oldOtp.getConsumedAt() == null) {
                if (encryptedSecretToCarryOver == null && oldOtp.getEncryptedPendingSecret() != null) {
                    encryptedSecretToCarryOver = oldOtp.getEncryptedPendingSecret();
                }
                oldOtp.setConsumedAt(now);
                otpCodeRepository.save(oldOtp);
            }
        }

        String rawCode = String.format("%06d", secureRandom.nextInt(1_000_000));
        String ticket = UUID.randomUUID().toString();
        Instant expiresAt = now.plus(purpose.getTtlMinutes(), ChronoUnit.MINUTES);

        String encryptedSecret = pendingPlainSecret != null
                ? secretCipherService.encrypt(pendingPlainSecret)
                : encryptedSecretToCarryOver;

        OtpCode newOtp = OtpCode.builder()
                .userId(user.getId())
                .ticket(ticket)
                .purpose(purpose.name())
                .codeHash(passwordEncoder.encode(rawCode))
                .encryptedPendingSecret(encryptedSecret)
                .attemptCount(0)
                .expiresAt(expiresAt)
                .createdAt(now)
                .build();
        otpCodeRepository.save(newOtp);

        mailSenderService.sendOtpEmail(user.getEmail(), user.getFullName(), rawCode, purpose);

        return new IssuedOtp(ticket, rawCode, expiresAt, RESEND_COOLDOWN_SECONDS);
    }

    @Transactional(noRollbackFor = AppException.class)
    public VerifiedOtpResult verifyOtpByTicket(String ticket, String code, OtpPurpose expectedPurpose) {
        OtpCode otp = otpCodeRepository.findByTicket(ticket)
                .orElseThrow(() -> new AppException(ErrorCode.OTP_INVALID));

        return verifyOtpRecord(otp, code, expectedPurpose);
    }

    @Transactional(noRollbackFor = AppException.class)
    public VerifiedOtpResult verifyLatestOtpForUser(Long userId, String code, OtpPurpose expectedPurpose) {
        OtpCode otp = otpCodeRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .filter(o -> expectedPurpose.name().equalsIgnoreCase(o.getPurpose()) && o.getConsumedAt() == null)
                .findFirst()
                .orElseThrow(() -> new AppException(ErrorCode.OTP_INVALID));

        return verifyOtpRecord(otp, code, expectedPurpose);
    }

    private VerifiedOtpResult verifyOtpRecord(OtpCode otp, String rawCode, OtpPurpose expectedPurpose) {
        Instant now = Instant.now();

        if (!expectedPurpose.name().equalsIgnoreCase(otp.getPurpose())) {
            throw new AppException(ErrorCode.OTP_INVALID);
        }
        if (otp.getConsumedAt() != null) {
            throw new AppException(ErrorCode.OTP_EXPIRED, "Ma OTP nay da duoc su dung hoac da bi thay the");
        }
        if (otp.getAttemptCount() >= MAX_ATTEMPTS) {
            throw new AppException(ErrorCode.OTP_MAX_ATTEMPTS);
        }
        if (now.isAfter(otp.getExpiresAt())) {
            throw new AppException(ErrorCode.OTP_EXPIRED);
        }

        if (rawCode == null || !passwordEncoder.matches(rawCode.trim(), otp.getCodeHash())) {
            int updatedAttempts = otp.getAttemptCount() + 1;
            otp.setAttemptCount(updatedAttempts);
            otpCodeRepository.save(otp);
            if (updatedAttempts >= MAX_ATTEMPTS) {
                throw new AppException(ErrorCode.OTP_MAX_ATTEMPTS);
            }
            throw new AppException(ErrorCode.OTP_INVALID);
        }

        String decryptedSecret = secretCipherService.decrypt(otp.getEncryptedPendingSecret());
        otp.setConsumedAt(now);
        otp.setEncryptedPendingSecret(null);
        otpCodeRepository.save(otp);

        return new VerifiedOtpResult(otp, decryptedSecret);
    }
}
