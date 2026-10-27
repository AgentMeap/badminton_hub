package com.se183891.badminton_be;

import com.se183891.badminton_be.user.entity.RoleCode;
import com.se183891.badminton_be.user.entity.User;
import com.se183891.badminton_be.user.repository.RoleRepository;
import com.se183891.badminton_be.user.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
class BadmintonBeApplicationTests {

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private UserRepository userRepository;

    @Test
    void contextLoadsAndRbacRolesAndUsersAreSeeded() {
        assertEquals(3, roleRepository.count());

        User admin = userRepository.findByEmailIgnoreCase("admin@badminton.vn").orElseThrow();
        assertTrue(admin.hasRole(RoleCode.ADMIN));
        assertTrue(admin.getPermissionCodes().contains("OWNER_APPLICATION_REVIEW"));

        User customer = userRepository.findByEmailIgnoreCase("customer@badminton.vn").orElseThrow();
        assertTrue(customer.hasRole(RoleCode.CUSTOMER));
        assertTrue(customer.getPermissionCodes().contains("BOOKING_CREATE"));

        User owner = userRepository.findByEmailIgnoreCase("owner@badminton.vn").orElseThrow();
        assertTrue(owner.hasRole(RoleCode.OWNER));
        assertTrue(owner.getPermissionCodes().contains("VENUE_MANAGE_OWN"));
    }
}
