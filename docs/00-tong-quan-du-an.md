# 00 – Tổng quan dự án

## Mục tiêu

Xây dựng nền tảng giúp **Customer** tìm và đặt sân cầu lông, **CourtOwner** quản lý cơ sở sân và doanh thu, **Admin** kiểm duyệt và vận hành nền tảng. Dự án phải thể hiện đủ 6 chủ đề của môn học:

| # | Chủ đề | Module môn học | Thể hiện ở đâu trong dự án |
|---|---|---|---|
| 1 | Database | 8, 9 | Spring Boot + JPA + Flyway, toàn bộ dữ liệu nghiệp vụ |
| 2 | Map | 6, 8 | Bản đồ sân gần tôi, ghim vị trí sân, chỉ đường, bản đồ tổng thể Admin |
| 3 | Payment | 7, 8, 10 | Thanh toán VNPay/MoMo sandbox, cọc, hoàn tiền, đối soát |
| 4 | Bảo mật tài khoản | 10 | Xác thực email, OTP đăng nhập/quên mật khẩu, JWT, khóa tài khoản |
| 5 | Notifications | 10 | Push FCM, màn hình Notifications, nhắc lịch, thông báo hàng loạt |
| 6 | Chat AI | 8, 10 | Chatbot gợi ý sân, hỏi đáp chính sách, trợ lý AI cho chủ sân |

## Ba actor (tách bảng riêng, không gộp role)

| Actor | Vai trò | Kênh sử dụng |
|---|---|---|
| Customer | Tìm sân, đặt sân, thanh toán, đánh giá | App Flutter |
| CourtOwner | Tạo và vận hành cơ sở sân, nhận tiền | App Flutter (giao diện chủ sân) |
| Admin | Duyệt hồ sơ, kiểm duyệt, cấu hình, đối soát | App Flutter (giao diện admin) |

## 8 main flow

| ID | Main flow | Actor chính | Ưu tiên |
|---|---|---|---|
| MF1 | Đăng ký & truy cập tài khoản | Customer, CourtOwner | **MVP** |
| MF2 | Đặt sân & thanh toán | Customer | **MVP** |
| MF3 | Đến sân & sử dụng sân (nhắc lịch, check-in, đánh giá) | Customer, CourtOwner | MVP (rút gọn) |
| MF4 | Hủy đặt sân & hoàn tiền | Customer, CourtOwner, Admin | Giai đoạn 2 |
| MF5 | Đưa cơ sở sân lên nền tảng | CourtOwner, Admin | **MVP** |
| MF6 | Vận hành sân hằng ngày | CourtOwner | Giai đoạn 2 |
| MF7 | Doanh thu, khuyến mãi & đối soát | CourtOwner, Admin | Giai đoạn 2 |
| MF8 | Quản trị & giám sát nền tảng | Admin | Giai đoạn 2 |

**Phạm vi MVP** (bắt buộc có khi demo): MF1 + MF2 + MF5 rút gọn + phần nhắc lịch và check-in của MF3. Phạm vi này đủ để demo cả 6 chủ đề trong một luồng liên tục:

```
Chủ sân tạo sân & ghim bản đồ → Admin duyệt → Customer đăng ký (OTP email)
→ tìm sân trên bản đồ / hỏi chatbot → đặt khung giờ → thanh toán VNPay sandbox
→ nhận push "Đặt sân thành công" → check-in QR tại sân
```

## Tài liệu nguồn

Các tài liệu phân tích đã có, dùng làm đầu vào cho mọi file trong thư mục này:

- User story (58 story): Customer US-C01…C26, CourtOwner US-O01…O19, Admin US-A01…A13
- Acceptance criteria cho từng story (Claude Doc "Acceptance Criteria – Nền tảng đặt sân cầu lông")
- 8 main flow, 62 use case (UC01…UC62)
- Danh sách entity & quan hệ, dữ liệu giả module Sân (`Fake_Data_Module_San.xlsx`, `seed_module_san.sql`)

> Nên đưa bản PDF/Markdown của các tài liệu trên vào `docs/phan-tich/` để mọi người cùng tra cứu.

## Công nghệ

| Lớp | Công nghệ |
|---|---|
| Mobile | Flutter (Dart SDK ^3.13), Android là nền tảng demo chính |
| Backend | Spring Boot 4.1, Java 21, Gradle, Spring Security, Spring Data JPA, Flyway, springdoc-openapi |
| Database | SQL Server (đề xuất, xem [03-quyet-dinh-ky-thuat.md](03-quyet-dinh-ky-thuat.md)) |
| Bên thứ ba | Google Maps, VNPay sandbox, Firebase Cloud Messaging, SMTP Gmail, API mô hình AI |
