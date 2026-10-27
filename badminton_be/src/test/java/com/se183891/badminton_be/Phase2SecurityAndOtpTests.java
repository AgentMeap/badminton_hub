package com.se183891.badminton_be;

import com.se183891.badminton_be.auth.entity.OtpCode;
import com.se183891.badminton_be.auth.entity.OtpPurpose;
import com.se183891.badminton_be.auth.repository.OtpCodeRepository;
import com.se183891.badminton_be.auth.service.FirebaseAuthService;
import com.se183891.badminton_be.auth.service.OtpService;
import com.se183891.badminton_be.common.exception.AppException;
import com.se183891.badminton_be.common.exception.ErrorCode;
import com.se183891.badminton_be.common.security.AuthenticatedUser;
import com.se183891.badminton_be.common.security.JwtService;
import com.se183891.badminton_be.user.entity.Role;
import com.se183891.badminton_be.user.entity.RoleCode;
import com.se183891.badminton_be.user.entity.User;
import com.se183891.badminton_be.user.repository.RoleRepository;
import com.se183891.badminton_be.user.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.Instant;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
class Phase2SecurityAndOtpTests {

    @Autowired
    private JwtService jwtService;

    @Autowired
    private OtpService otpService;

    @Autowired
    private OtpCodeRepository otpCodeRepository;

    @Autowired
    private FirebaseAuthService firebaseAuthService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Test
    void jwtServiceEncodesAndDecodesRbacClaims() {
        User customer = userRepository.findByEmailIgnoreCase("customer@badminton.vn").orElseThrow();
        String accessToken = jwtService.generateAccessToken(customer, 99L);

        AuthenticatedUser principal = jwtService.parseAccessToken(accessToken);
        assertEquals(customer.getId(), principal.userId());
        assertEquals("customer@badminton.vn", principal.email());
        assertEquals(99L, principal.sessionId());
        assertTrue(principal.hasRole(RoleCode.CUSTOMER));
        assertTrue(principal.hasPermission("BOOKING_CREATE"));
    }

    @Test
    void otpServiceEnforcesCooldownMaxAttemptsAndDecryptsPendingPasswordForFirebaseSync() {
        Role customerRole = roleRepository.findByCodeIgnoreCase(RoleCode.CUSTOMER.name()).orElseThrow();
        String testEmail = "phase2_otp_" + System.currentTimeMillis() + "@badminton.vn";
        User tempUser = userRepository.save(User.builder()
                .authProvider("LOCAL")
                .fullName("Test OTP User")
                .email(testEmail)
                .phone("0911222333")
                .passwordHash("hashed")
                .status("PENDING_VERIFICATION")
                .roles(Set.of(customerRole))
                .build());

        OtpService.IssuedOtp issued = otpService.issueAndSendOtp(
                tempUser,
                OtpPurpose.VERIFY_EMAIL,
                "MyPlainPassword123"
        );
        assertNotNull(issued.ticket());
        assertEquals(6, issued.rawCode().length());

        // 1. Immediate resend within 60s must throw OTP_COOLDOWN
        AppException cooldownEx = assertThrows(
                AppException.class,
                () -> otpService.issueAndSendOtp(tempUser, OtpPurpose.VERIFY_EMAIL, "MyPlainPassword123")
        );
        assertEquals(ErrorCode.OTP_COOLDOWN, cooldownEx.getErrorCode());

        // 2. Verify with correct code returns decrypted password and wipes encrypted secret in DB
        OtpService.VerifiedOtpResult verified = otpService.verifyOtpByTicket(
                issued.ticket(),
                issued.rawCode(),
                OtpPurpose.VERIFY_EMAIL
        );
        assertEquals("MyPlainPassword123", verified.decryptedPendingSecret());

        OtpCode inDb = otpCodeRepository.findByTicket(issued.ticket()).orElseThrow();
        assertNotNull(inDb.getConsumedAt());
        assertNull(inDb.getEncryptedPendingSecret());

        // 3. Sync user to Firebase Authentication after OTP verification
        String firebaseUid = firebaseAuthService.createVerifiedUserInFirebase(
                tempUser.getEmail(),
                verified.decryptedPendingSecret(),
                tempUser.getFullName()
        );
        assertTrue(firebaseUid.startsWith("fb-"));
        assertTrue(firebaseAuthService.getSyncedMockUserByEmail(testEmail).isPresent());
    }

    @Test
    void otpServiceLocksAfterThreeWrongAttempts() {
        Role customerRole = roleRepository.findByCodeIgnoreCase(RoleCode.CUSTOMER.name()).orElseThrow();
        String testEmail = "phase2_wrong_" + System.currentTimeMillis() + "@badminton.vn";
        User tempUser = userRepository.save(User.builder()
                .authProvider("LOCAL")
                .fullName("Test Wrong OTP")
                .email(testEmail)
                .phone("0911222444")
                .passwordHash("hashed")
                .status("ACTIVE")
                .roles(Set.of(customerRole))
                .build());

        OtpService.IssuedOtp issued = otpService.issueAndSendOtp(tempUser, OtpPurpose.LOGIN, null);

        // Attempt 1 & 2 -> OTP_INVALID
        AppException ex1 = assertThrows(
                AppException.class,
                () -> otpService.verifyOtpByTicket(issued.ticket(), "000000", OtpPurpose.LOGIN)
        );
        assertEquals(ErrorCode.OTP_INVALID, ex1.getErrorCode());

        AppException ex2 = assertThrows(
                AppException.class,
                () -> otpService.verifyOtpByTicket(issued.ticket(), "000000", OtpPurpose.LOGIN)
        );
        assertEquals(ErrorCode.OTP_INVALID, ex2.getErrorCode());

        // Attempt 3 -> OTP_MAX_ATTEMPTS
        AppException ex3 = assertThrows(
                AppException.class,
                () -> otpService.verifyOtpByTicket(issued.ticket(), "000000", OtpPurpose.LOGIN)
        );
        assertEquals(ErrorCode.OTP_MAX_ATTEMPTS, ex3.getErrorCode());

        // Even with the right code after 3 failures -> still OTP_MAX_ATTEMPTS
        OtpCode checkDb = otpCodeRepository.findByTicket(issued.ticket()).orElseThrow();
        assertEquals(3, checkDb.getAttemptCount());
        AppException ex4 = assertThrows(
                AppException.class,
                () -> otpService.verifyOtpByTicket(issued.ticket(), issued.rawCode(), OtpPurpose.LOGIN)
        );
        assertEquals(ErrorCode.OTP_MAX_ATTEMPTS, ex4.getErrorCode());
    }
}
