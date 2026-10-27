package com.se183891.badminton_be.owner.controller;

import com.se183891.badminton_be.common.response.ApiResponse;
import com.se183891.badminton_be.common.security.AuthenticatedUser;
import com.se183891.badminton_be.common.security.CurrentActor;
import com.se183891.badminton_be.owner.dto.OwnerApplicationResponse;
import com.se183891.badminton_be.owner.service.OwnerOnboardingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/owner/applications")
@RequiredArgsConstructor
public class OwnerOnboardingController {

    private final OwnerOnboardingService ownerOnboardingService;

    @GetMapping("/latest")
    @PreAuthorize("hasRole('OWNER')")
    public ApiResponse<OwnerApplicationResponse> getLatestApplication(@CurrentActor AuthenticatedUser currentActor) {
        return ApiResponse.ok(ownerOnboardingService.getLatestApplicationForOwner(currentActor.userId()));
    }

    @PostMapping(value = "/resubmit", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('OWNER')")
    public ApiResponse<OwnerApplicationResponse> resubmitApplication(
            @CurrentActor AuthenticatedUser currentActor,
            @RequestParam("businessName") String businessName,
            @RequestParam(value = "taxCode", required = false) String taxCode,
            @RequestParam("address") String address,
            @RequestPart("licenseFile") MultipartFile licenseFile
    ) {
        OwnerApplicationResponse data = ownerOnboardingService.resubmitApplication(
                currentActor.userId(),
                businessName,
                taxCode,
                address,
                licenseFile
        );
        return ApiResponse.ok(data);
    }
}
