# Tài liệu Frontend – badminton_fe

Flutter (Dart SDK ^3.13) · Android là nền tảng demo chính

| File | Nội dung |
|---|---|
| [01-kien-truc.md](01-kien-truc.md) | Cấu trúc thư mục, thư viện, state management, gọi API, phân luồng theo role |
| [02-design-system.md](02-design-system.md) | Màu, chữ, khoảng cách, component dùng chung, trạng thái màn hình |
| [03-danh-sach-man-hinh.md](03-danh-sach-man-hinh.md) | Toàn bộ màn hình của 3 role: mục đích, thành phần, API, story |
| [04-luong-dieu-huong.md](04-luong-dieu-huong.md) | Sơ đồ điều hướng giữa các màn hình theo main flow |
| [05-backlog-fe.md](05-backlog-fe.md) | Danh sách task FE theo sprint, để nhận việc |

## Chạy dự án

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

| Môi trường | `API_BASE_URL` |
|---|---|
| Android emulator, BE chạy trên máy | `http://10.0.2.2:8080/api/v1` |
| Điện thoại thật cùng Wi-Fi | `http://<IP LAN của máy>:8080/api/v1` |
| BE qua ngrok / deploy | `https://<domain>/api/v1` |

Các file cần tự đặt vào (không commit):

- `android/app/google-services.json` (Firebase)
- Google Maps API key trong `android/local.properties`: `MAPS_API_KEY=...`, đọc vào `AndroidManifest.xml` qua `manifestPlaceholders`

## Quy trình làm một màn hình

1. Đọc mô tả màn hình trong [03-danh-sach-man-hinh.md](03-danh-sach-man-hinh.md) và acceptance criteria của story liên quan.
2. Vẽ wireframe trên Figma (khung chung của nhóm), nhờ 1 người duyệt.
3. Kiểm tra API trên Swagger của BE. Nếu API chưa có, dùng dữ liệu giả trong repository (`fake_*_repository.dart`) để làm UI trước.
4. Code theo cấu trúc ở [01-kien-truc.md](01-kien-truc.md), dùng component ở [02-design-system.md](02-design-system.md).
5. Đủ 3 trạng thái loading / rỗng / lỗi rồi mới mở PR.
