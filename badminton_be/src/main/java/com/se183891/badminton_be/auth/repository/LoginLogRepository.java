package com.se183891.badminton_be.auth.repository;

import com.se183891.badminton_be.auth.entity.LoginLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LoginLogRepository extends JpaRepository<LoginLog, Long> {
}
