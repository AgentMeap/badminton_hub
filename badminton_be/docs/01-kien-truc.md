# 01 - Kiến trúc Backend

## Cấu trúc package (theo tính năng & RBAC)

Package gốc: `com.se183891.badminton_be`

```
badminton_be/
├── common/                 Dùng chung toàn hệ thống
│   ├── config/             WebMvcConfig, OpenApiConfig, PasswordEncoderConfig, InstantStringConverter, DemoAccountSeeder, TraceIdFilter, HealthController
│   ├── exception/          AppException, ErrorCode, GlobalExceptionHandler
│   ├── response/           ApiResponse<T>, PageResponse<T>
│   ├── security/           AuthenticatedUser, CurrentActor, JwtService, JwtAuthFilter, SecurityConfig, SecretCipherService
│   ├── storage/            StorageService, LocalStorageService (lưu file vào uploads/)
│   └── util/               TraceIdHolder
├── user/                   Mô hình RBAC: User, Role, Permission, RoleCode + Repositories
├── auth/                   Đăng ký (thường + Google Firebase), đăng nhập RBAC, OTP SMTP, FirebaseAuthService, refresh token
├── customer/               Hồ sơ mở rộng và tiện ích của Customer
├── owner/                  OwnerApplication, BankAccount, OwnerOnboardingService, OwnerOnboardingController
├── admin/                  AdminOwnerApprovalController, quản lý tài khoản, kiểm duyệt sân, dashboard
├── venue/                  Venue, Court, PriceRule, OperatingHour, CancellationRule, Amenity, VenueFaq (chủ đề 1, 2)
├── booking/                Booking, BookingSlot, RecurringGroup, CheckIn (chủ đề 1)
├── payment/                Payment, Invoice, Refund, Dispute, Promotion, Settlement, PayOS VietQR (chủ đề 3)
├── review/                 Review
├── notification/           Notification, Announcement, DeviceToken, FCM (chủ đề 5)
└── chat/                   ChatSession, ChatMessage, AiConfig, AI client (chủ đề 6)
```

Mỗi package tính năng có cấu trúc thống nhất:

```
venue/
├── controller/     CustomerVenueController, OwnerVenueController, AdminVenueController
├── service/        VenueService
├── repository/     VenueRepository (Spring Data JPA)
├── entity/         Venue, Court...
├── dto/            request/, response/
└── mapper/         VenueMapper (entity <-> dto)
```

## Nguyên tắc giữa các lớp

| Lớp | Được làm | Không được làm |
|---|---|---|
| Controller | Nhận request, validate DTO (`@Valid`), lấy `@CurrentActor AuthenticatedUser`, gọi service, trả `ApiResponse` | Chứa logic nghiệp vụ, gọi repository trực tiếp |
| Service | Logic nghiệp vụ, `@Transactional`, kiểm tra quyền sở hữu và quyền RBAC | Trả entity trực tiếp ra ngoài controller |
| Repository | Truy vấn DB (SQLite thông qua Spring Data JPA) | Logic nghiệp vụ |
| Entity | Ánh xạ bảng SQLite (với `InstantStringConverter` cho kiểu thời gian UTC) | Lộ trực tiếp ra API |

## Xử lý lỗi tập trung

- Mọi lỗi nghiệp vụ ném `AppException(ErrorCode.XXX)`.
- `GlobalExceptionHandler` (`@RestControllerAdvice`) chuyển thành JSON lỗi chuẩn `ApiResponse.fail(...)`, xem [03-api-design.md](file:///d:/badminton/badminton_be/docs/03-api-design.md).
- `ErrorCode` là enum chứa mã lỗi, HTTP status và thông điệp mặc định.

## Job định kỳ (`@Scheduled`)

| Job | Tần suất | Việc làm | Story |
|---|---|---|---|
| ExpireHoldJob | 1 phút | Hủy lượt `PENDING_PAYMENT` quá `holdExpiresAt`, giải phóng khung giờ | US-C13 |
| BookingReminderJob | 5 phút | Gửi nhắc lịch theo `reminderMinutes` của Customer | US-C22 |
| AutoRejectUnconfirmedJob | 10 phút | Lượt trả tại sân chủ sân chưa xác nhận sau 2 giờ -> hủy | US-O09 |
| CompleteBookingJob | 15 phút | Quá giờ kết thúc: đã check-in -> `COMPLETED`, chưa -> `NO_SHOW` | Bổ sung G3 |
| EscalateRefundJob | 1 giờ | Yêu cầu hoàn tiền quá 48 giờ chưa xử lý -> `ESCALATED` | US-O14 |
| ScheduledAnnouncementJob | 1 phút | Gửi thông báo hàng loạt đã hẹn giờ | US-A10 |

Bật bằng `@EnableScheduling`. Mỗi job phải idempotent (chạy lại không gây sai dữ liệu).
