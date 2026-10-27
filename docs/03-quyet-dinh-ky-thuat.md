# 03 - Quyết định kỹ thuật cần chốt

Chốt các mục dưới đây trong **Sprint 0, trước khi viết code nghiệp vụ**. Đổi ý giữa chừng sẽ phải làm lại nhiều. Ghi kết quả vào cột "Đã chốt" kèm ngày.

| # | Vấn đề | Lựa chọn | Đề xuất | Đã chốt |
|---|---|---|---|---|
| D1 | Database | SQLite (`org.xerial:sqlite-jdbc`) / SQL Server | **SQLite (chế độ WAL + Foreign Keys + Flyway)** giúp chạy độc lập, gọn nhẹ và vẫn hỗ trợ Partial Unique Index chống đặt trùng khung giờ | Đã chốt SQLite |
| D2 | Cơ chế xác thực & Phân quyền | Mô hình RBAC (`User`, `Role`, `Permission`) + JWT nội bộ + Firebase Authentication | **RBAC 1 bảng `users` liên kết `role` & `permission`**. Hỗ trợ 2 loại đăng ký: (1) Đăng ký Google qua Firebase Auth và (2) Đăng ký thường nhận OTP qua SMTP, xác thực OTP thành công mới lưu tài khoản lên Firebase Authentication | Đã chốt RBAC + Firebase Auth |
| D3 | Lưu ảnh & tài liệu (ảnh sân, avatar, giấy phép) | Thư mục `uploads/` trên server / Firebase Storage / Cloudinary | **Thư mục `uploads/`** phục vụ qua `/files/**`, trừu tượng hóa qua `StorageService` | Đã chốt `uploads/` |
| D4 | Cổng thanh toán | PayOS (VietQR) / VNPay / MoMo | **PayOS (VietQR Open Banking)** làm chính (quét mã VietQR 24/7, khớp đơn tức thì, đối soát webhook tự động), các cổng khác để sau | Đã chốt PayOS |
| D5 | Mô hình AI | Gemini / OpenAI / Claude | Chọn cổng có **gói miễn phí hoặc tín dụng thử** và hỗ trợ function calling (`gemini-2.5-flash`) | Đã chốt Gemini |
| D6 | State management Flutter | ChangeNotifier / Riverpod / Bloc | **ChangeNotifier + Repository / ApiService** gọn nhẹ, dễ kiểm thử | Đã chốt |
| D7 | Giao diện Admin | Trong app Flutter / web riêng | **Trong app Flutter**, điều hướng theo role RBAC | Đã chốt |
| D8 | Gửi OTP | Email / SMS | **Email (SMTP Gmail)** gửi mã OTP 6 chữ số (kèm in ra Console log khi dev) | Đã chốt SMTP Gmail |
| D9 | Nơi chạy BE khi demo | Máy cá nhân + ngrok / Render / Railway / VPS | **Máy cá nhân + ngrok** cho dev; một bản deploy online cho ngày demo | Đã chốt |

## Giải thích các quyết định kỹ thuật trọng tâm

### D1 - Cấu hình SQLite tối ưu cho bài toán chống đặt trùng và đa luồng

- Sử dụng `org.xerial:sqlite-jdbc` kết hợp `org.hibernate.community.dialect.SQLiteDialect` và quản lý schema bằng **Flyway** (`spring.jpa.hibernate.ddl-auto=validate`).
- Bật chế độ **WAL (Write-Ahead Logging)**, kiểm tra khóa ngoại (`foreign_keys=on`), `busy_timeout=5000` và giới hạn HikariCP `maximum-pool-size=1`:
  ```properties
  spring.datasource.url=jdbc:sqlite:badminton.db?foreign_keys=on&journal_mode=WAL&busy_timeout=5000
  spring.datasource.hikari.maximum-pool-size=1
  ```
- SQLite hỗ trợ đầy đủ **Partial Unique Index** (`CREATE UNIQUE INDEX ux_slot_active ON booking_slot (court_id, play_date, start_time) WHERE is_active = 1`), đảm bảo chống đặt trùng sân (`409 SLOT_ALREADY_BOOKED`) chính xác tuyệt đối.

### D2 - Mô hình RBAC kết hợp SMTP OTP và Firebase Authentication

- Thay vì tách 3 bảng rời (`customer`, `court_owner`, `admin`), hệ thống sử dụng mô hình **RBAC chuẩn** gồm 5 bảng: `role`, `permission`, `role_permission`, `users`, `user_role`.
- Mọi bảng bảo mật và nghiệp vụ (`otp_code`, `trusted_device`, `auth_session`, `login_log`, `account_action_log`, `owner_application`, `bank_account`) chỉ cần tham chiếu tới 1 khóa ngoại duy nhất `user_id REFERENCES users(id)`.
- Hai luồng đăng ký đồng bộ chặt chẽ với **Firebase Authentication**:
  1. **Đăng ký bằng Google**: App lấy Firebase ID Token gửi lên `POST /api/v1/auth/customer/google`, Backend xác thực qua Firebase Admin SDK và lưu `firebase_uid` vào bảng `users`.
  2. **Đăng ký bình thường**: App gửi thông tin lên `POST /api/v1/auth/customer/register` (hoặc `/owner/register`), Backend gửi mã OTP 6 số qua SMTP (mật khẩu chờ xác thực được mã hóa tạm thời bằng `AES-256-GCM` trong 15 phút). Ngay khi người dùng nhập đúng OTP tại `POST /api/v1/auth/{role}/verify-email`, Backend gọi Firebase Admin SDK `createUser(emailVerified=true)` để lưu tài khoản lên Firebase Authentication, gắn `firebase_uid` vào SQLite và cấp cặp JWT `accessToken` + `refreshToken`.

### D9 - Vì sao cần URL công khai

PayOS gọi **Webhook** về server để báo kết quả thanh toán VietQR. Webhook không gọi được `localhost`, nên khi dev cần ngrok (hoặc tương đương) để có URL công khai.
