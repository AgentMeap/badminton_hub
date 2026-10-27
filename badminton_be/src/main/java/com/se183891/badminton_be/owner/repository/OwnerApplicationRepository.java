package com.se183891.badminton_be.owner.repository;

import com.se183891.badminton_be.owner.entity.OwnerApplication;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface OwnerApplicationRepository extends JpaRepository<OwnerApplication, Long> {

    Optional<OwnerApplication> findFirstByUserIdOrderBySubmittedAtDesc(Long userId);

    List<OwnerApplication> findByStatusOrderBySubmittedAtDesc(String status);
}
