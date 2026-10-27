# 03 - Thiết kế API

Hợp đồng API chính thức được sinh tự động qua Swagger (`/swagger-ui.html`). Khi thêm hoặc sửa endpoint, cập nhật đồng bộ tài liệu này.

## 1. Phân vùng URL theo RBAC (`Role` & `Permission`)

| Tiền tố | Quyền truy cập | Ví dụ |
|---|---|---|
| `/api/v1/health/**` | Công khai | Kiểm tra trạng thái server & SQLite |
| `/api/v1/auth/**` | Công khai (trừ `/auth/me`) | Đăng ký (thường + Google Firebase), đăng nhập RBAC, xác thực OTP SMTP, quên mật khẩu, làm mới token |
| `/api/v1/public/**` | Công khai (không cần đăng nhập) | Tìm kiếm sân, xem chi tiết sân, lịch trống |
| `/api/v1/customer/**` | JWT có role `CUSTOMER` | Đặt sân, thanh toán PayOS VietQR, lịch sử đặt sân, Chat AI |
| `/api/v1/owner/**` | JWT có role `OWNER` | Hồ sơ chủ sân, quản lý cơ sở sân, bảng giá, timeline vận hành, quét QR check-in |
| `/api/v1/admin/**` | JWT có role `ADMIN` (+ `@PreAuthorize` theo permission) | Duyệt hồ sơ chủ sân (`OWNER_APPLICATION_REVIEW`), kiểm duyệt sân (`VENUE_APPROVE`), quản lý khóa tài khoản |
| `/api/v1/webhooks/**` | Bên thứ ba (kiểm tra chữ ký HMAC-SHA256) | Webhook PayOS VietQR |

Ngoài kiểm tra role/permission ở tầng Spring Security, tầng Service luôn kiểm tra **quyền sở hữu**: Owner chỉ thao tác trên venue thuộc `userId` của mình, Customer chỉ xem/hủy booking của chính mình.

## 2. Quy ước chung

### Response thành công (`ApiResponse<T>`)

```json
{
  "success": true,
  "data": { },
  "error": null,
  "meta": {
    "timestamp": "2026-10-27T14:20:00Z",
    "traceId": "8f2a9c1b4d3e"
  }
}
```

