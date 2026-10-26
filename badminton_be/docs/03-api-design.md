# 03 – Thiết kế API

Tài liệu này là **bản thiết kế ban đầu**. Hợp đồng chính thức là Swagger (`/swagger-ui.html`) sau khi code. Ai đổi endpoint thì cập nhật lại bảng ở đây.

## 1. Phân vùng URL theo actor

| Tiền tố | Ai được gọi | Ví dụ |
|---|---|---|
| `/api/v1/auth/**` | Công khai | Đăng ký, đăng nhập, OTP |
| `/api/v1/public/**` | Công khai (không cần đăng nhập) | Xem sân, lịch trống |
| `/api/v1/customer/**` | JWT role `CUSTOMER` | Đặt sân, thanh toán |
| `/api/v1/owner/**` | JWT role `OWNER` | Quản lý sân |
| `/api/v1/admin/**` | JWT role `ADMIN` | Duyệt, cấu hình |
| `/api/v1/webhooks/**` | Bên thứ ba (kiểm tra chữ ký) | IPN VNPay |

Ngoài kiểm tra role, service phải kiểm tra **quyền sở hữu**: owner chỉ thao tác được trên venue của mình, customer chỉ xem được booking của mình.

## 2. Quy ước chung

### Response thành công

```json
{
  "success": true,
  "data": { },
  "meta": { "page": 0, "size": 20, "totalElements": 135, "totalPages": 7 }
}
```

`meta` chỉ có ở API danh sách có phân trang.

### Response lỗi

```json
{
  "success": false,
  "error": {
    "code": "SLOT_ALREADY_BOOKED",
    "message": "Khung giờ vừa có người đặt",
    "details": [ { "field": "slots[0].startTime", "message": "..." } ],
    "traceId": "a1b2c3d4"
  }
}
```

FE hiển thị `message` cho người dùng và dựa vào `code` để xử lý riêng (ví dụ `SLOT_ALREADY_BOOKED` thì tải lại lịch trống).

### HTTP status

| Status | Khi nào |
|---|---|
| 200 / 201 | Thành công / tạo mới thành công |
| 400 | Dữ liệu không hợp lệ, OTP sai |
| 401 | Chưa đăng nhập, token hết hạn → FE gọi refresh |
| 403 | Sai role, không sở hữu tài nguyên, tài khoản bị khóa |
| 404 | Không tìm thấy |
| 409 | Xung đột: đặt trùng, email đã tồn tại |
| 429 | Vượt giới hạn tần suất (OTP, đăng nhập, chatbot) |

### Mã lỗi chính

| Code | Status | Ý nghĩa |
|---|---|---|
| `VALIDATION_ERROR` | 400 | Lỗi validate, xem `details` |
| `EMAIL_EXISTS` | 409 | Email đã dùng |
| `INVALID_CREDENTIALS` | 401 | Sai email hoặc mật khẩu |
| `EMAIL_NOT_VERIFIED` | 403 | Chưa xác thực email |
| `ACCOUNT_LOCKED` | 403 | Bị khóa (tạm hoặc bởi Admin) |
| `OTP_INVALID` / `OTP_EXPIRED` / `OTP_TOO_MANY_ATTEMPTS` | 400 / 400 / 429 | Lỗi OTP |
| `SLOT_ALREADY_BOOKED` | 409 | Khung giờ đã có người đặt |
| `SLOT_IN_PAST` / `SLOT_OUTSIDE_OPENING_HOURS` | 400 | Khung giờ không hợp lệ |
| `HOLD_EXPIRED` | 409 | Hết thời gian giữ chỗ |
| `PROMOTION_INVALID` | 400 | Mã giảm giá không hợp lệ, lý do trong `message` |
| `BOOKING_NOT_CANCELLABLE` | 409 | Trạng thái không cho hủy |
| `PAYMENT_SIGNATURE_INVALID` | 400 | Chữ ký cổng thanh toán sai |
| `QR_INVALID` | 400 | QR sai, hết hạn hoặc đã dùng |
| `RESOURCE_NOT_OWNED` | 403 | Không sở hữu tài nguyên |
| `NOT_FOUND` | 404 | Không tìm thấy |

