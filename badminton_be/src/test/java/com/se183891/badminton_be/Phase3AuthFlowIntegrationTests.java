package com.se183891.badminton_be;

import com.se183891.badminton_be.auth.dto.request.CustomerRegisterRequest;
import com.se183891.badminton_be.auth.dto.request.ForgotPasswordRequest;
import com.se183891.badminton_be.auth.dto.request.GoogleAuthRequest;
import com.se183891.badminton_be.auth.dto.request.LoginRequest;
import com.se183891.badminton_be.auth.dto.request.LoginVerifyOtpRequest;
import com.se183891.badminton_be.auth.dto.request.RefreshTokenRequest;
import com.se183891.badminton_be.auth.dto.request.ResetPasswordRequest;
import com.se183891.badminton_be.auth.dto.request.VerifyEmailOtpRequest;
import com.se183891.badminton_be.auth.dto.response.AuthTokenResponse;
import com.se183891.badminton_be.auth.dto.response.OtpChallengeResponse;
import com.se183891.badminton_be.auth.service.AuthService;
import com.se183891.badminton_be.auth.service.FirebaseAuthService;
import com.se183891.badminton_be.auth.service.MailSenderService;
import com.se183891.badminton_be.common.exception.AppException;
import com.se183891.badminton_be.common.exception.ErrorCode;
import com.se183891.badminton_be.owner.dto.OwnerApplicationResponse;
import com.se183891.badminton_be.owner.service.OwnerOnboardingService;
import com.se183891.badminton_be.user.entity.RoleCode;
import com.se183891.badminton_be.user.entity.User;
import com.se183891.badminton_be.user.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockMultipartFile;

import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
class Phase3AuthFlowIntegrationTests {

    @Autowired
    private AuthService authService;

    @Autowired
    private OwnerOnboardingService ownerOnboardingService;

    @Autowired
    private MailSenderService mailSenderService;

    @Autowired
    private FirebaseAuthService firebaseAuthService;

    @Autowired
    private UserRepository userRepository;

    @Test
    void customerNormalRegisterOtpVerifyFirebaseSyncAndTrustedDeviceLoginFlow() {
        String email = "reg_customer_" + System.currentTimeMillis() + "@badminton.vn";

        // 1. Register normal customer -> sends OTP via SMTP, does NOT sync to Firebase before OTP is verified
        OtpChallengeResponse regChallenge = authService.registerCustomer(new CustomerRegisterRequest(
                "Le Minh Khach",
                email,
                "0912345678",
                "Badminton123"
        ));
        assertTrue(regChallenge.otpRequired());
        assertNotNull(regChallenge.otpTicket());
        assertFalse(firebaseAuthService.getSyncedMockUserByEmail(email).isPresent());

        // 2. Verify OTP -> creates user in Firebase Authentication & issues tokens + trusts device-A
        String otpCode = mailSenderService.getLastOtpForEmail(email).orElseThrow();
        AuthTokenResponse verifiedTokens = authService.verifyEmailOtp(
                RoleCode.CUSTOMER,
                new VerifyEmailOtpRequest(email, regChallenge.otpTicket(), otpCode, "device-A", "iPhone 16"),
                "127.0.0.1"
        );
        assertFalse(verifiedTokens.otpRequired());
        assertNotNull(verifiedTokens.accessToken());
        assertNotNull(verifiedTokens.refreshToken());
        assertNotNull(verifiedTokens.user().firebaseUid());
        assertTrue(firebaseAuthService.getSyncedMockUserByEmail(email).isPresent());

        // 3. Login from trusted device-A -> returns AuthTokenResponse immediately (no OTP challenge)
        Object trustedLoginResult = authService.login(
                RoleCode.CUSTOMER,
                new LoginRequest(email, "Badminton123", "device-A", "iPhone 16"),
                "127.0.0.1"
        );
        AuthTokenResponse immediateLogin = assertInstanceOf(AuthTokenResponse.class, trustedLoginResult);
        assertNotNull(immediateLogin.accessToken());

        // 4. Login from untrusted device-B -> requires LOGIN OTP challenge
        Object untrustedLoginResult = authService.login(
                RoleCode.CUSTOMER,
                new LoginRequest(email, "Badminton123", "device-B", "iPad Air"),
                "127.0.0.1"
        );
        OtpChallengeResponse loginChallenge = assertInstanceOf(OtpChallengeResponse.class, untrustedLoginResult);
        assertTrue(loginChallenge.otpRequired());

        String loginOtp = mailSenderService.getLastOtpForEmail(email).orElseThrow();
        AuthTokenResponse secondDeviceTokens = authService.verifyLoginOtp(
                RoleCode.CUSTOMER,
                new LoginVerifyOtpRequest(loginChallenge.otpTicket(), loginOtp, "device-B", "iPad Air", true),
                "127.0.0.1"
        );
        assertNotNull(secondDeviceTokens.accessToken());
    }

