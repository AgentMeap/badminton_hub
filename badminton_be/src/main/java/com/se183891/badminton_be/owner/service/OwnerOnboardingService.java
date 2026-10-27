package com.se183891.badminton_be.owner.service;

import com.se183891.badminton_be.auth.entity.AccountActionLog;
import com.se183891.badminton_be.auth.repository.AccountActionLogRepository;
import com.se183891.badminton_be.common.exception.AppException;
import com.se183891.badminton_be.common.exception.ErrorCode;
import com.se183891.badminton_be.common.storage.StorageService;
import com.se183891.badminton_be.owner.dto.OwnerApplicationResponse;
import com.se183891.badminton_be.owner.entity.OwnerApplication;
import com.se183891.badminton_be.owner.repository.OwnerApplicationRepository;
import com.se183891.badminton_be.user.entity.User;
import com.se183891.badminton_be.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.Instant;
import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class OwnerOnboardingService {

    private final OwnerApplicationRepository ownerApplicationRepository;
    private final UserRepository userRepository;
    private final AccountActionLogRepository accountActionLogRepository;
    private final StorageService storageService;

    @Transactional(readOnly = true)
    public OwnerApplicationResponse getLatestApplicationForOwner(Long userId) {
        OwnerApplication app = ownerApplicationRepository.findFirstByUserIdOrderBySubmittedAtDesc(userId)
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND, "Chua co ho so dang ky chu san"));
        User owner = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND));
        return toDto(app, owner);
    }

    @Transactional
    public OwnerApplicationResponse resubmitApplication(
            Long userId,
            String businessName,
            String taxCode,
            String address,
            MultipartFile licenseFile
    ) {
        User owner = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND));

        String licenseUrl = storageService.storeFile(licenseFile, "licenses");

        OwnerApplication app = ownerApplicationRepository.findFirstByUserIdOrderBySubmittedAtDesc(userId)
                .orElseGet(() -> OwnerApplication.builder().userId(userId).build());
        app.setBusinessName(businessName.trim());
        app.setTaxCode(taxCode != null ? taxCode.trim() : null);
        app.setAddress(address.trim());
        app.setLicenseFileUrl(licenseUrl);
        app.setStatus("PENDING");
        app.setRejectReason(null);
        app.setReviewedByUserId(null);
        app.setReviewedAt(null);
        app.setSubmittedAt(Instant.now());

        OwnerApplication saved = ownerApplicationRepository.save(app);
        return toDto(saved, owner);
    }

    @Transactional(readOnly = true)
    public List<OwnerApplicationResponse> listApplicationsForAdmin(String status) {
        List<OwnerApplication> list;
        if (status == null || status.isBlank() || "ALL".equalsIgnoreCase(status)) {
            list = ownerApplicationRepository.findAll();
        } else {
            list = ownerApplicationRepository.findByStatusOrderBySubmittedAtDesc(status.trim().toUpperCase(Locale.ROOT));
        }
        return list.stream()
                .map(app -> {
                    User owner = userRepository.findById(app.getUserId()).orElse(null);
                    return toDto(app, owner);
                })
                .toList();
    }

    @Transactional
    public OwnerApplicationResponse approveApplication(Long applicationId, Long adminUserId) {
        OwnerApplication app = ownerApplicationRepository.findById(applicationId)
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND, "Khong tim thay ho so chu san"));
        User owner = userRepository.findById(app.getUserId())
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND));

        app.setStatus("APPROVED");
        app.setRejectReason(null);
        app.setReviewedByUserId(adminUserId);
        app.setReviewedAt(Instant.now());
        ownerApplicationRepository.save(app);

        owner.setStatus("ACTIVE");
        userRepository.save(owner);

        accountActionLogRepository.save(AccountActionLog.builder()
                .targetUserId(owner.getId())
                .performedByUserId(adminUserId)
                .actionType("APPROVE_OWNER_APPLICATION")
                .reason("Phe duyet ho so co so " + app.getBusinessName())
                .createdAt(Instant.now())
                .build());

        return toDto(app, owner);
    }

    @Transactional
    public OwnerApplicationResponse rejectApplication(Long applicationId, Long adminUserId, String reason) {
        OwnerApplication app = ownerApplicationRepository.findById(applicationId)
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND, "Khong tim thay ho so chu san"));
        User owner = userRepository.findById(app.getUserId())
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND));

        app.setStatus("REJECTED");
        app.setRejectReason(reason.trim());
        app.setReviewedByUserId(adminUserId);
        app.setReviewedAt(Instant.now());
        ownerApplicationRepository.save(app);

        accountActionLogRepository.save(AccountActionLog.builder()
                .targetUserId(owner.getId())
                .performedByUserId(adminUserId)
                .actionType("REJECT_OWNER_APPLICATION")
                .reason(reason.trim())
                .createdAt(Instant.now())
                .build());

        return toDto(app, owner);
    }

    private OwnerApplicationResponse toDto(OwnerApplication app, User owner) {
        return new OwnerApplicationResponse(
                app.getId(),
                app.getUserId(),
                owner != null ? owner.getFullName() : "",
                owner != null ? owner.getEmail() : "",
                owner != null ? owner.getPhone() : "",
                app.getBusinessName(),
                app.getTaxCode(),
                app.getAddress(),
                app.getLicenseFileUrl(),
                app.getStatus(),
                app.getRejectReason(),
                app.getReviewedByUserId(),
                app.getReviewedAt() != null ? app.getReviewedAt().toString() : null,
                app.getSubmittedAt() != null ? app.getSubmittedAt().toString() : null
        );
    }
}
