package com.se183891.badminton_be.auth.repository;

import com.se183891.badminton_be.auth.entity.TrustedDevice;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TrustedDeviceRepository extends JpaRepository<TrustedDevice, Long> {

    Optional<TrustedDevice> findByUserIdAndDeviceId(Long userId, String deviceId);
}
