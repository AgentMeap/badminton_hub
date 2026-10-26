# 01 – Kiến trúc Frontend

## 1. Thư viện đề xuất

| Mục đích | Package | Chủ đề |
|---|---|---|
| State management | `flutter_riverpod` | Chung |
| Điều hướng | `go_router` | Chung |
| Gọi API | `dio` | Chung |
| Model JSON | `json_annotation` + `json_serializable` (+ `build_runner`) | Chung |
| Lưu token an toàn | `flutter_secure_storage` | Bảo mật |
| Định danh thiết bị | `device_info_plus` | Bảo mật |
| Đăng nhập Google | `google_sign_in` | Bảo mật |
| Ô nhập OTP | `pinput` | Bảo mật |
| Bản đồ | `google_maps_flutter` | Map |
| Vị trí hiện tại | `geolocator` | Map |
| Mở Google Maps chỉ đường | `url_launcher` | Map |
| Thanh toán qua WebView | `webview_flutter` | Payment |
| Push notification | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` | Notifications |
| Hiển thị / quét QR | `qr_flutter`, `mobile_scanner` | Database (check-in) |
| Chọn ảnh | `image_picker` | Database |
| Ảnh mạng có cache | `cached_network_image` | Chung |
| Biểu đồ doanh thu | `fl_chart` | Payment |
| Định dạng ngày, tiền | `intl` | Chung |

Chốt danh sách trong Sprint 0 rồi mới thêm vào `pubspec.yaml`, tránh mỗi người cài một thư viện cho cùng một việc.

## 2. Cấu trúc thư mục

```
lib/
├── main.dart
├── app.dart                         MaterialApp.router, theme
├── core/
│   ├── config/env.dart              Đọc API_BASE_URL từ --dart-define
│   ├── network/
│   │   ├── dio_client.dart          Base URL, timeout
│   │   ├── auth_interceptor.dart    Gắn token, tự refresh khi 401
│   │   └── api_exception.dart       Chuyển lỗi BE {code, message} thành exception
│   ├── router/app_router.dart       go_router, chặn theo role
│   ├── theme/                       Màu, chữ, khoảng cách (xem design system)
│   ├── widgets/                     Component dùng chung
│   └── utils/                       Format tiền, ngày, validator
└── features/
    ├── auth/                        S-01…S-07
    ├── customer/
    │   ├── home_map/                C-01
    │   ├── venue/                   C-02…C-04
    │   ├── booking/                 C-05, C-06, C-09…C-12
    │   ├── payment/                 C-07, C-08, C-16
    │   ├── chat_ai/                 C-13
    │   └── profile/                 C-14, C-15
    ├── owner/
    │   ├── onboarding/              O-01, O-02
    │   ├── venue_manage/            O-04…O-09
    │   ├── operation/               O-03, O-10…O-13, O-17
    │   ├── revenue/                 O-14…O-16, O-19
    │   └── assistant/               O-18
    ├── admin/                       A-01…A-12
    └── shared/
        └── notifications/           S-08, S-09
```

Bên trong mỗi feature:

```
venue/
├── data/
│   ├── venue_api.dart               Gọi Dio
│   ├── venue_repository.dart        Interface + bản thật
│   ├── fake_venue_repository.dart   Dữ liệu giả để làm UI khi BE chưa xong
│   └── models/                      VenueSummary, VenueDetail (json_serializable)
├── providers/                       Riverpod providers / notifiers
└── presentation/
    ├── venue_detail_screen.dart
    └── widgets/
```

## 3. Phân luồng theo role

Một app, ba "shell" giao diện. Sau khi đăng nhập, router đọc `role` trong token và chuyển vào shell tương ứng:

| Role | Shell | Bottom navigation |
|---|---|---|
| CUSTOMER | `CustomerShell` | Khám phá (bản đồ) · Lịch đặt · Chat AI · Thông báo · Tài khoản |
| OWNER | `OwnerShell` | Hôm nay · Cơ sở sân · Doanh thu · Thông báo · Tài khoản |
| ADMIN | `AdminShell` | Tổng quan · Duyệt · Tài khoản · Giao dịch · Cấu hình |

`go_router` dùng `redirect` để chặn: Customer gõ đường dẫn `/owner/...` sẽ bị đưa về trang chủ của mình.

Màn hình đăng nhập có lựa chọn "Tôi là người chơi / Tôi là chủ sân". Đăng nhập Admin đặt ở mục ẩn (ví dụ chạm 5 lần vào logo) để không lộ trên giao diện thường.

## 4. Gọi API và xử lý lỗi

- `AuthInterceptor` gắn `Authorization: Bearer <accessToken>`. Khi nhận 401, gọi `/auth/refresh` một lần rồi thử lại request; nếu refresh cũng lỗi thì đăng xuất về màn hình đăng nhập.
- Mọi lỗi từ BE được đổi thành `ApiException(code, message)`. UI hiển thị `message`; một số `code` có xử lý riêng:

| Code | Xử lý ở FE |
|---|---|
| `SLOT_ALREADY_BOOKED`, `HOLD_EXPIRED` | Báo lỗi, tải lại lưới lịch trống |
| `EMAIL_NOT_VERIFIED` | Chuyển sang màn hình xác thực email |
| `ACCOUNT_LOCKED` | Hiển thị lý do khóa, không cho thử lại |
| `OTP_TOO_MANY_ATTEMPTS` | Khóa ô nhập, hiện nút "Gửi mã mới" |

- Tiền hiển thị bằng `NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')`, thời gian theo giờ Việt Nam.

## 5. Push notification

- Khởi tạo Firebase trong `main.dart`, xin quyền thông báo (Android 13+).
- Sau khi đăng nhập, gửi FCM token lên BE; khi token đổi (`onTokenRefresh`) gửi lại.
- App đang mở: hiện banner trong app. App ở nền hoặc tắt: hệ thống hiện thông báo, chạm vào thì đọc `data.type` + `data.targetId` để điều hướng (ví dụ `BOOKING` → C-10 Chi tiết lượt đặt).
