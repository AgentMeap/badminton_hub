package com.se183891.badminton_be.admin.controller;

import com.se183891.badminton_be.common.response.ApiResponse;
import com.se183891.badminton_be.common.security.AuthenticatedUser;
import com.se183891.badminton_be.common.security.CurrentActor;
import com.se183891.badminton_be.owner.dto.OwnerApplicationResponse;
import com.se183891.badminton_be.owner.dto.RejectOwnerApplicationRequest;
import com.se183891.badminton_be.owner.service.OwnerOnboardingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/owner-applications")
@RequiredArgsConstructor
public class AdminOwnerApprovalController {

    private final OwnerOnboardingService ownerOnboardingService;

    @GetMapping
    @PreAuthorize("hasAuthority('OWNER_APPLICATION_REVIEW')")
    public ApiResponse<List<OwnerApplicationResponse>> listApplications(
            @RequestParam(value = "status", required = false) String status
    ) {
        return ApiResponse.ok(ownerOnboardingService.listApplicationsForAdmin(status));
    }

    @PostMapping("/{id}/approve")
    @PreAuthorize("hasAuthority('OWNER_APPLICATION_REVIEW')")
    public ApiResponse<OwnerApplicationResponse> approveApplication(
            @PathVariable("id") Long id,
            @CurrentActor AuthenticatedUser currentActor
    ) {
        return ApiResponse.ok(ownerOnboardingService.approveApplication(id, currentActor.userId()));
    }

    @PostMapping("/{id}/reject")
    @PreAuthorize("hasAuthority('OWNER_APPLICATION_REVIEW')")
    public ApiResponse<OwnerApplicationResponse> rejectApplication(
            @PathVariable("id") Long id,
            @CurrentActor AuthenticatedUser currentActor,
            @Valid @RequestBody RejectOwnerApplicationRequest request
    ) {
        return ApiResponse.ok(ownerOnboardingService.rejectApplication(id, currentActor.userId(), request.reason()));
    }
}
