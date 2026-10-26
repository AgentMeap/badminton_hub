# 01 – Phân công công việc

## Nguyên tắc chia việc: theo lát cắt dọc (vertical slice)

Mỗi thành viên phụ trách **trọn một chủ đề**, làm cả FE lẫn BE của chủ đề đó. Lý do:

- Mỗi người phải tự thuyết trình và demo chủ đề của mình, nên cần hiểu từ màn hình đến API đến database.
- Giảm việc chờ nhau: không có cảnh "FE xong nhưng BE chưa có API".
- Dễ chấm điểm đóng góp theo từng chủ đề.

Phần nền tảng dùng chung (khung dự án, design system, xác thực JWT) giao cho 1–2 người làm trước trong Sprint 0.

## Bảng phân công

> Điền tên thành viên vào cột "Phụ trách". Nếu nhóm ít hơn 6 người, một người nhận 2 chủ đề nhỏ (gợi ý ghép Notifications + Chat AI).

| Chủ đề | Phụ trách | Phạm vi FE | Phạm vi BE | Story chính |
|---|---|---|---|---|
| **Nền tảng chung** | `<tên>` | Khung app, router, theme, Dio client, shell theo role | Khung dự án, cấu hình, xử lý lỗi chung, Swagger, Flyway | — |
| 1. Database | `<tên>` | Màn hình quản lý sân, sân con, giá, giờ mở cửa | Entity, migration, seed, CRUD module Sân, đặt sân & chống trùng | US-O03, O05–O08, O10, C12–C15 |
| 2. Map | `<tên>` | Bản đồ sân gần tôi, ghim vị trí, chỉ đường, bản đồ Admin | API tìm sân theo bán kính, lọc, geocoding | US-C08–C11, O04, A05, A06 |
| 3. Payment | `<tên>` | Checkout, WebView thanh toán, kết quả, hoàn tiền, doanh thu | Tích hợp VNPay, IPN, hóa đơn, hoàn tiền, đối soát | US-C16–C20, O12–O15, A07–A09 |
| 4. Bảo mật tài khoản | **Đạt** | Đăng ký, đăng nhập, OTP, quên/đổi mật khẩu, hồ sơ | JWT, OTP, xác thực email, khóa tài khoản, log đăng nhập | US-C01–C07, O01, O02, A01–A04 |
| 5. Notifications | `<tên>` | Màn hình Notifications, cài đặt nhắc lịch, xử lý push | FCM, lịch nhắc, thông báo hàng loạt | US-C21–C23, O16, O17, A10 |
| 6. Chat AI | `<tên>` | Màn hình chatbot, trợ lý AI chủ sân | Gọi API mô hình AI, function calling truy vấn sân, cấu hình AI | US-C24, C25, O18, O19, A11 |

Phần Admin (duyệt hồ sơ, dashboard, kiểm duyệt đánh giá) chia theo chủ đề tương ứng: duyệt hồ sơ → Bảo mật, duyệt sân → Map, giao dịch → Payment, broadcast → Notifications, cấu hình AI → Chat AI, dashboard → Database.

## Lộ trình theo sprint (gợi ý 6 tuần)

| Sprint | Thời lượng | Mục tiêu | Kết quả demo được |
|---|---|---|---|
| 0 | 3–4 ngày | Chốt [quyết định kỹ thuật](03-quyet-dinh-ky-thuat.md), dựng khung FE/BE, Git repo, đăng ký dịch vụ bên ngoài, wireframe | App chạy được, gọi được `/api/v1/health` |
| 1 | 1 tuần | Đăng ký/đăng nhập/OTP; chủ sân tạo sân, sân con, giá; ghim bản đồ | Chủ sân tạo sân, Customer đăng ký và đăng nhập |
| 2 | 1 tuần | Bản đồ sân gần tôi, chi tiết sân, lịch trống, giữ chỗ, Admin duyệt sân | Customer chọn được khung giờ và giữ chỗ |
| 3 | 1 tuần | Thanh toán VNPay sandbox, IPN, hóa đơn email, lịch sử đặt sân, QR | Đặt sân trọn vẹn đến trạng thái *Đã xác nhận* |
| 4 | 1 tuần | Push FCM, Notifications, nhắc lịch, check-in QR, Chat AI gợi ý sân | Luồng MVP chạy đủ 6 chủ đề |
| 5 | 1 tuần | Phần giai đoạn 2 nếu kịp (hủy & hoàn tiền, doanh thu, dashboard), kiểm thử, sửa lỗi, tài liệu, slide, quay video demo | Bản nộp cuối |

Backlog chi tiết từng task:

- Backend: [badminton_be/docs/06-backlog-be.md](../badminton_be/docs/06-backlog-be.md)
- Frontend: [badminton_fe/docs/05-backlog-fe.md](../badminton_fe/docs/05-backlog-fe.md)

## Definition of Done (một task được coi là xong khi)

- [ ] Đáp ứng đủ acceptance criteria của story liên quan.
- [ ] BE: API có trên Swagger, có ít nhất 1 test cho service chính, trả lỗi đúng định dạng chung.
- [ ] FE: màn hình có đủ trạng thái loading / rỗng / lỗi, chạy được trên máy Android thật hoặc emulator.
- [ ] Không còn cảnh báo `flutter analyze` và lỗi build Gradle.
- [ ] Pull request đã được ít nhất 1 thành viên khác review và merge vào `develop`.
- [ ] Cập nhật tài liệu nếu thay đổi API hoặc database.

## Họp nhóm

| Hoạt động | Tần suất | Nội dung |
|---|---|---|
| Daily ngắn (chat nhóm) | Hằng ngày | Hôm qua làm gì, hôm nay làm gì, đang vướng gì |
| Sprint planning | Đầu sprint | Chọn task từ backlog, gán người |
| Demo + review | Cuối sprint | Mỗi người demo phần của mình trên nhánh `develop` |
