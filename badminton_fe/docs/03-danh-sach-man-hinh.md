# 03 – Danh sách màn hình

Tổng cộng **56 màn hình**: 9 dùng chung (S), 16 Customer (C), 19 CourtOwner (O), 12 Admin (A). Đường dẫn API viết tắt, bỏ tiền tố `/api/v1`. Cột **Ưu tiên**: MVP hoặc GĐ2.

**Yêu cầu chung cho mọi màn hình có tải dữ liệu:** có trạng thái loading (skeleton hoặc spinner), trạng thái rỗng (minh họa + câu hướng dẫn), trạng thái lỗi (thông điệp + nút "Thử lại"), và kéo xuống để làm mới với màn hình danh sách.

## 1. Dùng chung (S)

| ID | Màn hình | Thành phần chính | API | Story | Ưu tiên |
|---|---|---|---|---|---|
| S-01 | Splash | Logo; kiểm tra refresh token để vào thẳng shell theo role hoặc về S-02 | `POST /auth/refresh` | C03 | MVP |
| S-02 | Đăng nhập | Chọn "Người chơi / Chủ sân", email, mật khẩu (ẩn/hiện), nút Google (Customer), link Quên mật khẩu, link Đăng ký | `POST /auth/{actor}/login`, `/auth/customer/google` | C03, O02, A01 | MVP |
| S-03 | Đăng ký Customer | Họ tên, email, SĐT, mật khẩu (đo độ mạnh), nhập lại mật khẩu, validate theo AC | `POST /auth/customer/register` | C01 | MVP |
| S-04 | Nhập OTP | 6 ô mã, đếm ngược hết hạn, nút "Gửi lại" sau 60 giây, hiện email đã che (`hu***@gmail.com`), checkbox "Tin cậy thiết bị này". Dùng chung cho xác thực email, đăng nhập, đặt lại và đổi mật khẩu | `/auth/{actor}/verify-email`, `/auth/{actor}/login/verify-otp` | C02, C04, C05, C07 | MVP |
| S-05 | Quên mật khẩu | Nhập email → luôn báo "Nếu email tồn tại, mã đã được gửi" | `POST /auth/{actor}/forgot-password` | C05 | MVP |
| S-06 | Đặt lại mật khẩu | Mật khẩu mới + nhập lại (sau S-04) | `POST /auth/{actor}/reset-password` | C05 | MVP |
| S-07 | Đổi mật khẩu | Mật khẩu hiện tại, mới, nhập lại → S-04 | `/{actor}/me/password/otp`, `PUT /{actor}/me/password` | C07 | GĐ2 |
| S-08 | Thông báo | Danh sách mới nhất trước, chấm xanh chưa đọc, "Đánh dấu tất cả đã đọc", chạm để điều hướng theo `type`; app đang mở thì hiện banner khi có push mới | `GET /{actor}/notifications`, `PATCH .../read`, `.../read-all` | C21, C23 | MVP |
| S-09 | Cài đặt thông báo | Customer: thời gian nhắc (30/60/120 phút/tắt). Owner: bật/tắt từng loại | `/{actor}/notification-settings` | C22, O16 | MVP |

## 2. Customer (C)

