# 06 – Backlog Backend

Cách dùng: nhận task bằng cách điền tên vào cột **Phụ trách**, tạo nhánh `feature/BE-xx-...`, đánh dấu `[x]` khi đạt [Definition of Done](../../docs/01-phan-cong-cong-viec.md#definition-of-done-một-task-được-coi-là-xong-khi). Nếu nhóm dùng GitHub Projects/Trello thì chép task sang đó và giữ nguyên ID.

Chủ đề: **NT** nền tảng chung · **DB** Database · **MAP** Map · **PAY** Payment · **SEC** Bảo mật · **NOTI** Notifications · **AI** Chat AI

## Sprint 0 – Nền tảng

| ✓ | ID | Task | Chủ đề | Phụ trách | Phụ thuộc |
|---|---|---|---|---|---|
| [ ] | BE-01 | Đổi driver sang SQL Server, thêm `flyway-sqlserver`, cấu hình profile `local` + file mẫu | NT | | D1 |
| [ ] | BE-02 | Package `common`: `ApiResponse`, `PageResponse`, `ErrorCode`, `AppException`, `GlobalExceptionHandler` | NT | | |
| [ ] | BE-03 | Cấu hình springdoc (Swagger có nút Authorize Bearer), CORS, Jackson múi giờ | NT | | |
| [ ] | BE-04 | `GET /api/v1/health` và filter gắn `traceId` vào log | NT | | |
| [ ] | BE-05 | `StorageService` lưu file vào `uploads/`, phục vụ ảnh qua `/files/**` | NT | | D3 |
| [ ] | BE-06 | Postman collection + environment dùng chung | NT | | |

## Sprint 1 – Tài khoản & tạo sân

| ✓ | ID | Task | Chủ đề | Phụ trách | Story |
|---|---|---|---|---|---|
| [ ] | BE-10 | Migration V1: actor + bảng bảo mật; seed 1 Admin | SEC | | G2 |
| [ ] | BE-11 | `JwtService`, `JwtAuthFilter`, `SecurityConfig` 3 role, `CurrentActor` | SEC | | C03 |
| [ ] | BE-12 | `OtpService`: tạo, băm, kiểm tra, giới hạn thử/gửi | SEC | | C02, C04 |
| [ ] | BE-13 | `MailSender` SMTP Gmail + template OTP | SEC | | C02 |
| [ ] | BE-14 | Đăng ký + xác thực email Customer | SEC | | C01, C02 |
| [ ] | BE-15 | Đăng nhập + OTP thiết bị lạ + refresh + logout (3 actor) | SEC | | C03, C04, O02, A01 |
| [ ] | BE-16 | Quên / đặt lại mật khẩu | SEC | | C05 |
| [ ] | BE-17 | Đăng ký chủ sân (upload giấy phép), Admin duyệt/từ chối hồ sơ | SEC | | O01, A02 |
| [ ] | BE-18 | Migration V3 module Sân + seed từ `seed_module_san.sql` | DB | | — |
| [ ] | BE-19 | CRUD venue, ảnh, tiện ích, sân con của Owner (kiểm tra sở hữu) | DB | | O03, O05 |
| [ ] | BE-20 | Bảng giá (kiểm tra chồng lấn), giờ mở cửa | DB | | O06, O07 |
| [ ] | BE-21 | `/public/geocode` gọi Google Geocoding | MAP | | O04 |

## Sprint 2 – Tìm sân & giữ chỗ

| ✓ | ID | Task | Chủ đề | Phụ trách | Story |
|---|---|---|---|---|---|
| [ ] | BE-30 | `/public/venues`: lọc + Haversine + sắp xếp + phân trang | MAP | | C08, C09 |
| [ ] | BE-31 | `/public/venues/{id}` chi tiết sân | DB | | C10 |
| [ ] | BE-32 | `/public/venues/{id}/availability` lưới lịch trống | DB | | C12 |
| [ ] | BE-33 | Migration V4 booking; filtered unique index chống trùng | DB | | N2 |
| [ ] | BE-34 | `POST /customer/bookings`: tính giá theo `PriceRule`, giữ chỗ 10 phút, bắt lỗi trùng → 409 | DB | | C13 |
| [ ] | BE-35 | Integration test: 2 request song song cùng khung giờ, chỉ 1 thành công | DB | | T2 |
| [ ] | BE-36 | `ExpireHoldJob` | DB | | C13 |
| [ ] | BE-37 | Admin duyệt / yêu cầu sửa / tạm ngưng venue | MAP | | A05 |

## Sprint 3 – Thanh toán & lịch sử

| ✓ | ID | Task | Chủ đề | Phụ trách | Story |
|---|---|---|---|---|---|
| [ ] | BE-40 | Migration V5 payment; seed `payment_gateway` VNPay | PAY | | — |
| [ ] | BE-41 | `VnpayClient`: tạo URL, ký HMAC-SHA512, verify chữ ký (có unit test) | PAY | | C17 |
| [ ] | BE-42 | Tạo payment FULL / DEPOSIT, trả `paymentUrl` | PAY | | C17, C18 |
| [ ] | BE-43 | IPN idempotent: cập nhật Payment + Booking `CONFIRMED` | PAY | | C17 |
| [ ] | BE-44 | Hóa đơn + gửi email hóa đơn | PAY | | C19 |
| [ ] | BE-45 | Lịch sử đặt sân theo tab, chi tiết + `qrToken` ký HMAC | DB | | C15 |

## Sprint 4 – Thông báo, check-in, Chat AI

| ✓ | ID | Task | Chủ đề | Phụ trách | Story |
|---|---|---|---|---|---|
| [ ] | BE-50 | Migration V6; `PushSender` FCM; device token API | NOTI | | C21 |
| [ ] | BE-51 | `NotificationService`: lưu + push khi đặt thành công/hủy, gửi cho cả Owner | NOTI | | C21, O16 |
| [ ] | BE-52 | API danh sách, unread-count, đánh dấu đã đọc | NOTI | | C23 |
| [ ] | BE-53 | Cài đặt nhắc lịch + `BookingReminderJob` | NOTI | | C22 |
| [ ] | BE-54 | `POST /owner/check-ins` kiểm tra QR; `CompleteBookingJob` | DB | | O11, G3 |
| [ ] | BE-55 | Timeline đặt sân cho Owner | DB | | O08 |
| [ ] | BE-56 | Migration V7; `AiClient` + function calling `search_venues`, `get_venue_policy` | AI | | C24, C25 |
| [ ] | BE-57 | API phiên chat, gửi/nhận tin, giới hạn tin nhắn/ngày | AI | | C24 |

## Giai đoạn 2 (làm khi MVP đã ổn định)

| ✓ | ID | Task | Chủ đề | Story |
|---|---|---|---|---|
| [ ] | BE-60 | Google Sign-In | SEC | C03 |
| [ ] | BE-61 | Đổi mật khẩu có OTP, cập nhật hồ sơ/avatar | SEC | C06, C07 |
| [ ] | BE-62 | Admin khóa/mở khóa tài khoản, log đăng nhập bất thường | SEC | A03, A04 |
| [ ] | BE-63 | Hủy đặt sân + preview tiền hoàn theo `CancellationRule` | PAY | C16 |
| [ ] | BE-64 | Hoàn tiền: Owner duyệt, `EscalateRefundJob`, Admin xử lý tranh chấp | PAY | O14, A09 |
| [ ] | BE-65 | Mã khuyến mãi + validate | PAY | C20, O15 |
| [ ] | BE-66 | Báo cáo doanh thu + xuất Excel | PAY | O13 |
| [ ] | BE-67 | Hoa hồng, đối soát, giao dịch Admin | PAY | A07, A08 |
| [ ] | BE-68 | Đặt định kỳ | DB | C14 |
| [ ] | BE-69 | Owner xác nhận/từ chối, đặt thủ công, `AutoRejectUnconfirmedJob` | DB | O09, O10 |
| [ ] | BE-70 | Đánh giá + báo cáo đánh giá + Admin ẩn | DB | C26, A13, G1 |
| [ ] | BE-71 | Thông báo của Owner và thông báo hàng loạt có hẹn giờ | NOTI | O17, A10 |
| [ ] | BE-72 | FAQ venue, trợ lý AI cho Owner, cấu hình AI + báo cáo chat | AI | O18, O19, A11 |
| [ ] | BE-73 | Dashboard Admin, bản đồ tổng thể | MAP | A06, A12 |
| [ ] | BE-74 | Rate limit cho auth và chatbot | SEC | N4 |