## 3. Danh sách endpoint

Cột **Story** để đối chiếu acceptance criteria. Cột **Ưu tiên**: MVP hoặc GĐ2 (giai đoạn 2).

### 3.1 Auth & tài khoản (chủ đề 4 – Bảo mật)

`{actor}` nhận một trong `customer`, `owner`, `admin`.

| Method | Endpoint | Mô tả | Story | Ưu tiên |
|---|---|---|---|---|
| POST | `/auth/customer/register` | Đăng ký Customer, gửi mã xác thực email | C01, C02 | MVP |
| POST | `/auth/owner/register` | Đăng ký chủ sân (multipart, kèm giấy phép) | O01 | MVP |
| POST | `/auth/{actor}/verify-email` | Nhập mã 6 số xác thực email | C02 | MVP |
| POST | `/auth/{actor}/verify-email/resend` | Gửi lại mã (chờ 60 giây) | C02 | MVP |
| POST | `/auth/{actor}/login` | Đăng nhập. Trả token, hoặc `otpRequired=true` + `otpTicket` khi thiết bị lạ / 2FA | C03, C04, O02, A01 | MVP |
| POST | `/auth/{actor}/login/verify-otp` | Gửi `otpTicket` + mã OTP, nhận token | C04, O02, A01 | MVP |
| POST | `/auth/customer/google` | Đăng nhập bằng Google ID token | C03 | GĐ2 |
| POST | `/auth/{actor}/forgot-password` | Gửi OTP đặt lại mật khẩu | C05 | MVP |
| POST | `/auth/{actor}/reset-password` | OTP + mật khẩu mới | C05 | MVP |
| POST | `/auth/refresh` | Đổi refresh token lấy access token mới | C03 | MVP |
| POST | `/auth/logout` | Thu hồi phiên hiện tại | — | MVP |
| GET / PUT | `/customer/me` | Xem / sửa hồ sơ | C06 | MVP |
| POST | `/customer/me/avatar` | Tải ảnh đại diện (multipart) | C06 | GĐ2 |
| POST | `/{actor}/me/password/otp` | Gửi OTP để đổi mật khẩu | C07 | GĐ2 |
| PUT | `/{actor}/me/password` | Mật khẩu cũ + mới + OTP | C07 | GĐ2 |
| GET / PUT | `/owner/me` | Hồ sơ chủ sân | — | MVP |
| GET | `/owner/applications/latest` | Trạng thái hồ sơ đăng ký | O01 | MVP |
| POST | `/owner/applications` | Nộp lại hồ sơ khi bị từ chối | O01 | GĐ2 |

### 3.2 Xem sân công khai (chủ đề 1, 2)

| Method | Endpoint | Mô tả | Story | Ưu tiên |
|---|---|---|---|---|
| GET | `/public/venues` | Tìm sân. Query: `lat`, `lng`, `radiusKm`, `keyword`, `district`, `minPrice`, `maxPrice`, `date`, `startTime`, `amenityIds`, `sort=distance\|price\|rating` | C08, C09 | MVP |
| GET | `/public/venues/{id}` | Chi tiết sân: ảnh, giá, tiện ích, giờ mở cửa, chính sách hủy, rating | C10 | MVP |
| GET | `/public/venues/{id}/availability?date=` | Lưới lịch: từng sân con × khung giờ, trạng thái `AVAILABLE/BOOKED/MAINTENANCE/PAST` | C12 | MVP |
| GET | `/public/venues/{id}/reviews` | Danh sách đánh giá (phân trang) | C10 | GĐ2 |
| GET | `/public/amenities` | Danh mục tiện ích cho bộ lọc | C09 | MVP |

Khoảng cách tính bằng công thức Haversine trong truy vấn SQL; lọc thô bằng khung lat/lng trước để dùng được index.

### 3.3 Đặt sân – Customer (chủ đề 1)