### Response lỗi (`ApiResponse<Void>`)

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "AUTH_INVALID_CREDENTIALS",
    "message": "Email hoac mat khau khong dung (con 4 lan thu)",
    "details": []
  },
  "meta": {
    "timestamp": "2026-10-27T14:20:05Z",
    "traceId": "9a1c3e5f7b2d"
  }
}
```

### Bảng mã lỗi chính (`ErrorCode`)

| Code | HTTP Status | Ý nghĩa |
|---|---|---|
| `VALIDATION_ERROR` | 400 | Dữ liệu đầu vào không hợp lệ, chi tiết từng trường trong `error.details` |
| `EMAIL_ALREADY_EXISTS` | 409 | Email đã được đăng ký |
| `EMAIL_REGISTERED_WITH_GOOGLE` | 409 | Email đã đăng ký qua Google Firebase, hướng dẫn đăng nhập bằng Google hoặc dùng Quên mật khẩu |
| `AUTH_INVALID_CREDENTIALS` | 401 | Sai email, mật khẩu hoặc vai trò đăng nhập |
| `AUTH_EMAIL_NOT_VERIFIED` | 403 | Tài khoản chưa hoàn tất bước xác thực mã OTP email |
| `ACCOUNT_LOCKED` | 403 | Tài khoản đang bị khóa tạm thời (15 phút sau 5 lần sai mật khẩu, hoặc 30 phút khi Admin sai OTP 3 lần) |
| `OTP_INVALID` / `OTP_EXPIRED` / `OTP_MAX_ATTEMPTS` | 400 | Mã OTP sai, hết hạn hoặc đã nhập sai quá 3 lần |
| `OTP_COOLDOWN` / `OTP_HOURLY_LIMIT` | 429 | Gửi lại OTP trước 60 giây hoặc vượt quá 5 mã OTP trong 1 giờ |
| `FIREBASE_TOKEN_INVALID` / `FIREBASE_SYNC_FAILED` | 401 / 502 | Firebase ID Token không hợp lệ hoặc lỗi đồng bộ Firebase Authentication |
| `TOKEN_EXPIRED` / `REFRESH_TOKEN_INVALID` | 401 | Access token hết hạn hoặc Refresh token đã bị thu hồi |
| `SLOT_ALREADY_BOOKED` / `HOLD_EXPIRED` | 409 | Khung giờ vừa có người đặt hoặc hết 10 phút giữ chỗ |

## 3. Danh sách Endpoint

### 3.1 Auth, RBAC & Onboarding Chủ sân (Đã hoàn thành)

Tham số `{actor}` nhận một trong `customer`, `owner`, `admin` (ánh xạ sang `RoleCode`).

| Method | Endpoint | Mô tả | Story | Trạng thái |
|---|---|---|---|---|
| POST | `/api/v1/auth/customer/register` | **Loại 2 (Đăng ký thường)**: Lưu `User(PENDING_VERIFICATION)`, gửi mã OTP 6 số qua SMTP | C01, C02 | Đã hoàn thành |
| POST | `/api/v1/auth/customer/google` | **Loại 1 (Đăng ký/Đăng nhập Google)**: Xác thực Firebase `idToken`, lưu/đồng bộ `users.firebase_uid`, cấp JWT + Refresh Token | C03 | Đã hoàn thành |
| POST | `/api/v1/auth/owner/register` | Đăng ký chủ sân (`multipart/form-data`, kèm file giấy phép `<= 5MB`), lưu `owner_application(PENDING)`, gửi OTP qua SMTP | O01 | Đã hoàn thành |
| POST | `/api/v1/auth/{actor}/verify-email` | Kiểm tra mã OTP 6 số; khi chính xác -> **tạo tài khoản trên Firebase Authentication (`emailVerified=true`)**, lưu `firebase_uid` vào SQLite, chuyển `ACTIVE` và cấp JWT + Refresh Token | C02, O01 | Đã hoàn thành |
| POST | `/api/v1/auth/{actor}/otp/resend` | Gửi lại mã OTP (kiểm tra cooldown 60 giây và giới hạn 5 mã/giờ) | C02 | Đã hoàn thành |
| POST | `/api/v1/auth/{actor}/login` | Đăng nhập RBAC. Kiểm tra khóa tạm 15 phút (khi sai 5 lần). Nếu `deviceId` đã có trong `trusted_device` -> trả cặp token ngay; nếu thiết bị mới -> gửi OTP `LOGIN` qua SMTP và trả `{ otpRequired: true, otpTicket }` | C03, C04, O02, A01 | Đã hoàn thành |
| POST | `/api/v1/auth/{actor}/login/verify-otp` | Xác thực `otpTicket` + mã OTP 6 số, lưu `trusted_device` (nếu chọn) và trả cặp token | C04, O02, A01 | Đã hoàn thành |
| POST | `/api/v1/auth/{actor}/forgot-password` | Gửi mã OTP `RESET_PASSWORD` (5 phút) qua SMTP | C05 | Đã hoàn thành |
| POST | `/api/v1/auth/{actor}/reset-password` | Xác thực OTP, cập nhật mật khẩu mới trong SQLite, **đồng bộ mật khẩu lên Firebase Authentication** và thu hồi toàn bộ `auth_session` cũ | C05 | Đã hoàn thành |
| POST | `/api/v1/auth/refresh` | Đổi `refreshToken` lấy `accessToken` mới (kèm xoay vòng `refreshToken`) | C03 | Đã hoàn thành |
| POST | `/api/v1/auth/logout` | Thu hồi phiên đăng nhập hiện tại (`revoked_at = NOW()`) | C03 | Đã hoàn thành |
| GET | `/api/v1/auth/me` | Lấy thông tin hồ sơ RBAC (`roles`, `permissions`, `firebaseUid`, `ownerApplicationStatus`) | C06 | Đã hoàn thành |
| GET | `/api/v1/owner/applications/latest` | Chủ sân xem trạng thái duyệt hồ sơ mới nhất (`PENDING`, `APPROVED`, `REJECTED`) trên màn hình `O-02` | O01 | Đã hoàn thành |
| POST | `/api/v1/owner/applications/resubmit` | Chủ sân nộp lại hồ sơ & giấy phép khi bị từ chối | O01 | Đã hoàn thành |
| GET | `/api/v1/admin/owner-applications` | Admin xem danh sách hồ sơ đăng ký chủ sân theo trạng thái (`A-02`) | A02 | Đã hoàn thành |
| POST | `/api/v1/admin/owner-applications/{id}/approve` | Admin phê duyệt hồ sơ chủ sân | A02 | Đã hoàn thành |
| POST | `/api/v1/admin/owner-applications/{id}/reject` | Admin từ chối hồ sơ chủ sân (bắt buộc nhập lý do) | A02 | Đã hoàn thành |

### 3.2 Xem sân công khai (Chủ đề 1, 2)

| Method | Endpoint | Mô tả | Story | Ưu tiên |
|---|---|---|---|---|
| GET | `/api/v1/public/venues` | Tìm sân. Query: `lat`, `lng`, `radiusKm`, `keyword`, `district`, `minPrice`, `maxPrice`, `date`, `startTime`, `amenityIds`, `sort=distance\|price\|rating` | C08, C09 | MVP |
| GET | `/api/v1/public/venues/{id}` | Chi tiết sân: ảnh, giá, tiện ích, giờ mở cửa, chính sách hủy, rating | C10 | MVP |
| GET | `/api/v1/public/venues/{id}/availability?date=` | Lưới lịch: từng sân con x khung giờ, trạng thái `AVAILABLE/BOOKED/MAINTENANCE/PAST` | C12 | MVP |
| GET | `/api/v1/public/venues/{id}/reviews` | Danh sách đánh giá (phân trang) | C10 | GĐ2 |
| GET | `/api/v1/public/amenities` | Danh mục tiện ích cho bộ lọc | C09 | MVP |

### 3.3 Đặt sân - Customer (Chủ đề 1)

| Method | Endpoint | Mô tả | Story | Ưu tiên |
|---|---|---|---|---|
| POST | `/api/v1/customer/bookings` | Giữ chỗ 10 phút: `courtId`, `date`, `startTime`, `endTime`, `promotionCode?`, `paymentOption=FULL\|DEPOSIT`. Trả booking + `holdExpiresAt` | C13, C18 | MVP |
| GET | `/api/v1/customer/bookings?tab=upcoming\|past\|cancelled` | Lịch sử đặt sân | C15 | MVP |
| GET | `/api/v1/customer/bookings/{id}` | Chi tiết + `qrToken` check-in | C15 | MVP |
| POST | `/api/v1/customer/bookings/{id}/cancel` | Hủy lượt đặt | C16 | GĐ2 |
| POST | `/api/v1/customer/promotions/validate` | Kiểm tra mã giảm giá | C20 | MVP |

### 3.4 Thanh toán PayOS VietQR (Chủ đề 3)

| Method | Endpoint | Mô tả | Story | Ưu tiên |
|---|---|---|---|---|
| POST | `/api/v1/customer/bookings/{id}/payments` | Tạo link thanh toán PayOS (`gateway=PAYOS`, `type=FULL\|DEPOSIT`). Trả `checkoutUrl`, `qrCode`, `bin`, `accountNumber`, `accountName`, `amount`, `description`, `orderCode` | C17, C18 | MVP |
| POST | `/api/v1/webhooks/payos` | PayOS gọi Webhook báo kết quả chuyển khoản VietQR; kiểm tra chữ ký `HMAC-SHA256`, cập nhật `Payment` + `Booking(CONFIRMED)` idempotent | C17 | MVP |
| GET | `/api/v1/customer/payments/{id}` | Kiểm tra trạng thái giao dịch PayOS (`PENDING`, `PAID`, `CANCELLED`) | C17 | MVP |
| GET | `/api/v1/customer/payments/{id}/invoice` | Xem hóa đơn điện tử | C19 | MVP |

### 3.5 Notifications & Chat AI (Chủ đề 5, 6)

| Method | Endpoint | Mô tả | Story | Ưu tiên |
|---|---|---|---|---|
| POST | `/api/v1/{actor}/device-tokens` | Đăng ký FCM token khi đăng nhập | C21 | MVP |
| GET | `/api/v1/{actor}/notifications` | Danh sách thông báo (phân trang) | C23 | MVP |
| GET | `/api/v1/{actor}/notifications/unread-count` | Số thông báo chưa đọc | C23 | MVP |
| PATCH | `/api/v1/{actor}/notifications/{id}/read` | Đánh dấu đã đọc | C23 | MVP |
| GET / PUT | `/api/v1/customer/notification-settings` | Cài đặt nhắc lịch trước giờ chơi (`30/60/120` phút) | C22 | MVP |
| POST | `/api/v1/customer/chat/sessions` | Tạo phiên trò chuyện AI | C24 | MVP |
| POST | `/api/v1/customer/chat/sessions/{id}/messages` | Gửi câu hỏi cho trợ lý AI (kèm danh sách thẻ sân gợi ý) | C24, C25 | MVP |