| ID | Màn hình | Thành phần chính | API | Story | Ưu tiên |
|---|---|---|---|---|---|
| C-01 | Khám phá (bản đồ) | Google Map + marker sân, nút "Vị trí của tôi", thanh tìm kiếm, chip bán kính (2/5/10 km), nút chuyển dạng danh sách; chạm marker → card tóm tắt (tên, giá từ, khoảng cách, rating). Bị từ chối quyền vị trí → nhập địa chỉ | `GET /public/venues?lat&lng&radiusKm` | C08 | MVP |
| C-02 | Bộ lọc (bottom sheet) | Khu vực, khoảng giá (slider), ngày + giờ, tiện ích (chip), sắp xếp. Kết quả rỗng → gợi ý nới bộ lọc | `GET /public/venues?...`, `GET /public/amenities` | C09 | MVP |
| C-03 | Chi tiết sân | Carousel ảnh, tên, rating, địa chỉ + nút "Chỉ đường", giờ mở cửa, bảng giá theo khung giờ, tiện ích, chính sách hủy, FAQ thu gọn, nút cố định "Đặt sân" | `GET /public/venues/{id}` | C10, C11 | MVP |
| C-04 | Đánh giá của sân | Điểm trung bình, phân bố sao, danh sách đánh giá | `GET /public/venues/{id}/reviews` | C10 | GĐ2 |
| C-05 | Chọn khung giờ | Chọn ngày (dải 14 ngày), lưới sân con × giờ có màu Trống/Đã đặt/Bảo trì/Đã qua, chọn nhiều ô liên tiếp cùng sân, thanh dưới hiện tổng giờ + tổng tiền, nút "Tiếp tục" | `GET /public/venues/{id}/availability?date` | C12, C13 | MVP |
| C-06 | Đặt định kỳ | Chọn thứ, khung giờ, số tuần; xem trước danh sách buổi, buổi trùng gạch đỏ | `/customer/bookings/recurring[/preview]` | C14 | GĐ2 |
| C-07 | Xác nhận & thanh toán | Tóm tắt lượt đặt, đồng hồ đếm ngược giữ chỗ 10 phút, ô mã giảm giá, chọn Thanh toán đủ / Đặt cọc X% / Trả tại sân, chọn cổng (PayOS VietQR), tổng tiền | `POST /customer/bookings`, `/customer/promotions/validate`, `POST /customer/bookings/{id}/payments` | C13, C17, C18, C20 | MVP |
| C-08 | Thanh toán PayOS VietQR | Cổng PayOS hiển thị mã VietQR động, ngân hàng, STK, nội dung CK kèm nút sao chép; bắt return URL / Webhook; hiện kết quả Thành công (mã lượt đặt, nút "Xem vé & QR") hoặc Thất bại (nút "Thanh toán lại" nếu còn thời gian giữ chỗ) | `GET /customer/payments/{id}` | C17 | MVP |
| C-09 | Lịch đặt của tôi | 3 tab Sắp tới / Đã qua / Đã hủy; mỗi thẻ: sân, ngày giờ, số tiền, chip trạng thái | `GET /customer/bookings?tab=` | C15 | MVP |
| C-10 | Chi tiết lượt đặt | Mã QR check-in (độ sáng tối đa khi mở), thông tin sân, khung giờ, thanh toán, nút Chỉ đường / Hủy / Đánh giá / Thanh toán phần còn lại / Xem hóa đơn tùy trạng thái | `GET /customer/bookings/{id}`, `GET /customer/payments/{id}/invoice` | C15, C11, C18, C19 | MVP |
| C-11 | Hủy lượt đặt (bottom sheet) | Số tiền được hoàn theo chính sách, lý do hủy, nút xác nhận | `/customer/bookings/{id}/cancel-preview`, `/cancel` | C16 | GĐ2 |
| C-12 | Viết đánh giá | Chọn 1–5 sao, nhận xét ≤ 500 ký tự (đếm ký tự) | `POST /customer/bookings/{id}/review`, `PUT /customer/reviews/{id}` | C26 | GĐ2 |
| C-13 | Chat AI | Khung chat, gợi ý câu hỏi nhanh ("Tối nay 7h còn sân nào gần tôi?"), câu trả lời có thể kèm thẻ sân + nút "Đặt ngay" → C-05, nút báo cáo trên từng câu trả lời, hiệu ứng "đang trả lời" | `/customer/chat/sessions`, `.../messages` | C24, C25 | MVP |
| C-14 | Tài khoản | Avatar, tên, menu: Sửa hồ sơ, Đổi mật khẩu, Cài đặt thông báo, Hoàn tiền & khiếu nại, Đăng xuất | `GET /customer/me` | C06 | MVP |
| C-15 | Sửa hồ sơ | Ảnh đại diện (chọn ảnh ≤ 5 MB), họ tên, SĐT; email chỉ xem | `PUT /customer/me`, `POST /customer/me/avatar` | C06 | GĐ2 |
| C-16 | Hoàn tiền & khiếu nại | Danh sách yêu cầu hoàn tiền + trạng thái, nút "Khiếu nại lên Admin" | `GET /customer/refunds`, `POST .../dispute` | C16, A09 | GĐ2 |