| Method | Endpoint | Mô tả | Story | Ưu tiên |
|---|---|---|---|---|
| POST | `/customer/bookings` | Giữ chỗ: `courtId`, `date`, `startTime`, `endTime`, `promotionCode?`, `paymentOption=FULL\|DEPOSIT\|AT_VENUE`. Trả booking + `holdExpiresAt` | C13, C18 | MVP |
| POST | `/customer/bookings/recurring/preview` | Kiểm tra trước các buổi định kỳ, trả buổi bị trùng | C14 | GĐ2 |
| POST | `/customer/bookings/recurring` | Tạo chuỗi đặt định kỳ | C14 | GĐ2 |
| GET | `/customer/bookings?tab=upcoming\|past\|cancelled` | Lịch sử đặt sân | C15 | MVP |
| GET | `/customer/bookings/{id}` | Chi tiết + `qrToken` | C15 | MVP |
| GET | `/customer/bookings/{id}/cancel-preview` | Số tiền được hoàn nếu hủy bây giờ | C16 | GĐ2 |
| POST | `/customer/bookings/{id}/cancel` | Hủy lượt đặt | C16 | GĐ2 |
| POST | `/customer/promotions/validate` | Kiểm tra mã giảm giá cho một lượt đặt | C20 | GĐ2 |
| POST | `/customer/bookings/{id}/review` | Đánh giá sau khi chơi | C26 | GĐ2 |
| PUT | `/customer/reviews/{id}` | Sửa đánh giá trong 7 ngày | C26 | GĐ2 |

### 3.4 Thanh toán (chủ đề 3)

| Method | Endpoint | Mô tả | Story | Ưu tiên |
|---|---|---|---|---|
| POST | `/customer/bookings/{id}/payments` | Tạo giao dịch: `gateway=VNPAY`, `type=FULL\|DEPOSIT\|REMAINING`. Trả `paymentUrl` để mở WebView | C17, C18 | MVP |
| GET | `/webhooks/vnpay/ipn` | VNPay gọi về, kiểm tra chữ ký, cập nhật Payment + Booking | C17 | MVP |
| GET | `/webhooks/vnpay/return` | Trang VNPay chuyển về sau thanh toán, chỉ để app nhận biết đã xong (không cập nhật trạng thái) | C17 | MVP |
| GET | `/customer/payments/{id}` | Trạng thái giao dịch (app hỏi lại sau khi đóng WebView) | C17 | MVP |
| GET | `/customer/payments/{id}/invoice` | Hóa đơn | C19 | GĐ2 |
| GET | `/customer/refunds` | Danh sách hoàn tiền | C16 | GĐ2 |
| POST | `/customer/refunds/{id}/dispute` | Khiếu nại lên Admin | A09 | GĐ2 |

### 3.5 Notifications (chủ đề 5)

`{actor}` = `customer` / `owner` / `admin`.

| Method | Endpoint | Mô tả | Story | Ưu tiên |
|---|---|---|---|---|
| POST | `/{actor}/device-tokens` | Đăng ký FCM token khi đăng nhập | C21 | MVP |
| DELETE | `/{actor}/device-tokens/{token}` | Hủy token khi đăng xuất | C21 | MVP |
| GET | `/{actor}/notifications` | Danh sách (phân trang, mới nhất trước) | C23 | MVP |
| GET | `/{actor}/notifications/unread-count` | Số chưa đọc cho badge | C23 | MVP |
| PATCH | `/{actor}/notifications/{id}/read` | Đánh dấu đã đọc | C23 | MVP |
| PATCH | `/{actor}/notifications/read-all` | Đánh dấu tất cả đã đọc | C23 | MVP |
| GET / PUT | `/customer/notification-settings` | Thời gian nhắc lịch | C22 | MVP |
| GET / PUT | `/owner/notification-settings` | Bật/tắt loại thông báo | O16 | GĐ2 |
| POST | `/owner/announcements` | Gửi thông báo cho khách | O17 | GĐ2 |
| POST | `/admin/announcements` | Thông báo hàng loạt, có hẹn giờ | A10 | GĐ2 |
| GET | `/admin/announcements` | Lịch sử + thống kê đã gửi/đã đọc | A10 | GĐ2 |

### 3.6 Chat AI (chủ đề 6)

