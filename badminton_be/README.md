# badminton_be – Backend

Backend của nền tảng đặt sân cầu lông: **Spring Boot 4.1 · Java 21 · Gradle · Spring Security · Spring Data JPA · Flyway · springdoc-openapi**.

## Yêu cầu

| Công cụ | Ghi chú |
|---|---|
| JDK 21 | Kiểm tra: `java -version` |
| SQL Server 2019+ / Express | Tạo sẵn database `badminton` |
| IntelliJ IDEA (khuyên dùng) | Cài plugin Lombok, bật *Annotation Processing* |
| ngrok (tùy chọn) | Chỉ cần khi test IPN của VNPay |

Không cần cài Gradle, dự án dùng Gradle Wrapper (`gradlew`).

## Chạy lần đầu

```bash
# 1. Tạo database
#    Trong SQL Server Management Studio: CREATE DATABASE badminton;

# 2. Tạo file cấu hình cá nhân từ file mẫu
cp src/main/resources/application-local.example.properties src/main/resources/application-local.properties
#    Mở file vừa tạo và điền mật khẩu DB, JWT secret, các khóa API

# 3. Chạy
./gradlew bootRun --args='--spring.profiles.active=local'      # Git Bash / macOS / Linux
.\gradlew.bat bootRun --args='--spring.profiles.active=local'   # PowerShell
```

Trong IntelliJ: *Run → Edit Configurations → Active profiles* điền `local`.

Flyway tự tạo bảng và seed dữ liệu demo ở lần chạy đầu.

| Địa chỉ | Mô tả |
|---|---|
| http://localhost:8080/swagger-ui.html | Swagger UI – hợp đồng API cho FE |
| http://localhost:8080/v3/api-docs | OpenAPI JSON (import vào Postman) |
| http://localhost:8080/api/v1/health | Kiểm tra server sống |

## Lệnh hay dùng

| Lệnh | Việc làm |
|---|---|
| `./gradlew bootRun` | Chạy server |
| `./gradlew build` | Biên dịch + chạy test + đóng gói jar |
| `./gradlew test` | Chạy test |
| `./gradlew clean` | Xóa thư mục `build/` |

## Cấu trúc

```
src/main/java/com/se183891/badminton_be/
├── common/          Cấu hình, xử lý lỗi, JWT, lưu file
├── auth/            Đăng ký, đăng nhập, OTP
├── customer/  owner/  admin/
├── venue/  booking/  payment/  review/  notification/  chat/
src/main/resources/
├── application.properties                    Cấu hình chung (commit)
├── application-local.example.properties      Mẫu cấu hình cá nhân (commit)
├── application-local.properties              Cấu hình cá nhân (KHÔNG commit)
└── db/migration/                             Script Flyway V1__..., V2__...
```

Chi tiết kiến trúc, database, danh sách API, bảo mật và backlog: [docs/README.md](docs/README.md).

## Lưu ý

- **Không commit** `application-local.properties`, file service account Firebase, thư mục `uploads/`.
- **Không sửa** file migration Flyway đã merge. Muốn đổi schema thì tạo file `V{số tiếp theo}__mo_ta.sql`.
- Mỗi endpoint mới phải xuất hiện trên Swagger với mô tả và ví dụ.

## Tài khoản demo (sau khi seed)

| Role | Email | Mật khẩu |
|---|---|---|
| Customer | customer@demo.vn | `Demo@123` |
| CourtOwner | hung.owner@example.com | `Demo@123` |
| Admin | admin@caulong.vn | `Demo@123` |
