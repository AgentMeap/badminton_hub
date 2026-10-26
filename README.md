# Badminton – Nền tảng quản lý & đặt sân cầu lông

Dự án nhóm môn **PRM393**. Ứng dụng di động Flutter kết nối backend Spring Boot, phục vụ 3 actor tách biệt:

| Actor | Làm được gì |
|---|---|
| **Customer** | Tìm sân trên bản đồ, đặt khung giờ, thanh toán online, nhận thông báo, hỏi chatbot AI, đánh giá sân |
| **CourtOwner** | Đăng ký cơ sở sân, quản lý sân con, giá, giờ mở cửa, check-in khách bằng QR, xem doanh thu |
| **Admin** | Duyệt chủ sân và cơ sở sân, quản lý tài khoản, đối soát giao dịch, cấu hình chatbot |

## 6 chủ đề của môn học trong dự án

| # | Chủ đề | Thể hiện |
|---|---|---|
| 1 | Database (Module 8, 9) | Spring Data JPA + Flyway, chống đặt trùng khung giờ |
| 2 | Map (Module 6, 8) | Bản đồ sân gần tôi, ghim vị trí sân, chỉ đường |
| 3 | Payment (Module 7, 8, 10) | VNPay sandbox, đặt cọc, hoàn tiền |
| 4 | Bảo mật tài khoản (Module 10) | Xác thực email, OTP, JWT, khóa tài khoản |
| 5 | Notifications (Module 10) | Push Firebase Cloud Messaging, nhắc lịch |
| 6 | Chat AI (Module 8, 10) | Chatbot gợi ý sân bằng function calling |

## Công nghệ

| Phần | Công nghệ |
|---|---|
| Mobile | Flutter (Dart ^3.13), Material 3 |
| Backend | Spring Boot 4.1, Java 21, Gradle, Spring Security, Spring Data JPA, Flyway, springdoc-openapi |
| Database | SQL Server (đề xuất, đang chốt ở quyết định D1) |
| Dịch vụ ngoài | Google Maps, VNPay sandbox, Firebase Cloud Messaging, SMTP Gmail, API mô hình AI |

## Cấu trúc repo

```
badminton/
├── .github/               Mẫu Pull Request và Issue
├── docs/                  Tài liệu chung: tổng quan, phân công, quy ước, quyết định kỹ thuật
├── badminton_be/          Backend Spring Boot   → xem badminton_be/README.md
│   └── docs/              Kiến trúc, database, API, bảo mật, backlog BE
└── badminton_fe/          Ứng dụng Flutter      → xem badminton_fe/README.md
    └── docs/              Kiến trúc, design system, màn hình, điều hướng, backlog FE
```

## Bắt đầu nhanh

### Yêu cầu cài đặt

| Công cụ | Phiên bản |
|---|---|
| Git | 2.30+ |
| JDK | 21 |
| Flutter SDK | Bản stable hỗ trợ Dart 3.13 |
| Android Studio + Android SDK | Có emulator hoặc điện thoại Android |
| SQL Server | 2019+ hoặc SQL Server Express |

### Chạy Backend

```bash
cd badminton_be
cp src/main/resources/application-local.example.properties src/main/resources/application-local.properties
# Mở file vừa tạo, điền mật khẩu database và các khóa
./gradlew bootRun --args='--spring.profiles.active=local'
```

Swagger: http://localhost:8080/swagger-ui.html · Chi tiết: [badminton_be/README.md](badminton_be/README.md)

### Chạy Frontend

```bash
cd badminton_fe
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

Chi tiết: [badminton_fe/README.md](badminton_fe/README.md)

## Tài liệu

Đọc theo thứ tự:

| # | File | Ai cần đọc |
|---|---|---|
| 1 | [docs/00-tong-quan-du-an.md](docs/00-tong-quan-du-an.md) | Cả nhóm |
| 2 | [docs/01-phan-cong-cong-viec.md](docs/01-phan-cong-cong-viec.md) | Cả nhóm |
| 3 | [docs/02-quy-uoc-lam-viec.md](docs/02-quy-uoc-lam-viec.md) | Cả nhóm |
| 4 | [docs/03-quyet-dinh-ky-thuat.md](docs/03-quyet-dinh-ky-thuat.md) | Cả nhóm (chốt trước khi code) |
| 5 | [docs/04-yeu-cau-bo-sung.md](docs/04-yeu-cau-bo-sung.md) | Cả nhóm |
| 6 | [docs/05-huong-dan-dua-len-github.md](docs/05-huong-dan-dua-len-github.md) | Trưởng nhóm (push lần đầu), thành viên (clone) |
| 7 | [badminton_be/docs/README.md](badminton_be/docs/README.md) | Thành viên làm BE |
| 8 | [badminton_fe/docs/README.md](badminton_fe/docs/README.md) | Thành viên làm FE |

### Hệ thống ID dùng xuyên suốt

| Tiền tố | Ý nghĩa | Ví dụ |
|---|---|---|
| `US-C`, `US-O`, `US-A` | User story của Customer / CourtOwner / Admin | US-C13 |
| `MF` | Main flow | MF2 – Đặt sân & thanh toán |
| `UC` | Use case | UC16 – Thanh toán online |
| `C-`, `O-`, `A-`, `S-` | Màn hình FE theo role (S = dùng chung) | C-05 Chọn khung giờ |
| `BE-`, `FE-` | Task trong backlog | BE-21, FE-14 |

Ghi kèm ID khi tạo task, commit hay pull request để truy vết từ yêu cầu đến code.

## Quy trình làm việc

Nhánh `main` (ổn định) ← `develop` (tích hợp) ← `feature/<ID>-<mô-tả>`. Mọi thay đổi vào `develop` qua Pull Request có ít nhất 1 người review. Xem [CONTRIBUTING.md](CONTRIBUTING.md).

## Thành viên

| Họ tên | MSSV | Chủ đề phụ trách |
|---|---|---|
|  |  | Nền tảng chung |
|  |  | 1. Database |
|  |  | 2. Map |
|  |  | 3. Payment |
| Đạt |  | 4. Bảo mật tài khoản |
|  |  | 5. Notifications |
|  |  | 6. Chat AI |
