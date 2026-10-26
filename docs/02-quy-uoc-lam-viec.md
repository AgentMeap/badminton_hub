# 02 – Quy ước làm việc

## Git

Dự án là một repo chung (monorepo) chứa cả FE và BE. Các bước đưa lên GitHub lần đầu, kiểm tra file bị bỏ qua và thiết lập bảo vệ nhánh: xem [05-huong-dan-dua-len-github.md](05-huong-dan-dua-len-github.md).

File cấu hình Git đã có sẵn:

| File | Tác dụng |
|---|---|
| `.gitignore` (gốc, `badminton_be/`, `badminton_fe/`) | Loại file build, cấu hình IDE, khóa bí mật |
| `.gitattributes` | Chuẩn hóa xuống dòng LF, giữ `gradlew` chạy được |
| `.editorconfig` | Thống nhất thụt lề giữa các IDE |
| `.github/pull_request_template.md`, `.github/ISSUE_TEMPLATE/` | Mẫu PR và Issue |

### Nhánh

| Nhánh | Mục đích |
|---|---|
| `main` | Bản ổn định, chỉ merge từ `develop` khi kết thúc sprint |
| `develop` | Nhánh tích hợp, mọi PR merge vào đây |
| `feature/<ID>-<mô-tả>` | Ví dụ `feature/BE-12-otp-login`, `feature/FE-20-map-home` |
| `fix/<ID>-<mô-tả>` | Sửa lỗi |

### Commit (Conventional Commits)

```
<loại>(<phạm vi>): <mô tả ngắn>  [ID]

feat(auth): gửi OTP khi đăng nhập thiết bị mới [BE-12]
fix(booking): chặn đặt trùng khung giờ [BE-31]
docs(api): cập nhật endpoint thanh toán
```

Loại: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `style`.

### Pull request

- Tiêu đề theo mẫu commit, mô tả ghi rõ story/task liên quan và cách test.
- Đính kèm ảnh chụp màn hình với PR FE.
- Ít nhất 1 người review. Không tự merge PR của mình khi chưa có review.

## Quy ước chung FE ↔ BE

| Nội dung | Quy ước |
|---|---|
| Base URL | `/api/v1` |
| Định dạng dữ liệu | JSON, tên trường `camelCase` |
| Thời gian | ISO 8601 có múi giờ, ví dụ `2026-11-02T19:00:00+07:00`. Ngày dạng `2026-11-02`, giờ dạng `19:00` |
| Múi giờ nghiệp vụ | `Asia/Ho_Chi_Minh` |
| Tiền | Số nguyên VNĐ (`long`), không dùng số thực |
| Phân trang | `?page=0&size=20&sort=createdAt,desc` |
| Enum | Chuỗi IN HOA: `PENDING_PAYMENT`, `CONFIRMED`… |
| Lỗi | Định dạng thống nhất, xem [API conventions](../badminton_be/docs/03-api-design.md#2-quy-ước-chung) |

Hợp đồng API là **Swagger của BE** (`/swagger-ui.html`). FE không tự đoán trường dữ liệu; nếu cần thay đổi thì mở issue cho người phụ trách BE.

## Đặt tên trong code

| Nơi | Quy ước | Ví dụ |
|---|---|---|
| Java class | PascalCase | `BookingService` |
| Java package | chữ thường | `com.se183891.badminton_be.booking` |
| Bảng DB | snake_case số ít | `booking_slot` |
| Dart file | snake_case | `venue_detail_screen.dart` |
| Dart class | PascalCase | `VenueDetailScreen` |
