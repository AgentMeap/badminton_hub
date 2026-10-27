package com.se183891.badminton_be.user.repository;

import com.se183891.badminton_be.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmailIgnoreCase(String email);

    Optional<User> findByFirebaseUid(String firebaseUid);

    boolean existsByEmailIgnoreCase(String email);
}
