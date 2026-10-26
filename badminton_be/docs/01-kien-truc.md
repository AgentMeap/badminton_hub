# 01 – Kiến trúc Backend

## Cấu trúc package (theo tính năng)

Package gốc: `com.se183891.badminton_be`

```
badminton_be/
├── common/                 Dùng chung toàn hệ thống
│   ├── config/             SecurityConfig, OpenApiConfig, CorsConfig, JacksonConfig
│   ├── exception/          AppException, ErrorCode, GlobalExceptionHandler
│   ├── response/           ApiResponse<T>, PageResponse<T>
│   ├── security/           JwtService, JwtAuthFilter, CurrentActor
│   ├── storage/            StorageService (lưu ảnh)
│   └── util/
├── auth/                   Đăng ký, đăng nhập, OTP, refresh token (chủ đề 4)
├── customer/               Hồ sơ Customer
├── owner/                  Hồ sơ CourtOwner, OwnerApplication, BankAccount
├── admin/                  Hồ sơ Admin, quản lý tài khoản, dashboard
├── venue/                  Venue, Court, PriceRule, OperatingHour, CancellationRule, Amenity, VenueFaq (chủ đề 1, 2)
├── booking/                Booking, BookingSlot, RecurringGroup, CheckIn (chủ đề 1)
├── payment/                Payment, Invoice, Refund, Dispute, Promotion, Settlement, VNPay (chủ đề 3)
├── review/                 Review
├── notification/           Notification, Announcement, DeviceToken, FCM (chủ đề 5)
└── chat/                   ChatSession, ChatMessage, AiConfig, AI client (chủ đề 6)
```

Mỗi package tính năng có cấu trúc giống nhau:

```
venue/
├── controller/     CustomerVenueController, OwnerVenueController, AdminVenueController
├── service/        VenueService
├── repository/     VenueRepository (Spring Data JPA)
├── entity/         Venue, Court...
├── dto/            request/, response/
└── mapper/         VenueMapper (entity ↔ dto)
```

Tách controller theo role (Customer / Owner / Admin) để nhìn tên file là biết actor nào gọi API, khớp với ý đồ tách 3 actor.

## Nguyên tắc giữa các lớp

| Lớp | Được làm | Không được làm |
|---|---|---|
| Controller | Nhận request, validate DTO (`@Valid`), gọi service, trả `ApiResponse` | Chứa logic nghiệp vụ, gọi repository trực tiếp |
| Service | Logic nghiệp vụ, `@Transactional`, kiểm tra quyền sở hữu | Trả entity ra ngoài controller |
| Repository | Truy vấn DB | Logic nghiệp vụ |
| Entity | Ánh xạ bảng | Lộ ra API (luôn map sang DTO) |

## Xử lý lỗi tập trung

- Mọi lỗi nghiệp vụ ném `AppException(ErrorCode.XXX)`.
- `GlobalExceptionHandler` (`@RestControllerAdvice`) chuyển thành JSON lỗi chuẩn, xem [03-api-design.md](03-api-design.md#2-quy-ước-chung).
- `ErrorCode` là enum chứa mã lỗi, HTTP status và thông điệp tiếng Việt mặc định.

```java
public enum ErrorCode {
    SLOT_ALREADY_BOOKED(HttpStatus.CONFLICT, "Khung giờ vừa có người đặt"),
    OTP_INVALID(HttpStatus.BAD_REQUEST, "Mã OTP không đúng"),
    OTP_EXPIRED(HttpStatus.BAD_REQUEST, "Mã OTP đã hết hạn"),
    ACCOUNT_LOCKED(HttpStatus.FORBIDDEN, "Tài khoản đang bị khóa"),
    VENUE_NOT_OWNED(HttpStatus.FORBIDDEN, "Bạn không có quyền với cơ sở này");
    // ...
}
```

## Job định kỳ (`@Scheduled`)

| Job | Tần suất | Việc làm | Story |
|---|---|---|---|
| ExpireHoldJob | 1 phút | Hủy lượt `PENDING_PAYMENT` quá `holdExpiresAt`, giải phóng khung giờ | US-C13 |
| BookingReminderJob | 5 phút | Gửi nhắc lịch theo `reminderMinutes` của Customer | US-C22 |
| AutoRejectUnconfirmedJob | 10 phút | Lượt trả tại sân chủ sân chưa xác nhận sau 2 giờ → hủy | US-O09 |
| CompleteBookingJob | 15 phút | Quá giờ kết thúc: đã check-in → `COMPLETED`, chưa → `NO_SHOW` | Bổ sung G3 |
| EscalateRefundJob | 1 giờ | Yêu cầu hoàn tiền quá 48 giờ chưa xử lý → `ESCALATED` | US-O14 |
| ScheduledAnnouncementJob | 1 phút | Gửi thông báo hàng loạt đã hẹn giờ | US-A10 |

Bật bằng `@EnableScheduling`. Mỗi job phải idempotent (chạy lại không gây sai dữ liệu).
