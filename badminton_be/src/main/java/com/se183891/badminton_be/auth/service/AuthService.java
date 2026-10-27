package com.se183891.badminton_be.auth.service;

import com.se183891.badminton_be.auth.dto.request.CustomerRegisterRequest;
import com.se183891.badminton_be.auth.dto.request.ForgotPasswordRequest;
import com.se183891.badminton_be.auth.dto.request.GoogleAuthRequest;
import com.se183891.badminton_be.auth.dto.request.LoginRequest;
import com.se183891.badminton_be.auth.dto.request.LoginVerifyOtpRequest;
import com.se183891.badminton_be.auth.dto.request.LogoutRequest;
import com.se183891.badminton_be.auth.dto.request.RefreshTokenRequest;
import com.se183891.badminton_be.auth.dto.request.ResendOtpRequest;
import com.se183891.badminton_be.auth.dto.request.ResetPasswordRequest;
import com.se183891.badminton_be.auth.dto.request.VerifyEmailOtpRequest;
import com.se183891.badminton_be.auth.dto.response.AuthTokenResponse;
import com.se183891.badminton_be.auth.dto.response.OtpChallengeResponse;
import com.se183891.badminton_be.auth.dto.response.UserSummaryResponse;
import com.se183891.badminton_be.auth.entity.AuthSession;
import com.se183891.badminton_be.auth.entity.LoginLog;
import com.se183891.badminton_be.auth.entity.OtpCode;
import com.se183891.badminton_be.auth.entity.OtpPurpose;
import com.se183891.badminton_be.auth.entity.TrustedDevice;
import com.se183891.badminton_be.auth.repository.AuthSessionRepository;
import com.se183891.badminton_be.auth.repository.LoginLogRepository;
import com.se183891.badminton_be.auth.repository.OtpCodeRepository;
import com.se183891.badminton_be.auth.repository.TrustedDeviceRepository;
import com.se183891.badminton_be.common.exception.AppException;
import com.se183891.badminton_be.common.exception.ErrorCode;
import com.se183891.badminton_be.common.response.ApiResponse;
import com.se183891.badminton_be.common.security.AuthenticatedUser;
import com.se183891.badminton_be.common.security.JwtService;
import com.se183891.badminton_be.common.storage.StorageService;
import com.se183891.badminton_be.owner.entity.OwnerApplication;
import com.se183891.badminton_be.owner.repository.OwnerApplicationRepository;
import com.se183891.badminton_be.user.entity.Role;
import com.se183891.badminton_be.user.entity.RoleCode;
import com.se183891.badminton_be.user.entity.User;
import com.se183891.badminton_be.user.repository.RoleRepository;
import com.se183891.badminton_be.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class AuthService {

    private static final Pattern PASSWORD_POLICY = Pattern.compile("^(?=.*[A-Za-z])(?=.*\\d).{8,}$");
    private static final int MAX_FAILED_PASSWORD_ATTEMPTS = 5;
    private static final int PASSWORD_LOCK_MINUTES = 15;
    private static final int ADMIN_OTP_LOCK_MINUTES = 30;

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final OwnerApplicationRepository ownerApplicationRepository;
    private final OtpCodeRepository otpCodeRepository;
    private final TrustedDeviceRepository trustedDeviceRepository;
    private final AuthSessionRepository authSessionRepository;
    private final LoginLogRepository loginLogRepository;
    private final OtpService otpService;
    private final FirebaseAuthService firebaseAuthService;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final StorageService storageService;

    @Transactional
    public OtpChallengeResponse registerCustomer(CustomerRegisterRequest request) {
        validatePasswordStrength(request.password());
        String normalizedEmail = normalizeEmail(request.email());

        Role customerRole = getRoleOrThrow(RoleCode.CUSTOMER);
        Optional<User> existingOpt = userRepository.findByEmailIgnoreCase(normalizedEmail);

        User user;
        if (existingOpt.isPresent()) {
            User existing = existingOpt.get();
            if ("PENDING_VERIFICATION".equalsIgnoreCase(existing.getStatus()) && existing.hasRole(RoleCode.CUSTOMER)) {
                existing.setFullName(request.fullName().trim());
                existing.setPhone(request.phone().trim());
                existing.setPasswordHash(passwordEncoder.encode(request.password()));
                user = userRepository.save(existing);
            } else if ("GOOGLE".equalsIgnoreCase(existing.getAuthProvider()) && existing.getPasswordHash() == null) {
                throw new AppException(ErrorCode.EMAIL_REGISTERED_WITH_GOOGLE);
            } else {
                throw new AppException(ErrorCode.EMAIL_ALREADY_EXISTS);
            }
        } else {
            user = userRepository.save(User.builder()
                    .authProvider("LOCAL")
                    .fullName(request.fullName().trim())
                    .email(normalizedEmail)
                    .phone(request.phone().trim())
                    .passwordHash(passwordEncoder.encode(request.password()))
                    .status("PENDING_VERIFICATION")
                    .failedLoginCount(0)
                    .roles(new HashSet<>(Set.of(customerRole)))
                    .build());
        }

        OtpService.IssuedOtp issued = otpService.issueAndSendOtp(user, OtpPurpose.VERIFY_EMAIL, request.password());
        return new OtpChallengeResponse(
                true,
                issued.ticket(),
                OtpPurpose.VERIFY_EMAIL.name(),
                user.getEmail(),
                issued.expiresAt().toString(),
                issued.cooldownSeconds(),
                "Ma OTP 6 so da duoc gui toi email " + user.getEmail()
        );
    }

    @Transactional
    public OtpChallengeResponse registerOwner(
            String fullName,
            String email,
            String phone,
            String password,
            String businessName,
            String taxCode,
            String address,
            MultipartFile licenseFile
    ) {
        validatePasswordStrength(password);
        if (businessName == null || businessName.isBlank()) {
            throw new AppException(ErrorCode.VALIDATION_ERROR, "Ten co so kinh doanh khong duoc de trong");
        }
        if (address == null || address.isBlank()) {
            throw new AppException(ErrorCode.VALIDATION_ERROR, "Dia chi co so khong duoc de trong");
        }

        String licenseUrl = storageService.storeFile(licenseFile, "licenses");
        String normalizedEmail = normalizeEmail(email);
        Role ownerRole = getRoleOrThrow(RoleCode.OWNER);

        Optional<User> existingOpt = userRepository.findByEmailIgnoreCase(normalizedEmail);
        User ownerUser;
        if (existingOpt.isPresent()) {
            User existing = existingOpt.get();
            if ("PENDING_VERIFICATION".equalsIgnoreCase(existing.getStatus()) && existing.hasRole(RoleCode.OWNER)) {
                existing.setFullName(fullName.trim());
                existing.setPhone(phone.trim());
                existing.setPasswordHash(passwordEncoder.encode(password));
                ownerUser = userRepository.save(existing);
            } else {
                throw new AppException(ErrorCode.EMAIL_ALREADY_EXISTS);
            }
        } else {
            ownerUser = userRepository.save(User.builder()
                    .authProvider("LOCAL")
                    .fullName(fullName.trim())
                    .email(normalizedEmail)
                    .phone(phone.trim())
                    .passwordHash(passwordEncoder.encode(password))
                    .status("PENDING_VERIFICATION")
                    .failedLoginCount(0)
                    .roles(new HashSet<>(Set.of(ownerRole)))
                    .build());
        }

        OwnerApplication app = ownerApplicationRepository.findFirstByUserIdOrderBySubmittedAtDesc(ownerUser.getId())
                .orElseGet(() -> OwnerApplication.builder().userId(ownerUser.getId()).build());
        app.setBusinessName(businessName.trim());
        app.setTaxCode(taxCode != null ? taxCode.trim() : null);
        app.setAddress(address.trim());
        app.setLicenseFileUrl(licenseUrl);
        app.setStatus("PENDING");
        app.setRejectReason(null);
        app.setSubmittedAt(Instant.now());
        ownerApplicationRepository.save(app);

        OtpService.IssuedOtp issued = otpService.issueAndSendOtp(ownerUser, OtpPurpose.VERIFY_EMAIL, password);
        return new OtpChallengeResponse(
                true,
                issued.ticket(),
                OtpPurpose.VERIFY_EMAIL.name(),
                ownerUser.getEmail(),
                issued.expiresAt().toString(),
                issued.cooldownSeconds(),
                "Ho so chu san da duoc ghi nhan. Vui long nhap ma OTP gui qua email de xac thuc"
        );
    }

    @Transactional(noRollbackFor = AppException.class)
    public AuthTokenResponse verifyEmailOtp(RoleCode roleCode, VerifyEmailOtpRequest request, String ipAddress) {
        OtpService.VerifiedOtpResult verified;
        User user;

        if (request.otpTicket() != null && !request.otpTicket().isBlank()) {
            verified = otpService.verifyOtpByTicket(request.otpTicket().trim(), request.code(), OtpPurpose.VERIFY_EMAIL);
            user = userRepository.findById(verified.otpCode().getUserId())
                    .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND, "Khong tim thay tai khoan"));
        } else if (request.email() != null && !request.email().isBlank()) {
            user = userRepository.findByEmailIgnoreCase(normalizeEmail(request.email()))
                    .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND, "Khong tim thay tai khoan"));
            verified = otpService.verifyLatestOtpForUser(user.getId(), request.code(), OtpPurpose.VERIFY_EMAIL);
        } else {
            throw new AppException(ErrorCode.BAD_REQUEST, "Can cung cap otpTicket hoac email");
        }

        if (!user.hasRole(roleCode)) {
            throw new AppException(ErrorCode.FORBIDDEN, "Tai khoan khong thuoc vai tro " + roleCode.name());
        }

        // Sync verified account to Firebase Authentication
        String firebaseUid = firebaseAuthService.createVerifiedUserInFirebase(
                user.getEmail(),
                verified.decryptedPendingSecret(),
                user.getFullName()
        );
        user.setFirebaseUid(firebaseUid);
        user.setStatus("ACTIVE");
        user.setFailedLoginCount(0);
        user.setLockedUntil(null);
        userRepository.save(user);

        if (request.deviceId() != null && !request.deviceId().isBlank()) {
            saveOrUpdateTrustedDevice(user.getId(), request.deviceId(), request.deviceName());
        }

        return issueSessionAndTokens(user, request.deviceId(), ipAddress);
    }

    @Transactional
    public AuthTokenResponse authenticateWithGoogle(GoogleAuthRequest request, String ipAddress) {
        FirebaseAuthService.GoogleTokenClaims claims = firebaseAuthService.verifyGoogleIdToken(request.idToken());
        Role customerRole = getRoleOrThrow(RoleCode.CUSTOMER);

        Optional<User> existingOpt = userRepository.findByEmailIgnoreCase(claims.email());
        User user;
        if (existingOpt.isEmpty()) {
            user = userRepository.save(User.builder()
                    .firebaseUid(claims.firebaseUid())
                    .authProvider("GOOGLE")
                    .fullName(claims.fullName())
                    .email(claims.email())
                    .avatarUrl(claims.avatarUrl())
                    .status("ACTIVE")
                    .failedLoginCount(0)
                    .roles(new HashSet<>(Set.of(customerRole)))
                    .build());
        } else {
            user = existingOpt.get();
            checkAccountNotLocked(user);
            user.setFirebaseUid(claims.firebaseUid());
            if (user.getAvatarUrl() == null && claims.avatarUrl() != null) {
                user.setAvatarUrl(claims.avatarUrl());
            }
            if ("LOCAL".equalsIgnoreCase(user.getAuthProvider())) {
                user.setAuthProvider("BOTH");
            }
            if ("PENDING_VERIFICATION".equalsIgnoreCase(user.getStatus())) {
                user.setStatus("ACTIVE");
            }
            if (!user.hasRole(RoleCode.CUSTOMER)) {
                user.getRoles().add(customerRole);
            }
            user = userRepository.save(user);
        }

        if (request.deviceId() != null && !request.deviceId().isBlank()) {
            saveOrUpdateTrustedDevice(user.getId(), request.deviceId(), request.deviceName());
        }

        recordLoginLog(user.getId(), RoleCode.CUSTOMER.name(), user.getEmail(), request.deviceId(), ipAddress, true, "GOOGLE_AUTH_OK");
        return issueSessionAndTokens(user, request.deviceId(), ipAddress);
    }

    @Transactional
    public OtpChallengeResponse resendOtp(RoleCode roleCode, ResendOtpRequest request) {
        String normalizedEmail = normalizeEmail(request.email());
        User user = userRepository.findByEmailIgnoreCase(normalizedEmail)
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND, "Khong tim thay tai khoan voi email nay"));
        if (!user.hasRole(roleCode)) {
            throw new AppException(ErrorCode.FORBIDDEN, "Tai khoan khong thuoc vai tro " + roleCode.name());
        }

        OtpPurpose purpose = OtpPurpose.VERIFY_EMAIL;
        if (request.purpose() != null && !request.purpose().isBlank()) {
            try {
                purpose = OtpPurpose.valueOf(request.purpose().trim().toUpperCase(Locale.ROOT));
            } catch (IllegalArgumentException ex) {
                throw new AppException(ErrorCode.BAD_REQUEST, "Muc dich OTP khong hop le");
            }
        }

        OtpService.IssuedOtp issued = otpService.issueAndSendOtp(user, purpose, null);
        return new OtpChallengeResponse(
                true,
                issued.ticket(),
                purpose.name(),
                user.getEmail(),
                issued.expiresAt().toString(),
                issued.cooldownSeconds(),
                "Ma OTP moi da duoc gui toi " + user.getEmail()
        );
    }

    @Transactional(noRollbackFor = AppException.class)
    public Object login(RoleCode roleCode, LoginRequest request, String ipAddress) {
        String normalizedEmail = normalizeEmail(request.email());
        Optional<User> userOpt = userRepository.findByEmailIgnoreCase(normalizedEmail);

        if (userOpt.isEmpty() || !userOpt.get().hasRole(roleCode)) {
            recordLoginLog(null, roleCode.name(), normalizedEmail, request.deviceId(), ipAddress, false, "USER_OR_ROLE_NOT_FOUND");
            throw new AppException(ErrorCode.AUTH_INVALID_CREDENTIALS);
        }

        User user = userOpt.get();
        checkAccountNotLocked(user);

        if ("PENDING_VERIFICATION".equalsIgnoreCase(user.getStatus())) {
            recordLoginLog(user.getId(), roleCode.name(), normalizedEmail, request.deviceId(), ipAddress, false, "EMAIL_NOT_VERIFIED");
            throw new AppException(ErrorCode.AUTH_EMAIL_NOT_VERIFIED);
        }

        if (user.getPasswordHash() == null || user.getPasswordHash().isBlank()) {
            recordLoginLog(user.getId(), roleCode.name(), normalizedEmail, request.deviceId(), ipAddress, false, "GOOGLE_ONLY_ACCOUNT");
            throw new AppException(ErrorCode.EMAIL_REGISTERED_WITH_GOOGLE);
        }

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            int failed = user.getFailedLoginCount() + 1;
            user.setFailedLoginCount(failed);
            if (failed >= MAX_FAILED_PASSWORD_ATTEMPTS) {
                user.setLockedUntil(Instant.now().plus(PASSWORD_LOCK_MINUTES, ChronoUnit.MINUTES));
                user.setStatus("LOCKED");
                userRepository.save(user);
                recordLoginLog(user.getId(), roleCode.name(), normalizedEmail, request.deviceId(), ipAddress, false, "LOCKED_AFTER_5_FAILURES");
                throw new AppException(
                        ErrorCode.ACCOUNT_LOCKED,
                        "Ban da nhap sai mat khau 5 lan. Tai khoan bi khoa tam thoi 15 phut"
                );
            }
            userRepository.save(user);
            recordLoginLog(user.getId(), roleCode.name(), normalizedEmail, request.deviceId(), ipAddress, false, "WRONG_PASSWORD_" + failed);
            throw new AppException(
                    ErrorCode.AUTH_INVALID_CREDENTIALS,
                    "Email hoac mat khau khong dung (con " + (MAX_FAILED_PASSWORD_ATTEMPTS - failed) + " lan thu)"
            );
        }

        // Password matched: clear failed login counters
        user.setFailedLoginCount(0);
        user.setLockedUntil(null);
        if ("LOCKED".equalsIgnoreCase(user.getStatus())) {
            user.setStatus("ACTIVE");
        }
        userRepository.save(user);

        boolean deviceTrusted = isDeviceTrusted(user.getId(), request.deviceId());
        if (deviceTrusted) {
            saveOrUpdateTrustedDevice(user.getId(), request.deviceId(), request.deviceName());
            recordLoginLog(user.getId(), roleCode.name(), normalizedEmail, request.deviceId(), ipAddress, true, "TRUSTED_DEVICE_OK");
            return issueSessionAndTokens(user, request.deviceId(), ipAddress);
        }

        // Untrusted / new device -> issue LOGIN OTP
        OtpService.IssuedOtp issued = otpService.issueAndSendOtp(user, OtpPurpose.LOGIN, null);
        recordLoginLog(user.getId(), roleCode.name(), normalizedEmail, request.deviceId(), ipAddress, true, "OTP_REQUIRED_NEW_DEVICE");
        return new OtpChallengeResponse(
                true,
                issued.ticket(),
                OtpPurpose.LOGIN.name(),
                user.getEmail(),
                issued.expiresAt().toString(),
                issued.cooldownSeconds(),
                "Phat hien thiet bi moi. Vui long nhap ma OTP 6 so gui qua email"
        );
    }

    @Transactional(noRollbackFor = AppException.class)
    public AuthTokenResponse verifyLoginOtp(RoleCode roleCode, LoginVerifyOtpRequest request, String ipAddress) {
        OtpCode otpRecord = otpCodeRepository.findByTicket(request.otpTicket().trim())
                .orElseThrow(() -> new AppException(ErrorCode.OTP_INVALID));
        User user = userRepository.findById(otpRecord.getUserId())
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND, "Khong tim thay tai khoan"));

        if (!user.hasRole(roleCode)) {
            throw new AppException(ErrorCode.FORBIDDEN, "Tai khoan khong thuoc vai tro " + roleCode.name());
        }
        checkAccountNotLocked(user);

        try {
            otpService.verifyOtpByTicket(request.otpTicket().trim(), request.code(), OtpPurpose.LOGIN);
        } catch (AppException ex) {
            if (ex.getErrorCode() == ErrorCode.OTP_MAX_ATTEMPTS && roleCode == RoleCode.ADMIN) {
                user.setLockedUntil(Instant.now().plus(ADMIN_OTP_LOCK_MINUTES, ChronoUnit.MINUTES));
                user.setStatus("LOCKED");
                userRepository.save(user);
                throw new AppException(
                        ErrorCode.ACCOUNT_LOCKED,
                        "Tai khoan Admin bi khoa 30 phut do nhap sai OTP 3 lan"
                );
            }
            throw ex;
        }

        if (request.trustDevice() && request.deviceId() != null && !request.deviceId().isBlank()) {
            saveOrUpdateTrustedDevice(user.getId(), request.deviceId(), request.deviceName());
        }

        recordLoginLog(user.getId(), roleCode.name(), user.getEmail(), request.deviceId(), ipAddress, true, "OTP_LOGIN_VERIFIED");
        return issueSessionAndTokens(user, request.deviceId(), ipAddress);
    }

    @Transactional
    public OtpChallengeResponse forgotPassword(RoleCode roleCode, ForgotPasswordRequest request) {
        String normalizedEmail = normalizeEmail(request.email());
        User user = userRepository.findByEmailIgnoreCase(normalizedEmail)
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND, "Khong tim thay tai khoan voi email nay"));
        if (!user.hasRole(roleCode)) {
            throw new AppException(ErrorCode.FORBIDDEN, "Tai khoan khong thuoc vai tro " + roleCode.name());
        }

        OtpService.IssuedOtp issued = otpService.issueAndSendOtp(user, OtpPurpose.RESET_PASSWORD, null);
        return new OtpChallengeResponse(
                true,
                issued.ticket(),
                OtpPurpose.RESET_PASSWORD.name(),
                user.getEmail(),
                issued.expiresAt().toString(),
                issued.cooldownSeconds(),
                "Ma OTP dat lai mat khau da duoc gui toi " + user.getEmail()
        );
    }

    @Transactional(noRollbackFor = AppException.class)
    public void resetPassword(RoleCode roleCode, ResetPasswordRequest request) {
        validatePasswordStrength(request.newPassword());

        User user;
        if (request.otpTicket() != null && !request.otpTicket().isBlank()) {
            OtpService.VerifiedOtpResult verified = otpService.verifyOtpByTicket(
                    request.otpTicket().trim(),
                    request.code(),
                    OtpPurpose.RESET_PASSWORD
            );
            user = userRepository.findById(verified.otpCode().getUserId())
                    .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND));
        } else if (request.email() != null && !request.email().isBlank()) {
            user = userRepository.findByEmailIgnoreCase(normalizeEmail(request.email()))
                    .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND));
            otpService.verifyLatestOtpForUser(user.getId(), request.code(), OtpPurpose.RESET_PASSWORD);
        } else {
            throw new AppException(ErrorCode.BAD_REQUEST, "Can cung cap otpTicket hoac email");
        }

        if (!user.hasRole(roleCode)) {
            throw new AppException(ErrorCode.FORBIDDEN);
        }

        user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        if ("GOOGLE".equalsIgnoreCase(user.getAuthProvider())) {
            user.setAuthProvider("BOTH");
        }
        user.setFailedLoginCount(0);
        user.setLockedUntil(null);
        if ("LOCKED".equalsIgnoreCase(user.getStatus())) {
            user.setStatus("ACTIVE");
        }
        userRepository.save(user);

        // Sync new password to Firebase Authentication
        firebaseAuthService.updatePasswordInFirebase(user.getFirebaseUid(), user.getEmail(), request.newPassword());

        // Revoke all active refresh sessions for this user
        revokeAllSessionsForUser(user.getId());
    }

    @Transactional
    public AuthTokenResponse refreshToken(RefreshTokenRequest request, String ipAddress) {
        String tokenHash = jwtService.hashRefreshToken(request.refreshToken());
        AuthSession session = authSessionRepository.findByRefreshTokenHash(tokenHash)
                .orElseThrow(() -> new AppException(ErrorCode.REFRESH_TOKEN_INVALID));

        Instant now = Instant.now();
        if (session.getRevokedAt() != null || now.isAfter(session.getExpiresAt())) {
            throw new AppException(ErrorCode.REFRESH_TOKEN_INVALID);
        }

        User user = userRepository.findById(session.getUserId())
                .orElseThrow(() -> new AppException(ErrorCode.UNAUTHORIZED));
        checkAccountNotLocked(user);

        // Rotate refresh token within the same session
        String newRawRefreshToken = jwtService.generateRawRefreshToken();
        session.setRefreshTokenHash(jwtService.hashRefreshToken(newRawRefreshToken));
        session.setExpiresAt(jwtService.calculateRefreshTokenExpiry());
        if (ipAddress != null) {
            session.setIpAddress(ipAddress);
        }
        authSessionRepository.save(session);

        String newAccessToken = jwtService.generateAccessToken(user, session.getId());
        return new AuthTokenResponse(
                false,
                null,
                newAccessToken,
                newRawRefreshToken,
                jwtService.getAccessTokenMinutes() * 60,
                buildUserSummary(user)
        );
    }

    @Transactional
    public void logout(AuthenticatedUser currentActor, LogoutRequest request) {
        Instant now = Instant.now();
        if (request != null && request.refreshToken() != null && !request.refreshToken().isBlank()) {
            String hash = jwtService.hashRefreshToken(request.refreshToken());
            authSessionRepository.findByRefreshTokenHash(hash).ifPresent(s -> {
                s.setRevokedAt(now);
                authSessionRepository.save(s);
            });
        }
        if (currentActor != null && currentActor.sessionId() != null) {
            authSessionRepository.findById(currentActor.sessionId()).ifPresent(s -> {
                s.setRevokedAt(now);
                authSessionRepository.save(s);
            });
        }
    }

    @Transactional(readOnly = true)
    public UserSummaryResponse getCurrentUserSummary(AuthenticatedUser currentActor) {
        if (currentActor == null) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }
        User user = userRepository.findById(currentActor.userId())
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND));
        return buildUserSummary(user);
    }

    public UserSummaryResponse buildUserSummary(User user) {
        String ownerAppStatus = null;
        String ownerRejectReason = null;
        if (user.hasRole(RoleCode.OWNER)) {
            Optional<OwnerApplication> latestApp = ownerApplicationRepository
                    .findFirstByUserIdOrderBySubmittedAtDesc(user.getId());
            if (latestApp.isPresent()) {
                ownerAppStatus = latestApp.get().getStatus();
                ownerRejectReason = latestApp.get().getRejectReason();
            }
        }
        return new UserSummaryResponse(
                user.getId(),
                user.getFirebaseUid(),
                user.getAuthProvider(),
                user.getFullName(),
                user.getEmail(),
                user.getPhone(),
                user.getAvatarUrl(),
                user.getStatus(),
                user.getRoleCodes(),
                user.getPermissionCodes(),
                ownerAppStatus,
                ownerRejectReason
        );
    }

    private AuthTokenResponse issueSessionAndTokens(User user, String deviceId, String ipAddress) {
        String rawRefreshToken = jwtService.generateRawRefreshToken();
        AuthSession session = AuthSession.builder()
                .userId(user.getId())
                .refreshTokenHash(jwtService.hashRefreshToken(rawRefreshToken))
                .deviceId(deviceId)
                .ipAddress(ipAddress)
                .expiresAt(jwtService.calculateRefreshTokenExpiry())
                .createdAt(Instant.now())
                .build();
        session = authSessionRepository.save(session);

        String accessToken = jwtService.generateAccessToken(user, session.getId());
        return new AuthTokenResponse(
                false,
                null,
                accessToken,
                rawRefreshToken,
                jwtService.getAccessTokenMinutes() * 60,
                buildUserSummary(user)
        );
    }

    private void revokeAllSessionsForUser(Long userId) {
        Instant now = Instant.now();
        List<AuthSession> activeSessions = authSessionRepository.findByUserIdAndRevokedAtIsNull(userId);
        for (AuthSession s : activeSessions) {
            s.setRevokedAt(now);
            authSessionRepository.save(s);
        }
    }

    private boolean isDeviceTrusted(Long userId, String deviceId) {
        if (deviceId == null || deviceId.isBlank()) {
            return false;
        }
        return trustedDeviceRepository.findByUserIdAndDeviceId(userId, deviceId.trim()).isPresent();
    }

    private void saveOrUpdateTrustedDevice(Long userId, String deviceId, String deviceName) {
        String cleanDeviceId = deviceId.trim();
        TrustedDevice device = trustedDeviceRepository.findByUserIdAndDeviceId(userId, cleanDeviceId)
                .orElseGet(() -> TrustedDevice.builder()
                        .userId(userId)
                        .deviceId(cleanDeviceId)
                        .build());
        if (deviceName != null && !deviceName.isBlank()) {
            device.setDeviceName(deviceName.trim());
        }
        device.setLastUsedAt(Instant.now());
        trustedDeviceRepository.save(device);
    }

    private void checkAccountNotLocked(User user) {
        if (user.getLockedUntil() != null && Instant.now().isBefore(user.getLockedUntil())) {
            throw new AppException(ErrorCode.ACCOUNT_LOCKED);
        }
        if ("DISABLED".equalsIgnoreCase(user.getStatus())) {
            throw new AppException(ErrorCode.ACCOUNT_DISABLED);
        }
    }

    private void validatePasswordStrength(String password) {
        if (password == null || !PASSWORD_POLICY.matcher(password).matches()) {
            throw new AppException(
                    ErrorCode.VALIDATION_ERROR,
                    "Mat khau phai tu 8 ky tu va chua it nhat 1 chu cai va 1 chu so",
                    List.of(new ApiResponse.FieldErrorDetail("password", "Phai tu 8 ky tu, gom chu va so"))
            );
        }
    }

    private Role getRoleOrThrow(RoleCode code) {
        return roleRepository.findByCodeIgnoreCase(code.name())
                .orElseThrow(() -> new AppException(ErrorCode.INTERNAL_SERVER_ERROR, "Role " + code + " chua duoc khoi tao"));
    }

    private String normalizeEmail(String email) {
        if (email == null) {
            return "";
        }
        return email.trim().toLowerCase(Locale.ROOT);
    }

    private void recordLoginLog(
            Long userId,
            String roleCode,
            String email,
            String deviceId,
            String ipAddress,
            boolean success,
            String reason
    ) {
        loginLogRepository.save(LoginLog.builder()
                .userId(userId)
                .roleCode(roleCode)
                .email(email)
                .deviceId(deviceId)
                .ipAddress(ipAddress)
                .success(success ? 1 : 0)
                .failureReason(reason)
                .createdAt(Instant.now())
                .build());
    }
}
