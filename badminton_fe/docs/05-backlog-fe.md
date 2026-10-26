# 05 – Backlog Frontend

Cách dùng giống [backlog BE](../../badminton_be/docs/06-backlog-be.md): điền tên vào cột **Phụ trách**, tạo nhánh `feature/FE-xx-...`, đánh dấu `[x]` khi đạt Definition of Done. Mỗi màn hình phải có wireframe được duyệt trước khi code.

Chủ đề: **NT** nền tảng chung · **DB** Database · **MAP** Map · **PAY** Payment · **SEC** Bảo mật · **NOTI** Notifications · **AI** Chat AI

## Sprint 0 – Nền tảng & thiết kế

| ✓ | ID | Task | Chủ đề | Phụ trách | Phụ thuộc |
|---|---|---|---|---|---|
| [x] | FE-01 | Chốt và thêm package vào `pubspec.yaml`, tạo cấu trúc thư mục | NT | | D6 |
| [x] | FE-02 | `Env` đọc `API_BASE_URL`; `DioClient`, `ApiException` | NT | | |
| [x] | FE-03 | Theme theo design system, font Be Vietnam Pro | NT | | |
| [x] | FE-04 | Component dùng chung: `AppButton`, `AppTextField`, `StatusChip`, `AsyncView`, `EmptyState`, `PriceText`, `ConfirmDialog` | NT | | FE-03 |
| [x] | FE-05 | `go_router` + 3 shell + redirect theo role | NT | | |
| [ ] | FE-06 | Figma: khung chung + wireframe các màn hình MVP | Tất cả | | |
| [ ] | FE-07 | Cấu hình Google Maps key, Firebase (`google-services.json`) trên Android | MAP, NOTI | | |

## Sprint 1 – Tài khoản & tạo sân

| ✓ | ID | Task | Màn hình | Chủ đề | Phụ trách | Story |
|---|---|---|---|---|---|---|
| [x] | FE-10 | Lưu token an toàn, `AuthInterceptor` tự refresh, đăng xuất | — | SEC | | C03 |
| [x] | FE-11 | Splash + đăng nhập (chọn vai trò) | S-01, S-02 | SEC | | C03 |
| [x] | FE-12 | Đăng ký Customer + validate | S-03 | SEC | | C01 |
| [x] | FE-13 | Component `OtpInput` + màn hình OTP dùng chung (gửi `deviceId`) | S-04 | SEC | | C02, C04 |
| [x] | FE-14 | Quên / đặt lại mật khẩu | S-05, S-06 | SEC | | C05 |
| [x] | FE-15 | Đăng ký chủ sân + trạng thái hồ sơ | O-01, O-02 | SEC | | O01 |
| [x] | FE-16 | Danh sách cơ sở, tạo/sửa cơ sở, tải ảnh, tiện ích | O-04, O-05 | DB | | O03 |
| [x] | FE-17 | Ghim vị trí: marker kéo được + geocode | O-06 | MAP | | O04 |
| [x] | FE-18 | Sân con, bảng giá, giờ mở cửa | O-07, O-08 | DB | | O05–O07 |

## Sprint 2 – Tìm sân & chọn giờ

| ✓ | ID | Task | Màn hình | Chủ đề | Phụ trách | Story |
|---|---|---|---|---|---|---|
| [x] | FE-20 | Bản đồ sân gần tôi: quyền vị trí, marker, card tóm tắt, dạng danh sách | C-01 | MAP | | C08 |
| [x] | FE-21 | Bộ lọc & sắp xếp | C-02 | MAP | | C09 |
| [x] | FE-22 | Chi tiết sân + nút chỉ đường | C-03 | MAP | | C10, C11 |
| [x] | FE-23 | `SlotGrid` + màn chọn khung giờ, xử lý 409 | C-05 | DB | | C12, C13 |
| [x] | FE-24 | Admin duyệt hồ sơ chủ sân, duyệt cơ sở sân (có bản đồ) | A-02, A-03 | SEC, MAP | | A02, A05 |

