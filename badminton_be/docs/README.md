# Tài liệu Backend – badminton_be

Spring Boot 4.1 · Java 21 · Gradle · Spring Security · Spring Data JPA · Flyway · springdoc-openapi

| File | Nội dung |
|---|---|
| [01-kien-truc.md](01-kien-truc.md) | Cấu trúc package, các lớp, xử lý lỗi, job định kỳ |
| [02-database.md](02-database.md) | Bảng, quan hệ, ràng buộc, kế hoạch migration Flyway |
| [03-api-design.md](03-api-design.md) | Quy ước API và danh sách endpoint theo module, theo role |
| [04-bao-mat.md](04-bao-mat.md) | JWT, phân quyền 3 actor, luồng OTP, khóa tài khoản |
| [05-tich-hop-ben-ngoai.md](05-tich-hop-ben-ngoai.md) | VNPay, FCM, SMTP, Google Maps, mô hình AI |
| [06-backlog-be.md](06-backlog-be.md) | Danh sách task BE theo sprint, để nhận việc |

## Chạy dự án ở máy cá nhân

### Yêu cầu

- JDK 21
- SQL Server 2019+ (hoặc SQL Server Express), tạo sẵn database `badminton`
- (Tùy chọn) ngrok để nhận IPN từ VNPay

### Các bước

1. Sao chép file cấu hình mẫu và điền thông tin của bạn:

   ```bash
   cp src/main/resources/application-local.example.properties src/main/resources/application-local.properties
   ```

   ```properties
   spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=badminton;encrypt=false
   spring.datasource.username=sa
   spring.datasource.password=<mật khẩu>
   app.jwt.secret=<chuỗi ngẫu nhiên ≥ 32 ký tự>
   app.mail.username=<gmail>
   app.mail.app-password=<app password>
   app.vnpay.tmn-code=<sandbox>
   app.vnpay.hash-secret=<sandbox>
   app.ai.api-key=<khóa API>
   ```

2. Chạy:

   ```bash
   ./gradlew bootRun --args='--spring.profiles.active=local'
   ```

3. Mở Swagger: http://localhost:8080/swagger-ui.html

Flyway tự tạo bảng và seed dữ liệu demo khi khởi động lần đầu.

## Tài khoản demo (sau khi seed)

| Role | Email | Mật khẩu |
|---|---|---|
| Customer | customer@demo.vn | `Demo@123` |
| CourtOwner | hung.owner@example.com | `Demo@123` |
| Admin | admin@caulong.vn | `Demo@123` |
