package com.se183891.badminton_be.auth.controller;

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
import com.se183891.badminton_be.auth.service.AuthService;
import com.se183891.badminton_be.common.response.ApiResponse;
import com.se183891.badminton_be.common.security.AuthenticatedUser;
import com.se183891.badminton_be.common.security.CurrentActor;
import com.se183891.badminton_be.user.entity.RoleCode;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/customer/register")
    public ResponseEntity<ApiResponse<OtpChallengeResponse>> registerCustomer(
            @Valid @RequestBody CustomerRegisterRequest request
    ) {
        OtpChallengeResponse data = authService.registerCustomer(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(data));
    }

    @PostMapping("/customer/google")
    public ApiResponse<AuthTokenResponse> authenticateWithGoogle(
            @Valid @RequestBody GoogleAuthRequest request,
            HttpServletRequest servletRequest
    ) {
        AuthTokenResponse data = authService.authenticateWithGoogle(request, extractClientIp(servletRequest));
        return ApiResponse.ok(data);
    }

    @PostMapping(value = "/owner/register", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<OtpChallengeResponse>> registerOwner(
            @RequestParam("fullName") String fullName,
            @RequestParam("email") String email,
            @RequestParam("phone") String phone,
            @RequestParam("password") String password,
            @RequestParam("businessName") String businessName,
            @RequestParam(value = "taxCode", required = false) String taxCode,
            @RequestParam("address") String address,
            @RequestPart("licenseFile") MultipartFile licenseFile
    ) {
        OtpChallengeResponse data = authService.registerOwner(
                fullName,
                email,
                phone,
                password,
                businessName,
                taxCode,
                address,
                licenseFile
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(data));
    }

    @PostMapping("/{actor}/verify-email")
    public ApiResponse<AuthTokenResponse> verifyEmail(
            @PathVariable("actor") String actor,
            @Valid @RequestBody VerifyEmailOtpRequest request,
            HttpServletRequest servletRequest
    ) {
        RoleCode roleCode = RoleCode.fromPathSegment(actor);
        AuthTokenResponse data = authService.verifyEmailOtp(roleCode, request, extractClientIp(servletRequest));
        return ApiResponse.ok(data);
    }

    @PostMapping("/{actor}/otp/resend")
    public ApiResponse<OtpChallengeResponse> resendOtp(
            @PathVariable("actor") String actor,
            @Valid @RequestBody ResendOtpRequest request
    ) {
        RoleCode roleCode = RoleCode.fromPathSegment(actor);
        return ApiResponse.ok(authService.resendOtp(roleCode, request));
    }

    @PostMapping("/{actor}/login")
    public ApiResponse<Object> login(
            @PathVariable("actor") String actor,
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest servletRequest
    ) {
        RoleCode roleCode = RoleCode.fromPathSegment(actor);
        Object result = authService.login(roleCode, request, extractClientIp(servletRequest));
        return ApiResponse.ok(result);
    }

    @PostMapping("/{actor}/login/verify-otp")
    public ApiResponse<AuthTokenResponse> verifyLoginOtp(
            @PathVariable("actor") String actor,
            @Valid @RequestBody LoginVerifyOtpRequest request,
            HttpServletRequest servletRequest
    ) {
        RoleCode roleCode = RoleCode.fromPathSegment(actor);
        AuthTokenResponse data = authService.verifyLoginOtp(roleCode, request, extractClientIp(servletRequest));
        return ApiResponse.ok(data);
    }

    @PostMapping("/{actor}/forgot-password")
    public ApiResponse<OtpChallengeResponse> forgotPassword(
            @PathVariable("actor") String actor,
            @Valid @RequestBody ForgotPasswordRequest request
    ) {
        RoleCode roleCode = RoleCode.fromPathSegment(actor);
        return ApiResponse.ok(authService.forgotPassword(roleCode, request));
    }

    @PostMapping("/{actor}/reset-password")
    public ApiResponse<Map<String, String>> resetPassword(
            @PathVariable("actor") String actor,
            @Valid @RequestBody ResetPasswordRequest request
    ) {
        RoleCode roleCode = RoleCode.fromPathSegment(actor);
        authService.resetPassword(roleCode, request);
        return ApiResponse.ok(Map.of("message", "Dat lai mat khau thanh cong. Vui long dang nhap lai"));
    }

    @PostMapping("/refresh")
    public ApiResponse<AuthTokenResponse> refresh(
            @Valid @RequestBody RefreshTokenRequest request,
            HttpServletRequest servletRequest
    ) {
        AuthTokenResponse data = authService.refreshToken(request, extractClientIp(servletRequest));
        return ApiResponse.ok(data);
    }

    @PostMapping("/logout")
    public ApiResponse<Map<String, String>> logout(
            @CurrentActor AuthenticatedUser currentActor,
            @RequestBody(required = false) LogoutRequest request
    ) {
        authService.logout(currentActor, request);
        return ApiResponse.ok(Map.of("message", "Dang xuat thanh cong"));
    }

    @GetMapping("/me")
    public ApiResponse<UserSummaryResponse> getCurrentUser(@CurrentActor AuthenticatedUser currentActor) {
        return ApiResponse.ok(authService.getCurrentUserSummary(currentActor));
    }

    private String extractClientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
