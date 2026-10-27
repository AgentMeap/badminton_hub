package com.se183891.badminton_be.auth.service;

import com.se183891.badminton_be.auth.entity.OtpPurpose;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class MailSenderService {

    private static final Logger log = LoggerFactory.getLogger(MailSenderService.class);

    private final JavaMailSender javaMailSender;
    private final String smtpUsername;
    private final String smtpPassword;
    private final String fromAddress;
    private final boolean logOtpToConsole;

    private final Map<String, String> lastOtpByEmail = new ConcurrentHashMap<>();

    public MailSenderService(
            @Autowired(required = false) JavaMailSender javaMailSender,
            @Value("${spring.mail.username:}") String smtpUsername,
            @Value("${spring.mail.password:}") String smtpPassword,
            @Value("${app.mail.from:no-reply@badminton.vn}") String fromAddress,
            @Value("${app.mail.log-otp-to-console:true}") boolean logOtpToConsole
    ) {
        this.javaMailSender = javaMailSender;
        this.smtpUsername = smtpUsername;
        this.smtpPassword = smtpPassword;
        this.fromAddress = fromAddress;
        this.logOtpToConsole = logOtpToConsole;
    }

    public void sendOtpEmail(String recipientEmail, String fullName, String rawOtpCode, OtpPurpose purpose) {
        String normalizedEmail = recipientEmail.trim().toLowerCase(Locale.ROOT);
        lastOtpByEmail.put(normalizedEmail, rawOtpCode);

        String subject = buildSubject(purpose);
        String body = buildBody(fullName, rawOtpCode, purpose);

        if (logOtpToConsole) {
            log.info(
                    "\n============================================================\n" +
                    "[OTP EMAIL] To: {} | Purpose: {} | TTL: {} minutes\n" +
                    "[OTP CODE ] >>> {} <<<\n" +
                    "============================================================",
                    normalizedEmail,
                    purpose.name(),
                    purpose.getTtlMinutes(),
                    rawOtpCode
            );
        }

        if (isSmtpConfigured()) {
            try {
                SimpleMailMessage message = new SimpleMailMessage();
                message.setFrom(fromAddress);
                message.setTo(normalizedEmail);
                message.setSubject(subject);
                message.setText(body);
                javaMailSender.send(message);
                log.info("Sent OTP email via SMTP to {}", normalizedEmail);
            } catch (Exception ex) {
                log.warn("Failed to send SMTP email to {} (OTP is still logged in console if enabled): {}",
                        normalizedEmail, ex.getMessage());
            }
        }
    }

    public Optional<String> getLastOtpForEmail(String email) {
        if (email == null) {
            return Optional.empty();
        }
        return Optional.ofNullable(lastOtpByEmail.get(email.trim().toLowerCase(Locale.ROOT)));
    }

    private boolean isSmtpConfigured() {
        return javaMailSender != null
                && smtpUsername != null
                && !smtpUsername.isBlank()
                && !smtpUsername.contains("your-email")
                && smtpPassword != null
                && !smtpPassword.isBlank()
                && !smtpPassword.contains("CHANGE_ME");
    }

    private String buildSubject(OtpPurpose purpose) {
        return switch (purpose) {
            case VERIFY_EMAIL -> "[Badminton Booking] Ma OTP xac thuc dang ky tai khoan";
            case LOGIN -> "[Badminton Booking] Ma OTP xac minh dang nhap thiet bi moi";
            case RESET_PASSWORD -> "[Badminton Booking] Ma OTP dat lai mat khau";
            case CHANGE_PASSWORD -> "[Badminton Booking] Ma OTP xac nhan doi mat khau";
            case BANK_ACCOUNT -> "[Badminton Booking] Ma OTP xac nhan tai khoan ngan hang";
        };
    }

    private String buildBody(String fullName, String rawOtpCode, OtpPurpose purpose) {
        String displayName = (fullName == null || fullName.isBlank()) ? "Ban" : fullName;
        return "Xin chao " + displayName + ",\n\n"
                + "Ma xac thuc OTP cua ban la: " + rawOtpCode + "\n"
                + "Muc dich: " + purpose.name() + "\n"
                + "Ma co hieu luc trong " + purpose.getTtlMinutes() + " phut.\n"
                + "Vui long khong chia se ma nay cho bat ky ai.\n\n"
                + "Tran trong,\nDoi ngu Badminton Booking";
    }
}
