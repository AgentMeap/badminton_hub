# badminton_fe – Ứng dụng di động

Ứng dụng Flutter của nền tảng đặt sân cầu lông, dùng chung cho 3 role **Customer**, **CourtOwner** và **Admin**. Mỗi role có giao diện riêng sau khi đăng nhập.

**Flutter (Dart ^3.13) · Material 3 · Riverpod · go_router · Dio**. Android là nền tảng demo chính.

## Yêu cầu

| Công cụ | Ghi chú |
|---|---|
| Flutter SDK (stable) | Kiểm tra: `flutter doctor` không còn dấu ✗ ở mục Android |
| Android Studio | Cài Android SDK, tạo 1 emulator (API 33+) |
| Backend đang chạy | Xem [../badminton_be/README.md](../badminton_be/README.md) |

## Chạy lần đầu

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

`API_BASE_URL` theo môi trường:

| Môi trường | Giá trị |
|---|---|
| Android emulator, BE chạy trên cùng máy | `http://10.0.2.2:8080/api/v1` (mặc định) |
| Điện thoại thật cùng Wi-Fi | `http://<IP LAN của máy chạy BE>:8080/api/v1` |
| BE qua ngrok hoặc đã deploy | `https://<domain>/api/v1` |

Trong Android Studio: *Run → Edit Configurations → Additional run args*: `--dart-define=API_BASE_URL=...`

### File phải tự thêm (không có trong Git)

| File | Lấy ở đâu | Dùng cho |
|---|---|---|
| `android/app/google-services.json` | Firebase Console → Project settings → Android app (xin người quản lý Firebase của nhóm) | Push notification, Google Sign-In |
| `MAPS_API_KEY=...` trong `android/local.properties` | Google Cloud Console (xin người phụ trách Map) | Google Maps |

## Lệnh hay dùng

| Lệnh | Việc làm |
|---|---|
| `flutter pub get` | Cài thư viện sau khi `pubspec.yaml` thay đổi |
| `flutter analyze` | Kiểm tra lỗi và cảnh báo (phải sạch trước khi mở PR) |
| `dart format lib test` | Định dạng code |
| `flutter test` | Chạy test |
| `dart run build_runner build -d` | Sinh code model JSON (`*.g.dart`) |
| `flutter build apk --release --dart-define=API_BASE_URL=...` | Build APK để phát cho lớp |

## Cấu trúc

```
lib/
├── main.dart, app.dart
├── core/
│   ├── config/      Env (API_BASE_URL)
│   ├── network/     Dio client, xử lý lỗi API
│   ├── router/      go_router, chặn theo role
│   ├── theme/       Màu, chữ, khoảng cách (design tokens)
│   ├── l10n/        Chuỗi giao diện tiếng Việt
│   ├── utils/       Định dạng tiền, ngày
│   └── widgets/     Component dùng chung: AppButton, OtpInput, SlotGrid, VenueCard...
└── features/
    ├── auth/        Màn hình S-01…S-07
    ├── customer/    C-01…C-16
    ├── owner/       O-01…O-19
    ├── admin/       A-01…A-12
    └── shared/      Thông báo S-08, S-09
```

Mỗi feature chia `data/` (API, repository, model), `providers/` (Riverpod), `presentation/` (màn hình, widget). Khi BE chưa có API, dùng `fake_*_repository.dart` để làm giao diện trước.

## Tài liệu

| Tài liệu | Nội dung |
|---|---|
| [docs/README.md](docs/README.md) | Mục lục tài liệu FE |
| [docs/02-design-system.md](docs/02-design-system.md) | Màu, chữ, component – đọc trước khi làm giao diện |
| [docs/03-danh-sach-man-hinh.md](docs/03-danh-sach-man-hinh.md) | 56 màn hình: thành phần, API, story |
| [docs/05-backlog-fe.md](docs/05-backlog-fe.md) | Nhận task FE |
| `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.claude/`, `.agents/` | Hướng dẫn cho trợ lý AI khi thiết kế/code giao diện |
| `tokens/`, `components/`, `accessibility/`, `design-systems/`... | Tài liệu tham khảo thiết kế dùng kèm trợ lý AI |

## Lưu ý

- Không hard-code màu, cỡ chữ, khoảng cách trong màn hình; lấy từ `lib/core/theme/`.
- Mọi màn hình gọi API phải có đủ trạng thái loading / rỗng / lỗi (dùng `AsyncView`).
- Chuỗi hiển thị đặt trong `lib/core/l10n/`, không viết thẳng trong widget.