    @Test
    void googleFirebaseSignInAndAccountLinkingFlow() {
        String googleEmail = "google_player_" + System.currentTimeMillis() + "@gmail.com";
        AuthTokenResponse googleAuth = authService.authenticateWithGoogle(
                new GoogleAuthRequest("mock-google:" + googleEmail + ":Pham Hoang Google", "dev-google-1", "Pixel 9"),
                "127.0.0.1"
        );
        assertEquals("GOOGLE", googleAuth.user().authProvider());
        assertEquals("ACTIVE", googleAuth.user().status());
        assertTrue(googleAuth.user().roles().contains("CUSTOMER"));

        // Attempting normal registration with the same Google email should return EMAIL_REGISTERED_WITH_GOOGLE
        AppException conflictEx = assertThrows(
                AppException.class,
                () -> authService.registerCustomer(new CustomerRegisterRequest(
                        "Duplicate User",
                        googleEmail,
                        "0988777666",
                        "Badminton123"
                ))
        );
        assertEquals(ErrorCode.EMAIL_REGISTERED_WITH_GOOGLE, conflictEx.getErrorCode());
    }

    @Test
    void fiveFailedPasswordsLockAccountAndResetPasswordUnlocksAndRevokesSessions() {
        String email = "lockout_user_" + System.currentTimeMillis() + "@badminton.vn";
        OtpChallengeResponse reg = authService.registerCustomer(new CustomerRegisterRequest(
                "Lockout Tester",
                email,
                "0933444555",
                "Badminton123"
        ));
        String regOtp = mailSenderService.getLastOtpForEmail(email).orElseThrow();
        AuthTokenResponse initialTokens = authService.verifyEmailOtp(
                RoleCode.CUSTOMER,
                new VerifyEmailOtpRequest(email, reg.otpTicket(), regOtp, "dev-lock-1", "Chrome"),
                "127.0.0.1"
        );

        // 4 failed attempts -> AUTH_INVALID_CREDENTIALS
        for (int i = 1; i <= 4; i++) {
            AppException wrongEx = assertThrows(
                    AppException.class,
                    () -> authService.login(
                            RoleCode.CUSTOMER,
                            new LoginRequest(email, "WrongPass999", "dev-lock-1", "Chrome"),
                            "127.0.0.1"
                    )
            );
            assertEquals(ErrorCode.AUTH_INVALID_CREDENTIALS, wrongEx.getErrorCode());
        }

        // 5th failed attempt -> ACCOUNT_LOCKED (15 minutes)
        AppException lockEx = assertThrows(
                AppException.class,
                () -> authService.login(
                        RoleCode.CUSTOMER,
                        new LoginRequest(email, "WrongPass999", "dev-lock-1", "Chrome"),
                        "127.0.0.1"
                )
        );
        assertEquals(ErrorCode.ACCOUNT_LOCKED, lockEx.getErrorCode());

        // Forgot password + Reset password unlocks account & revokes old refresh token
        OtpChallengeResponse forgotChallenge = authService.forgotPassword(
                RoleCode.CUSTOMER,
                new ForgotPasswordRequest(email)
        );
        String resetOtp = mailSenderService.getLastOtpForEmail(email).orElseThrow();
        authService.resetPassword(
                RoleCode.CUSTOMER,
                new ResetPasswordRequest(email, forgotChallenge.otpTicket(), resetOtp, "NewBadminton456")
        );

        // Old refresh token must now be invalid (revoked)
        AppException revokedEx = assertThrows(
                AppException.class,
                () -> authService.refreshToken(new RefreshTokenRequest(initialTokens.refreshToken(), "dev-lock-1"), "127.0.0.1")
        );
        assertEquals(ErrorCode.REFRESH_TOKEN_INVALID, revokedEx.getErrorCode());

        // Login with new password on trusted device succeeds
        Object unlockedLogin = authService.login(
                RoleCode.CUSTOMER,
                new LoginRequest(email, "NewBadminton456", "dev-lock-1", "Chrome"),
                "127.0.0.1"
        );
        assertInstanceOf(AuthTokenResponse.class, unlockedLogin);
    }

    @Test
    void ownerRegisterWithLicenseFileAndAdminApproveFlow() {
        String ownerEmail = "new_owner_" + System.currentTimeMillis() + "@badminton.vn";
        MockMultipartFile licenseFile = new MockMultipartFile(
                "licenseFile",
                "giay-phep-kinh-doanh.pdf",
                "application/pdf",
                "%PDF-1.4 sample license content".getBytes(StandardCharsets.UTF_8)
        );

        OtpChallengeResponse ownerReg = authService.registerOwner(
                "Pham Chu San Moi",
                ownerEmail,
                "0977888999",
                "Badminton123",
                "San Cau Long Thao Dien",
                "0399887766",
                "28 Thao Dien, TP. Thu Duc",
                licenseFile
        );
        String otp = mailSenderService.getLastOtpForEmail(ownerEmail).orElseThrow();

        AuthTokenResponse ownerTokens = authService.verifyEmailOtp(
                RoleCode.OWNER,
                new VerifyEmailOtpRequest(ownerEmail, ownerReg.otpTicket(), otp, "dev-owner-1", "MacBook"),
                "127.0.0.1"
        );
        assertEquals("PENDING", ownerTokens.user().ownerApplicationStatus());

        OwnerApplicationResponse latestApp = ownerOnboardingService.getLatestApplicationForOwner(ownerTokens.user().id());
        assertEquals("PENDING", latestApp.status());
        assertTrue(latestApp.licenseFileUrl().startsWith("/files/licenses/"));

        User admin = userRepository.findByEmailIgnoreCase("admin@badminton.vn").orElseThrow();
        OwnerApplicationResponse approvedApp = ownerOnboardingService.approveApplication(latestApp.id(), admin.getId());
        assertEquals("APPROVED", approvedApp.status());
    }
}
