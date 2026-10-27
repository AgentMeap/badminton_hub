package com.se183891.badminton_be.common.security;

import com.se183891.badminton_be.user.entity.RoleCode;

import java.util.Set;

public record AuthenticatedUser(
        Long userId,
        String email,
        Long sessionId,
        Set<String> roles,
        Set<String> permissions
) {
    public boolean hasRole(RoleCode roleCode) {
        if (roles == null || roleCode == null) {
            return false;
        }
        return roles.stream().anyMatch(r -> roleCode.name().equalsIgnoreCase(r));
    }

    public boolean hasPermission(String permissionCode) {
        if (permissions == null || permissionCode == null) {
            return false;
        }
        return permissions.stream().anyMatch(p -> permissionCode.equalsIgnoreCase(p));
    }
}
