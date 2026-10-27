package com.se183891.badminton_be.auth.repository;

import com.se183891.badminton_be.auth.entity.OtpCode;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface OtpCodeRepository extends JpaRepository<OtpCode, Long> {

    Optional<OtpCode> findByTicket(String ticket);

    List<OtpCode> findByUserIdOrderByCreatedAtDesc(Long userId);
}
