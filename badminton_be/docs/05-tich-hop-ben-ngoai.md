# 05 – Tích hợp dịch vụ bên ngoài

Mọi khóa API đặt trong cấu hình, **không commit lên Git**. Mỗi tích hợp bọc sau một interface để có thể thay bằng bản giả (mock) khi chưa có khóa:

```java
public interface PaymentGatewayClient { String createPaymentUrl(Payment p); boolean verifySignature(Map<String,String> params); }
public interface PushSender { void send(String fcmToken, String title, String body, Map<String,String> data); }
public interface MailSender { void sendOtp(String to, String code, OtpPurpose purpose); }
public interface AiClient { AiReply chat(List<ChatTurn> history, List<ToolDefinition> tools); }
```

## 1. VNPay sandbox (chủ đề 3)

| Bước | Ai làm | Ghi chú |
|---|---|---|
| 1 | Đăng ký tài khoản sandbox VNPay | Nhận `vnp_TmnCode`, `vnp_HashSecret` |
| 2 | App gọi `POST /customer/bookings/{id}/payments` | BE tạo `Payment(PENDING)`, ký tham số bằng HMAC-SHA512, trả `paymentUrl` |
| 3 | App mở `paymentUrl` trong WebView | Người dùng nhập thẻ test của VNPay |
| 4 | VNPay gọi **IPN** `GET /webhooks/vnpay/ipn` | BE kiểm tra chữ ký, số tiền, trạng thái; cập nhật `Payment` và `Booking` trong một transaction; trả `RspCode=00` |
| 5 | VNPay chuyển trình duyệt về `return URL` | App bắt URL này trong WebView, đóng WebView, gọi `GET /customer/payments/{id}` để lấy trạng thái thật |

Lưu ý:

- **Chỉ IPN được cập nhật trạng thái thanh toán.** Return URL có thể bị giả mạo.
- IPN phải idempotent: VNPay có thể gọi lại nhiều lần.
- Khi dev ở máy cá nhân, chạy `ngrok http 8080` và khai báo URL IPN của ngrok trong cổng sandbox.

## 2. Firebase Cloud Messaging (chủ đề 5)

- Tạo Firebase project, thêm app Android, tải `google-services.json` cho FE.
- BE dùng Firebase Admin SDK với file service account (đặt ngoài source, đường dẫn trong cấu hình).
- Luồng: app đăng nhập → lấy FCM token → `POST /{actor}/device-tokens`. Sự kiện nghiệp vụ (đặt sân thành công…) → `NotificationService` lưu bảng `notification` **và** gửi push.
- Payload `data` luôn có `type` và `targetId` (ví dụ `type=BOOKING`, `targetId=1024`) để app mở đúng màn hình khi người dùng chạm.

## 3. SMTP Gmail (chủ đề 4)

- Bật xác minh 2 bước cho Gmail dùng gửi, tạo **App Password**.
- `spring-boot-starter-mail`, host `smtp.gmail.com`, port 587, STARTTLS.
- Gửi mail bất đồng bộ (`@Async`) để API không chờ SMTP.
- Mẫu email (OTP, hóa đơn, cảnh báo) đặt trong `resources/templates/mail/`.

## 4. Google Maps (chủ đề 2)

| Thành phần | Ai gọi | API của Google |
|---|---|---|
| Hiển thị bản đồ, marker | FE | Maps SDK for Android |
| Đổi địa chỉ ↔ tọa độ | BE (`/public/geocode`) | Geocoding API (giấu key trên server) |
| Chỉ đường | FE mở ứng dụng Google Maps qua URL `https://www.google.com/maps/dir/?api=1&destination=lat,lng` | Không cần key |
| Tìm sân gần tôi | BE tự tính bằng Haversine | Không cần Google |

Giới hạn API key theo package name + SHA-1 của app Android.

## 5. Mô hình AI (chủ đề 6)

Chatbot dùng **function calling** để không bịa dữ liệu (US-C24):

1. BE gửi câu hỏi của người dùng kèm danh sách *tool* mà AI được phép gọi:
   - `search_venues(lat, lng, radiusKm, date, startTime, maxPrice)`
   - `get_venue_policy(venueId)` (giờ mở cửa, chính sách hủy, FAQ)
2. AI trả về yêu cầu gọi tool kèm tham số.
3. BE chạy truy vấn thật trong DB, gửi kết quả lại cho AI.
4. AI viết câu trả lời tiếng Việt; BE trả cho app cả câu trả lời **và** danh sách sân dạng cấu trúc để app vẽ nút "Đặt ngay".

| Cấu hình (`ai_config`) | Ý nghĩa |
|---|---|
| `systemPrompt` | Vai trò: trợ lý đặt sân, chỉ trả lời về sân cầu lông và nền tảng |
| `blockedTopics` | Chủ đề từ chối trả lời |
| `dailyMessageLimit` | Giới hạn tin nhắn/ngày/người, kiểm soát chi phí |
| `isEnabled` | Tắt chatbot khi cần |

Trợ lý AI cho chủ sân (US-O18) dùng cùng cơ chế với tool `get_revenue(ownerId, from, to)`, `get_occupancy(venueId, from, to)`, trong đó `ownerId` lấy từ token chứ không lấy từ AI.
