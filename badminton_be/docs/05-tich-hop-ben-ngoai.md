# 05 - Tích hợp dịch vụ bên ngoài

Mọi khóa API và thông tin nhạy cảm đặt trong `application-local.properties` hoặc biến môi trường, **không commit lên Git**. Mỗi dịch vụ đều có chế độ fallback/dev-log để chạy kiểm thử local ngay cả khi chưa cấu hình khóa thật.

## 1. PayOS - Cổng thanh toán VietQR (Chủ đề 3)

| Bước | Thành phần | Chi tiết xử lý |
|---|---|---|
| 1 | Cấu hình PayOS | Khai báo `app.payos.client-id`, `app.payos.api-key`, `app.payos.checksum-key` từ PayOS Dashboard |
| 2 | Tạo link & mã VietQR | App gọi `POST /api/v1/customer/bookings/{id}/payments`; Backend tạo đơn thanh toán PayOS (`orderCode`, `amount`, `description`), ký dữ liệu bằng `HMAC-SHA256` và trả về mã VietQR động cùng thông tin tài khoản nhận |
| 3 | Quét mã / Chuyển khoản 24/7 | Người dùng mở ứng dụng ngân hàng quét mã VietQR hoặc sao chép số tài khoản + nội dung chuyển khoản trên màn hình `C-08` |
| 4 | Webhook đối soát tự động | PayOS gọi `POST /api/v1/webhooks/payos` ngay khi nhận tiền; Backend xác thực chữ ký `checksum`, cập nhật `Payment(PAID)` và `Booking(CONFIRMED)` trong một transaction idempotent |

## 2. Firebase Authentication & Firebase Cloud Messaging (Chủ đề 4, 5)

- Tạo Firebase Project trên Firebase Console, bật **Authentication** (Sign-in providers: **Email/Password** và **Google**) và **Cloud Messaging**.
- Tải file JSON Service Account đặt ngoài thư mục mã nguồn và trỏ đường dẫn vào `app.firebase.service-account-path` trong `application-local.properties`.
- [FirebaseAuthService.java](file:///d:/badminton/badminton_be/src/main/java/com/se183891/badminton_be/auth/service/FirebaseAuthService.java) đảm nhiệm 3 tác vụ:
  1. `verifyGoogleIdToken(idToken)`: Xácминh Google ID Token khi người dùng đăng ký/đăng nhập qua Google (`POST /api/v1/auth/customer/google`).
  2. `createVerifiedUserInFirebase(email, plainPassword, fullName)`: Tạo tài khoản chính thức trên Firebase Authentication (`emailVerified = true`) ngay sau khi người dùng nhập đúng mã OTP 6 số gửi qua SMTP (`POST /api/v1/auth/{actor}/verify-email`).
  3. `updatePasswordInFirebase(firebaseUid, email, newPassword)`: Đồng bộ mật khẩu khi người dùng đặt lại mật khẩu (`POST /api/v1/auth/{actor}/reset-password`).

## 3. SMTP Gmail gửi OTP (Chủ đề 4)

- Bật xác minh 2 bước cho tài khoản Gmail gửi thư và tạo **App Password** (16 ký tự).
- Cấu hình trong `application-local.properties`:
  ```properties
  spring.mail.host=smtp.gmail.com
  spring.mail.port=587
  spring.mail.username=your-email@gmail.com
  spring.mail.password=YOUR_16_CHAR_APP_PASSWORD
  app.mail.log-otp-to-console=true
  ```
- [MailSenderService.java](file:///d:/badminton/badminton_be/src/main/java/com/se183891/badminton_be/auth/service/MailSenderService.java) gửi email qua SMTP đồng thời in khung mã OTP 6 số ra Console log khi `app.mail.log-otp-to-console=true` để hỗ trợ kiểm thử nhanh.

## 4. Google Maps (Chủ đề 2)

| Thành phần | Ai gọi | API của Google |
|---|---|---|
| Hiển thị bản đồ, marker | FE (`badminton_fe`) | Maps SDK |
| Đổi địa chỉ <-> tọa độ | BE (`/api/v1/public/geocode`) | Geocoding API (giấu key trên server) |
| Chỉ đường | FE mở ứng dụng Google Maps qua URL | Không cần key |
| Tìm sân gần tôi | BE tự tính bằng công thức Haversine | Không cần Google |

## 5. Mô hình AI (Chủ đề 6)

Chatbot dùng **function calling** để tư vấn sân dựa trên dữ liệu thực trong SQLite:
- `search_venues(lat, lng, radiusKm, date, startTime, maxPrice)`
- `get_venue_policy(venueId)` (giờ mở cửa, chính sách hủy, FAQ)
