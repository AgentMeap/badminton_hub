package com.se183891.badminton_be.user.repository;

import com.se183891.badminton_be.user.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoleRepository extends JpaRepository<Role, Long> {

    Optional<Role> findByCodeIgnoreCase(String code);
}