## Sprint 3 – Thanh toán & lịch sử

| ✓ | ID | Task | Màn hình | Chủ đề | Phụ trách | Story |
|---|---|---|---|---|---|---|
| [x] | FE-30 | Xác nhận & thanh toán, đếm ngược giữ chỗ | C-07 | PAY | | C13, C17, C18 |
| [x] | FE-31 | Cổng thanh toán PayOS (VietQR Open Banking), webhook/return URL, màn kết quả | C-08 | PAY | | C17 |
| [x] | FE-32 | Lịch đặt của tôi + chi tiết lượt đặt có QR | C-09, C-10 | DB | | C15 |
| [x] | FE-33 | Tài khoản Customer (menu) | C-14 | SEC | | C06 |

## Sprint 4 – Thông báo, check-in, Chat AI

| ✓ | ID | Task | Màn hình | Chủ đề | Phụ trách | Story |
|---|---|---|---|---|---|---|
| [ ] | FE-40 | Khởi tạo FCM, gửi token, xử lý chạm thông báo theo `data.type` | — | NOTI | | C21 |
| [ ] | FE-41 | Màn hình thông báo + badge chưa đọc | S-08 | NOTI | | C23 |
| [ ] | FE-42 | Cài đặt nhắc lịch | S-09 | NOTI | | C22 |
| [ ] | FE-43 | Owner: Hôm nay + Timeline | O-03, O-10 | DB | | O08 |
| [ ] | FE-44 | Quét QR check-in | O-13 | DB | | O11 |
| [ ] | FE-45 | Chat AI: khung chat, gợi ý nhanh, thẻ sân "Đặt ngay" | C-13 | AI | | C24, C25 |

## Giai đoạn 2

| ✓ | ID | Task | Màn hình | Chủ đề | Story |
|---|---|---|---|---|---|
| [ ] | FE-50 | Đăng nhập Google | S-02 | SEC | C03 |
| [ ] | FE-51 | Sửa hồ sơ, đổi mật khẩu | C-15, S-07 | SEC | C06, C07 |
| [ ] | FE-52 | Hủy lượt đặt, hoàn tiền & khiếu nại | C-11, C-16 | PAY | C16 |
| [ ] | FE-53 | Mã giảm giá trong checkout | C-07 | PAY | C20 |
| [ ] | FE-54 | Đánh giá sân, xem đánh giá | C-12, C-04 | DB | C26 |
| [ ] | FE-55 | Đặt định kỳ | C-06 | DB | C14 |
| [ ] | FE-56 | Chính sách hủy & FAQ | O-09 | DB, AI | O07, O19 |
| [ ] | FE-57 | Chi tiết lượt đặt Owner (xác nhận/từ chối), đặt thủ công | O-11, O-12 | DB | O09, O10 |
| [ ] | FE-58 | Doanh thu, hoàn tiền, khuyến mãi, tài khoản ngân hàng | O-14, O-15, O-16, O-19 | PAY | O12–O15 |
| [ ] | FE-59 | Gửi thông báo cho khách, thông báo hàng loạt | O-17, A-10 | NOTI | O17, A10 |
| [ ] | FE-60 | Trợ lý AI chủ sân, cấu hình AI | O-18, A-11 | AI | O18, A11 |
| [ ] | FE-61 | Admin: tổng quan, bản đồ tổng thể | A-01, A-04 | MAP | A06, A12 |
| [ ] | FE-62 | Admin: tài khoản, log đăng nhập | A-05, A-06 | SEC | A03, A04 |
| [ ] | FE-63 | Admin: giao dịch, tranh chấp, cổng & hoa hồng | A-07, A-08, A-12 | PAY | A07–A09 |
| [ ] | FE-64 | Admin: kiểm duyệt đánh giá | A-09 | DB | A13 |
