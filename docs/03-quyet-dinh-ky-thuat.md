# 03 – Quyết định kỹ thuật cần chốt

Chốt các mục dưới đây trong **Sprint 0, trước khi viết code nghiệp vụ**. Đổi ý giữa chừng sẽ phải làm lại nhiều. Ghi kết quả vào cột "Đã chốt" kèm ngày.

| # | Vấn đề | Lựa chọn | Đề xuất | Đã chốt |
|---|---|---|---|---|
| D1 | Database | SQLite (đang khai báo trong `build.gradle`) / SQL Server | **SQL Server** | |
| D2 | Cơ chế xác thực | Spring Boot tự cấp JWT / Firebase Auth + BE verify token | **Spring Boot tự cấp JWT**, Google Sign-In qua Firebase chỉ là cách đăng nhập phụ | |
| D3 | Lưu ảnh (ảnh sân, avatar, giấy phép) | Thư mục `uploads/` trên server / Firebase Storage / Cloudinary | **Thư mục `uploads/`** cho bản demo, trừu tượng hóa qua `StorageService` để đổi sau | |
| D4 | Cổng thanh toán | PayOS (VietQR) / VNPay / MoMo | **PayOS (VietQR Open Banking)** làm chính (quét mã VietQR 24/7, khớp đơn tức thì, đối soát webhook tự động), các cổng khác để sau | Đã chốt PayOS |
| D5 | Mô hình AI | Gemini / OpenAI / Claude | Chọn cổng có **gói miễn phí hoặc tín dụng thử** và hỗ trợ function calling | |
| D6 | State management Flutter | Provider / Riverpod / Bloc | **Riverpod** (ít boilerplate hơn Bloc, test dễ hơn Provider) | |
| D7 | Giao diện Admin | Trong app Flutter / web riêng | **Trong app Flutter**, menu theo role | |
| D8 | Gửi OTP | Email / SMS | **Email (SMTP Gmail)**, SMS chỉ trình bày lý thuyết vì tốn phí | |
| D9 | Nơi chạy BE khi demo | Máy cá nhân + ngrok / Render / Railway / VPS | **Máy cá nhân + ngrok** cho dev; một bản deploy online cho ngày demo | |

## Giải thích các đề xuất quan trọng

### D1 – Vì sao nên đổi SQLite sang SQL Server

- `build.gradle` hiện dùng `org.xerial:sqlite-jdbc`. SQLite khóa cả file khi ghi, nên không thể hiện được bài toán **nhiều người đặt cùng khung giờ** (US-C13), vốn là điểm nhấn của chủ đề Database.
- Script seed module Sân đã viết cho SQL Server.
- Chủ đề Database (Module 8, 9) yêu cầu trình bày kết nối MySQL / SQL Server.

Thay đổi cần làm trong `build.gradle`:

```gradle
runtimeOnly 'com.microsoft.sqlserver:mssql-jdbc'
implementation 'org.flywaydb:flyway-sqlserver'
```

Có thể giữ SQLite cho test nếu muốn, nhưng migration Flyway phải viết bằng SQL tương thích.

### D2 – Vì sao Spring Boot tự cấp JWT

- Ba actor nằm ở **ba bảng riêng** (Customer, CourtOwner, Admin). JWT do BE cấp chứa sẵn `role` và `actorId`, Spring Security phân quyền theo tiền tố URL rất gọn.
- Toàn bộ logic OTP, khóa tài khoản, log đăng nhập (chủ đề 4) nằm ở BE, dễ trình bày và viết bài lab.
- Google Sign-In vẫn làm được: app lấy Google ID token rồi gửi lên `POST /auth/customer/google`, BE xác minh và cấp JWT của hệ thống.

### D9 – Vì sao cần URL công khai

PayOS gọi **Webhook** về server của mình để báo kết quả thanh toán. Webhook không gọi được `localhost`, nên khi dev cần ngrok (hoặc tương đương) để có URL công khai.
