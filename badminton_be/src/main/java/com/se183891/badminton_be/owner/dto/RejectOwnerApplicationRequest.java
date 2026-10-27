package com.se183891.badminton_be.owner.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RejectOwnerApplicationRequest(
        @NotBlank(message = "Ly do tu choi khong duoc de trong")
        @Size(max = 500, message = "Ly do tu choi toi da 500 ky tu")
        String reason
) {
}
