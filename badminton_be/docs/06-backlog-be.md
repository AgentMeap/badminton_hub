# 06 - Backlog Backend

Chủ đề: **NT** nền tảng chung - **DB** Database - **MAP** Map - **PAY** Payment (PayOS) - **SEC** Bảo mật (RBAC + OTP SMTP + Firebase Auth) - **NOTI** Notifications - **AI** Chat AI

## Sprint 0 - Nền tảng

| Done | ID | Task | Chủ đề | Phụ thuộc |
|---|---|---|---|---|
| [x] | BE-01 | Cấu hình SQLite (`WAL mode` + `foreign_keys=on`), Hibernate `SQLiteDialect`, Flyway, file mẫu `application-local.example.properties` | NT | D1 |
| [x] | BE-02 | Package `common`: `ApiResponse`, `PageResponse`, `ErrorCode`, `AppException`, `GlobalExceptionHandler` | NT | |
| [x] | BE-03 | Cấu hình `OpenApiConfig` (Swagger có nút Authorize Bearer), `WebMvcConfig` (CORS), `InstantStringConverter` | NT | |
| [x] | BE-04 | `GET /api/v1/health` và `TraceIdFilter` gắn `X-Trace-Id` vào log & response | NT | |
| [x] | BE-05 | `StorageService` & `LocalStorageService` lưu file vào `uploads/`, phục vụ qua `/files/**` | NT | D3 |
| [ ] | BE-06 | Postman collection + environment dùng chung | NT | |

## Sprint 1 - Tài khoản RBAC, Firebase Auth & Tạo sân

| Done | ID | Task | Chủ đề | Story |
|---|---|---|---|---|
| [x] | BE-10 | Migration `V1` & `V2`: Mô hình RBAC (`role`, `permission`, `role_permission`, `users`, `user_role`), bảng bảo mật (`otp_code`, `trusted_device`, `auth_session`, `login_log`, `account_action_log`), `owner_application`, `bank_account` + `DemoAccountSeeder` | SEC | G2 |
| [x] | BE-11 | `JwtService`, `JwtAuthFilter`, `SecurityConfig` theo RBAC (`Role` + `Permission`), `@CurrentActor AuthenticatedUser` | SEC | C03 |
| [x] | BE-12 | `OtpService` + `SecretCipherService` (AES-256-GCM): tạo OTP 6 số, băm BCrypt, kiểm tra hết hạn, giới hạn sai 3 lần, cooldown 60s, tối đa 5 OTP/giờ | SEC | C02, C04 |
| [x] | BE-13 | `MailSenderService` gửi OTP qua SMTP Gmail + in khung OTP ra Console khi dev | SEC | C02 |
| [x] | BE-14 | Đăng ký Customer (2 loại: Google Firebase `/auth/customer/google` và Đăng ký thường `/auth/customer/register` -> xác thực OTP SMTP `/verify-email` -> tạo user trên Firebase Authentication) | SEC | C01, C02, C03 |
| [x] | BE-15 | Đăng nhập RBAC (`/auth/{actor}/login`) + khóa 15 phút khi sai 5 lần + OTP thiết bị lạ (`/login/verify-otp`) + `/auth/refresh` + `/auth/logout` + `/auth/me` | SEC | C03, C04, O02, A01 |
| [x] | BE-16 | Quên / đặt lại mật khẩu (`/forgot-password`, `/reset-password`) đồng bộ lên Firebase Authentication & thu hồi toàn bộ `auth_session` cũ | SEC | C05 |
| [x] | BE-17 | Đăng ký chủ sân (`/auth/owner/register` kèm upload giấy phép), xem trạng thái (`/owner/applications/latest`), Admin duyệt/từ chối hồ sơ (`/admin/owner-applications/**`) | SEC | O01, A02 |
| [ ] | BE-18 | Migration V3 module Sân + seed dữ liệu sân mẫu cho SQLite | DB | |
| [ ] | BE-19 | CRUD venue, ảnh, tiện ích, sân con của Owner (kiểm tra sở hữu) | DB | O03, O05 |
| [ ] | BE-20 | Bảng giá (kiểm tra chồng lấn), giờ mở cửa | DB | O06, O07 |
| [ ] | BE-21 | `/public/geocode` gọi Google Geocoding | MAP | O04 |

## Sprint 2 - Tìm sân & giữ chỗ

| Done | ID | Task | Chủ đề | Story |
|---|---|---|---|---|
| [ ] | BE-30 | `/public/venues`: lọc + Haversine + sắp xếp + phân trang | MAP | C08, C09 |
| [ ] | BE-31 | `/public/venues/{id}` chi tiết sân | DB | C10 |
| [ ] | BE-32 | `/public/venues/{id}/availability` lưới lịch trống | DB | C12 |
| [ ] | BE-33 | Migration V4 booking; Partial Unique Index SQLite chống đặt trùng | DB | N2 |
| [ ] | BE-34 | `POST /customer/bookings`: tính giá theo `PriceRule`, giữ chỗ 10 phút, bắt lỗi trùng -> 409 | DB | C13 |
| [ ] | BE-35 | Integration test: 2 request đặt cùng khung giờ, chỉ 1 thành công | DB | T2 |
| [ ] | BE-36 | `ExpireHoldJob` giải phóng ghế giữ chỗ quá 10 phút | DB | C13 |
| [ ] | BE-37 | Admin duyệt / yêu cầu sửa / tạm ngưng venue | MAP | A05 |

## Sprint 3 - Thanh toán PayOS VietQR & lịch sử

| Done | ID | Task | Chủ đề | Story |
|---|---|---|---|---|
| [ ] | BE-40 | Migration V5 payment; seed `payment_gateway` PayOS | PAY | |
| [ ] | BE-41 | `PayosClient`: tạo link VietQR, ký & kiểm tra chữ ký HMAC-SHA256 | PAY | C17 |
| [ ] | BE-42 | Tạo payment FULL / DEPOSIT, trả dữ liệu VietQR + `checkoutUrl` | PAY | C17, C18 |
| [ ] | BE-43 | Webhook PayOS idempotent: cập nhật Payment + Booking `CONFIRMED` | PAY | C17 |
| [ ] | BE-44 | Hóa đơn + gửi email hóa đơn | PAY | C19 |
| [ ] | BE-45 | Lịch sử đặt sân theo tab, chi tiết + `qrToken` ký HMAC | DB | C15 |

## Sprint 4 - Thông báo, check-in, Chat AI

| Done | ID | Task | Chủ đề | Story |
|---|---|---|---|---|
| [ ] | BE-50 | Migration V6; `PushSender` FCM; device token API | NOTI | C21 |
| [ ] | BE-51 | `NotificationService`: lưu + push khi đặt thành công/hủy, gửi cho cả Owner | NOTI | C21, O16 |
| [ ] | BE-52 | API danh sách, unread-count, đánh dấu đã đọc | NOTI | C23 |
| [ ] | BE-53 | Cài đặt nhắc lịch + `BookingReminderJob` | NOTI | C22 |
| [ ] | BE-54 | `POST /owner/check-ins` kiểm tra QR; `CompleteBookingJob` | DB | O11, G3 |
| [ ] | BE-55 | Timeline đặt sân cho Owner | DB | O08 |
| [ ] | BE-56 | Migration V7; `AiClient` + function calling `search_venues`, `get_venue_policy` | AI | C24, C25 |
| [ ] | BE-57 | API phiên chat, gửi/nhận tin, giới hạn tin nhắn/ngày | AI | C24 |