| Method | Endpoint | Mô tả | Story | Ưu tiên |
|---|---|---|---|---|
| POST | `/customer/chat/sessions` | Tạo phiên chat | C24 | MVP |
| GET | `/customer/chat/sessions/{id}/messages` | Lịch sử tin nhắn | C25 | MVP |
| POST | `/customer/chat/sessions/{id}/messages` | Gửi câu hỏi, nhận trả lời (kèm danh sách sân gợi ý nếu có) | C24, C25 | MVP |
| POST | `/customer/chat/messages/{id}/report` | Báo cáo câu trả lời | C25 | GĐ2 |
| POST | `/owner/assistant/messages` | Hỏi trợ lý AI về dữ liệu cơ sở của mình | O18 | GĐ2 |

### 3.7 Quản lý sân – CourtOwner (chủ đề 1, 2)

| Method | Endpoint | Mô tả | Story | Ưu tiên |
|---|---|---|---|---|
| GET / POST | `/owner/venues` | Danh sách / tạo cơ sở (trạng thái `DRAFT`) | O03 | MVP |
| GET / PUT | `/owner/venues/{id}` | Xem / sửa thông tin, kể cả `latitude`, `longitude` | O03, O04 | MVP |
| POST | `/owner/venues/{id}/submit` | Gửi Admin duyệt (`DRAFT` → `PENDING_REVIEW`) | O03 | MVP |
| POST | `/owner/venues/{id}/images` | Tải ảnh (multipart, tối đa 10) | O03 | MVP |
| DELETE | `/owner/venues/{id}/images/{imageId}` | Xóa ảnh | O03 | MVP |
| PUT | `/owner/venues/{id}/amenities` | Cập nhật danh sách tiện ích | O03 | MVP |
| GET / POST | `/owner/venues/{id}/courts` | Sân con | O05 | MVP |
| PUT | `/owner/courts/{courtId}` | Đổi tên sân con | O05 | MVP |
| PATCH | `/owner/courts/{courtId}/status` | `ACTIVE` / `MAINTENANCE`, trả cảnh báo nếu còn lượt đặt tương lai | O05 | GĐ2 |
| GET / PUT | `/owner/venues/{id}/price-rules` | Thay toàn bộ bảng giá (kiểm tra chồng lấn) | O06 | MVP |
| GET / PUT | `/owner/venues/{id}/operating-hours` | Giờ mở cửa 7 ngày | O07 | MVP |
| GET / PUT | `/owner/venues/{id}/cancellation-rules` | Mốc hoàn tiền | O07 | GĐ2 |
| GET / POST / PUT / DELETE | `/owner/venues/{id}/faqs[/{faqId}]` | FAQ cho chatbot | O19 | GĐ2 |
| GET | `/public/geocode?address=` | Đổi địa chỉ thành tọa độ (BE gọi Google Geocoding, giấu API key) | O04 | MVP |

### 3.8 Vận hành & doanh thu – CourtOwner

| Method | Endpoint | Mô tả | Story | Ưu tiên |
|---|---|---|---|---|
| GET | `/owner/venues/{id}/bookings?date=&courtId=` | Timeline đặt sân trong ngày | O08 | MVP |
| POST | `/owner/bookings/{id}/confirm` | Xác nhận lượt trả tại sân | O09 | GĐ2 |
| POST | `/owner/bookings/{id}/reject` | Từ chối, bắt buộc lý do | O09 | GĐ2 |
| POST | `/owner/venues/{id}/bookings` | Đặt thủ công cho khách vãng lai | O10 | GĐ2 |
| POST | `/owner/check-ins` | Body `qrToken`, xác nhận check-in | O11 | MVP |
| GET / POST | `/owner/bank-accounts` | Xem / thêm tài khoản ngân hàng (cần OTP) | O12 | GĐ2 |
| GET | `/owner/reports/revenue?from=&to=&venueId=` | Doanh thu, phí nền tảng, thực nhận | O13 | GĐ2 |
| GET | `/owner/reports/revenue/export` | Xuất Excel | O13 | GĐ2 |
| GET | `/owner/refunds` | Yêu cầu hoàn tiền | O14 | GĐ2 |
| POST | `/owner/refunds/{id}/approve` · `/reject` | Duyệt / từ chối hoàn tiền | O14 | GĐ2 |
| GET / POST / PUT | `/owner/promotions[/{id}]` | Mã khuyến mãi | O15 | GĐ2 |
| GET | `/owner/settlements` | Các kỳ đối soát | A08 | GĐ2 |

