package com.se183891.badminton_be.auth.repository;

import com.se183891.badminton_be.auth.entity.AccountActionLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AccountActionLogRepository extends JpaRepository<AccountActionLog, Long> {
}
