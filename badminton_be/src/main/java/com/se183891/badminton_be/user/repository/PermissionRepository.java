package com.se183891.badminton_be.user.repository;

import com.se183891.badminton_be.user.entity.Permission;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PermissionRepository extends JpaRepository<Permission, Long> {

    Optional<Permission> findByCodeIgnoreCase(String code);
}