### 3.9 Admin

| Method | Endpoint | Mô tả | Story | Ưu tiên |
|---|---|---|---|---|
| GET | `/admin/owner-applications?status=` | Hồ sơ chủ sân | A02 | MVP |
| POST | `/admin/owner-applications/{id}/approve` · `/reject` | Duyệt / từ chối (bắt buộc lý do) | A02 | MVP |
| GET | `/admin/venues?status=` | Cơ sở chờ duyệt / tất cả | A05 | MVP |
| POST | `/admin/venues/{id}/approve` · `/request-changes` · `/suspend` | Kiểm duyệt cơ sở | A05, G7 | MVP |
| GET | `/admin/venues/map?province=&status=` | Dữ liệu bản đồ tổng thể (chỉ tọa độ + tên) | A06 | GĐ2 |
| GET | `/admin/customers` · `/admin/owners` | Danh sách tài khoản, tìm kiếm, lọc | A03 | GĐ2 |
| POST | `/admin/{customers\|owners}/{id}/lock` · `/unlock` | Khóa / mở khóa (bắt buộc lý do) | A03 | GĐ2 |
| GET | `/admin/login-logs?flagged=` | Log đăng nhập | A04 | GĐ2 |
| GET / PUT | `/admin/payment-gateways[/{id}]` | Cấu hình cổng | A07 | GĐ2 |
| GET / POST | `/admin/commission-configs` | % hoa hồng | A07 | GĐ2 |
| GET | `/admin/transactions` | Giao dịch toàn hệ thống | A08 | GĐ2 |
| GET / POST | `/admin/settlements` | Lập / xem đối soát | A08 | GĐ2 |
| GET | `/admin/disputes` | Tranh chấp | A09 | GĐ2 |
| POST | `/admin/disputes/{id}/resolve` | Quyết định cuối | A09 | GĐ2 |
| GET | `/admin/reviews?reported=true` | Đánh giá bị báo cáo | A13 | GĐ2 |
| POST | `/admin/reviews/{id}/hide` | Ẩn đánh giá | A13 | GĐ2 |
| GET / PUT | `/admin/ai-config` | Cấu hình chatbot | A11 | GĐ2 |
| GET | `/admin/chat-reports` | Báo cáo câu trả lời AI | A11 | GĐ2 |
| GET | `/admin/dashboard?from=&to=` | Số liệu tổng quan | A12 | GĐ2 |

## 4. Ví dụ request/response cho luồng chính

### Giữ chỗ

```http
POST /api/v1/customer/bookings
Authorization: Bearer <accessToken>

{
  "courtId": 3,
  "date": "2026-11-02",
  "startTime": "19:00",
  "endTime": "21:00",
  "paymentOption": "DEPOSIT",
  "promotionCode": null
}
```

```json
{
  "success": true,
  "data": {
    "id": 1024,
    "bookingCode": "BK-20261102-1024",
    "status": "PENDING_PAYMENT",
    "venue": { "id": 1, "name": "Sân Cầu Lông Phượng Hoàng" },
    "court": { "id": 3, "name": "Sân 3" },
    "date": "2026-11-02",
    "slots": [
      { "startTime": "19:00", "endTime": "20:00", "price": 140000 },
      { "startTime": "20:00", "endTime": "21:00", "price": 140000 }
    ],
    "totalAmount": 280000,
    "discountAmount": 0,
    "payNowAmount": 84000,
    "holdExpiresAt": "2026-11-01T15:42:00+07:00"
  }
}
```

### Đăng nhập cần OTP

```json
// POST /api/v1/auth/customer/login → thiết bị lạ
{ "success": true, "data": { "otpRequired": true, "otpTicket": "c2b1...", "channel": "EMAIL", "maskedTarget": "hu***@gmail.com" } }

// POST /api/v1/auth/customer/login/verify-otp
{ "otpTicket": "c2b1...", "code": "482915", "deviceId": "android-8f3a...", "trustDevice": true }
```