## 3. CourtOwner (O)

| ID | Màn hình | Thành phần chính | API | Story | Ưu tiên |
|---|---|---|---|---|---|
| O-01 | Đăng ký chủ sân | Bước 1: thông tin cá nhân. Bước 2: tên cơ sở + tải giấy phép (pdf/jpg ≤ 10 MB) | `POST /auth/owner/register` | O01 | MVP |
| O-02 | Trạng thái hồ sơ | Chờ duyệt / Bị từ chối (lý do + nút nộp lại) / Đã duyệt → vào shell | `GET /owner/applications/latest` | O01 | MVP |
| O-03 | Hôm nay | Số lượt đặt hôm nay theo trạng thái, danh sách lượt sắp tới, nút lớn "Quét QR check-in", lượt chờ xác nhận | `GET /owner/venues/{id}/bookings?date=today` | O08 | MVP |
| O-04 | Cơ sở sân của tôi | Thẻ từng cơ sở + chip trạng thái (Nháp/Chờ duyệt/Hoạt động/Tạm ngưng), nút thêm cơ sở | `GET /owner/venues` | O03 | MVP |
| O-05 | Tạo / sửa cơ sở | Tên, địa chỉ, mô tả, ảnh (tối đa 10, kéo để sắp xếp), tiện ích, % cọc; nút "Gửi duyệt" khi đủ thông tin | `/owner/venues[/{id}]`, `/images`, `/amenities`, `/submit` | O03 | MVP |
| O-06 | Ghim vị trí | Bản đồ có marker kéo được, ô địa chỉ tự đặt marker (geocode), nút xác nhận | `GET /public/geocode`, `PUT /owner/venues/{id}` | O04 | MVP |
| O-07 | Sân con | Danh sách sân con, thêm/đổi tên, công tắc Hoạt động/Bảo trì (cảnh báo khi còn lượt đặt tương lai) | `/owner/venues/{id}/courts`, `/owner/courts/{id}[/status]` | O05 | MVP |
| O-08 | Bảng giá & giờ mở cửa | Tab Ngày thường / Cuối tuần: các khung giờ + giá (báo lỗi chồng lấn ngay khi nhập); giờ mở/đóng 7 ngày, công tắc nghỉ | `/owner/venues/{id}/price-rules`, `/operating-hours` | O06, O07 | MVP |
| O-09 | Chính sách hủy & FAQ | Các mốc giờ + % hoàn; danh sách FAQ thêm/sửa/xóa | `/cancellation-rules`, `/faqs` | O07, O19 | GĐ2 |
| O-10 | Timeline đặt sân | Chọn ngày, trục giờ ngang × sân con dọc, khối màu theo trạng thái, lọc sân con | `GET /owner/venues/{id}/bookings?date&courtId` | O08 | MVP |
| O-11 | Chi tiết lượt đặt (Owner) | Tên khách, SĐT (bấm gọi), khung giờ, thanh toán; nút Xác nhận / Từ chối (nhập lý do) | `/owner/bookings/{id}/confirm`, `/reject` | O09 | GĐ2 |
| O-12 | Đặt thủ công | Chọn sân con + khung trống, tên + SĐT khách, đã trả tiền mặt hay chưa | `POST /owner/venues/{id}/bookings` | O10 | GĐ2 |
| O-13 | Quét QR check-in | Camera quét, rung + kết quả xanh/đỏ kèm lý do (sai cơ sở, hết hạn, đã dùng) | `POST /owner/check-ins` | O11 | MVP |
| O-14 | Doanh thu | Chọn khoảng ngày + cơ sở, biểu đồ cột theo ngày, tổng doanh thu / phí nền tảng / thực nhận, nút xuất Excel | `GET /owner/reports/revenue[/export]` | O13 | GĐ2 |
| O-15 | Yêu cầu hoàn tiền | Danh sách, số tiền đề xuất, duyệt / từ chối | `/owner/refunds` | O14 | GĐ2 |
| O-16 | Khuyến mãi | Danh sách mã + form tạo (loại, giá trị, thời hạn, lượt, đơn tối thiểu, khung giờ) | `/owner/promotions` | O15 | GĐ2 |
| O-17 | Gửi thông báo cho khách | Chọn sân con + khoảng thời gian, nội dung ≤ 500 ký tự, số khách sẽ nhận | `POST /owner/announcements` | O17 | GĐ2 |
| O-18 | Trợ lý AI | Khung chat giống C-13, câu hỏi gợi ý về doanh thu/khung giờ vắng | `POST /owner/assistant/messages` | O18 | GĐ2 |
| O-19 | Tài khoản ngân hàng | Ngân hàng, số tài khoản (hiển thị che), chủ tài khoản; lưu cần OTP (S-04) | `/owner/bank-accounts` | O12 | GĐ2 |

## 4. Admin (A)

| ID | Màn hình | Thành phần chính | API | Story | Ưu tiên |
|---|---|---|---|---|---|
| A-01 | Tổng quan | Thẻ số liệu (người dùng mới, lượt đặt, doanh thu, tỷ lệ hủy), biểu đồ theo ngày, top sân | `GET /admin/dashboard` | A12 | GĐ2 |
| A-02 | Duyệt hồ sơ chủ sân | Danh sách chờ duyệt → chi tiết: thông tin + xem giấy phép; Duyệt / Từ chối (bắt buộc lý do) | `/admin/owner-applications` | A02 | MVP |
| A-03 | Duyệt cơ sở sân | Danh sách chờ duyệt → chi tiết: ảnh, thông tin, bản đồ marker đặt cạnh địa chỉ; Duyệt / Yêu cầu sửa / Tạm ngưng | `/admin/venues` | A05 | MVP |
| A-04 | Bản đồ tổng thể | Bản đồ gom cụm marker, lọc tỉnh/trạng thái | `GET /admin/venues/map` | A06 | GĐ2 |
| A-05 | Quản lý tài khoản | Tab Customer / Chủ sân, tìm kiếm, lọc trạng thái, khóa/mở khóa có lý do | `/admin/customers`, `/admin/owners` | A03 | GĐ2 |
| A-06 | Log đăng nhập | Danh sách, lọc "bất thường", nút khóa nhanh | `GET /admin/login-logs` | A04 | GĐ2 |
| A-07 | Giao dịch & đối soát | Danh sách giao dịch có lọc; tab đối soát theo kỳ, giao dịch lệch gắn cờ | `/admin/transactions`, `/admin/settlements` | A08 | GĐ2 |
| A-08 | Tranh chấp | Danh sách → chi tiết lịch sử lượt đặt, giao dịch; quyết định hoàn toàn bộ / một phần / từ chối | `/admin/disputes` | A09 | GĐ2 |
| A-09 | Kiểm duyệt đánh giá | Đánh giá bị báo cáo, ẩn kèm lý do | `/admin/reviews` | A13 | GĐ2 |
| A-10 | Thông báo hàng loạt | Đối tượng, tiêu đề, nội dung, xem trước, hẹn giờ; lịch sử + thống kê | `/admin/announcements` | A10 | GĐ2 |
| A-11 | Cấu hình AI | System prompt, chủ đề chặn, giới hạn tin nhắn, bật/tắt; tab báo cáo câu trả lời | `/admin/ai-config`, `/admin/chat-reports` | A11 | GĐ2 |
| A-12 | Cổng thanh toán & hoa hồng | Bật/tắt cổng, cập nhật khóa (ô mật khẩu, không hiển thị lại), % hoa hồng + ngày hiệu lực | `/admin/payment-gateways`, `/admin/commission-configs` | A07 | GĐ2 |

## 5. Màn hình MVP cần thiết kế trước (Sprint 0–1)

S-01 → S-06, S-08, C-01, C-03, C-05, C-07, C-08, C-09, C-10, C-13, O-01 → O-08, O-10, O-13, A-02, A-03.
