# 04 – Yêu cầu bổ sung để dự án hoàn chỉnh

Bộ user story và acceptance criteria hiện mô tả **chức năng**. Một dự án hoàn chỉnh còn cần các yêu cầu dưới đây. Mỗi mục có mức ưu tiên: **P1** bắt buộc cho bản nộp, **P2** nên có, **P3** điểm cộng.

## 1. Lỗ hổng trong yêu cầu hiện tại (cần bổ sung vào phân tích)

| # | Vấn đề phát hiện | Đề xuất | Ưu tiên |
|---|---|---|---|
| G1 | US-A13 nói "đánh giá bị báo cáo" nhưng chưa có story/entity cho việc báo cáo đánh giá | Thêm US-C27 "Báo cáo đánh giá vi phạm" và entity `ReviewReport` | P2 |
| G2 | Chưa có cách tạo tài khoản Admin đầu tiên | Seed 1 Admin trong migration Flyway, mật khẩu đổi ở lần đăng nhập đầu | P1 |
| G3 | Chưa định nghĩa khi nào lượt đặt chuyển sang *Hoàn thành* | Job định kỳ: lượt đã check-in và quá giờ kết thúc → `COMPLETED`; chưa check-in → `NO_SHOW` | P1 |
| G4 | Chưa có quy tắc khi giá thay đổi giữa lúc giữ chỗ và thanh toán | Chốt giá vào `BookingSlot.price` tại thời điểm giữ chỗ | P1 |
| G5 | Chưa có giới hạn số lượt giữ chỗ chưa thanh toán của một Customer | Tối đa 3 lượt `PENDING_PAYMENT` cùng lúc, tránh giữ chỗ ảo | P2 |
| G6 | Chưa quy định khung giờ đặt tối thiểu/tối đa | Tối thiểu 1 giờ, tối đa 4 giờ liên tiếp mỗi lượt | P2 |
| G7 | Chưa có xử lý khi Venue bị Admin tạm ngưng mà vẫn còn lượt đặt | Tự hủy và hoàn 100% cho các lượt tương lai, gửi thông báo | P2 |

## 2. Yêu cầu phi chức năng

| # | Nhóm | Yêu cầu | Ưu tiên |
|---|---|---|---|
| N1 | Hiệu năng | API danh sách/tìm kiếm phản hồi ≤ 2 giây với 1.000 sân; có index cho `venue(latitude, longitude)`, `booking_slot(court_id, play_date)` | P1 |
| N2 | Đồng thời | Không bao giờ có 2 lượt đặt trùng sân con + khung giờ (ràng buộc UNIQUE + transaction) | P1 |
| N3 | Bảo mật | Mật khẩu băm BCrypt; OTP băm; mọi khóa API nằm ngoài source code; HTTPS khi deploy | P1 |
| N4 | Bảo mật | Rate limit cho API đăng nhập, gửi OTP, chatbot | P2 |
| N5 | Bảo mật | Kiểm tra quyền sở hữu: chủ sân A không sửa được sân của chủ sân B (lỗi IDOR) | P1 |
| N6 | Dữ liệu | Thời gian lưu UTC trong DB, hiển thị theo `Asia/Ho_Chi_Minh` | P1 |
| N7 | Khả dụng | App hoạt động khi mạng chập chờn: hiển thị lỗi thân thiện, nút thử lại, không crash | P1 |
| N8 | Ngôn ngữ | Toàn bộ giao diện tiếng Việt, chuỗi tập trung một chỗ để dễ thêm tiếng Anh | P2 |
| N9 | Trải nghiệm | Chữ có độ tương phản đủ đọc, vùng chạm ≥ 48dp | P2 |
| N10 | Log | BE ghi log có `traceId` cho mỗi request; không log mật khẩu, OTP, token | P2 |

## 3. Kiểm thử

| # | Loại | Nội dung tối thiểu | Ưu tiên |
|---|---|---|---|
| T1 | Unit test BE | Service: tính giá, tính tiền hoàn, kiểm tra OTP, kiểm tra chữ ký VNPay | P1 |
| T2 | Integration test BE | Hai request đặt cùng khung giờ song song → chỉ 1 thành công | P1 |
| T3 | Postman collection | Đủ các luồng MVP, lưu ở `badminton_be/postman/` | P1 |
| T4 | Widget test FE | Form đăng ký, đăng nhập (validate dữ liệu) | P2 |
| T5 | Kiểm thử thủ công | Checklist theo acceptance criteria trước mỗi lần demo | P1 |

## 4. Môi trường, cấu hình và triển khai

| # | Yêu cầu | Ưu tiên |
|---|---|---|
| E1 | Tách cấu hình theo profile: `application.properties` (chung), `application-local.properties` (không commit), có file mẫu `application-local.example.properties` | P1 |
| E2 | FE nhận `API_BASE_URL` qua `--dart-define`, không hard-code | P1 |
| E3 | Seed dữ liệu demo: 3 tài khoản mẫu cho 3 role, 8 cơ sở sân, vài lượt đặt mẫu | P1 |
| E4 | Hướng dẫn cài đặt từ đầu trong README của FE và BE (người mới clone về chạy được trong 30 phút) | P1 |
| E5 | Deploy BE lên một dịch vụ online cho ngày demo; build file APK để phát cho lớp | P2 |
| E6 | GitHub Actions: build Gradle + `flutter analyze` mỗi khi mở PR | P3 |
| E7 | Docker Compose chạy SQL Server + BE bằng một lệnh | P3 |

## 5. Sản phẩm nộp theo đề bài

| Hạng mục đề bài | Cụ thể cần chuẩn bị | Ưu tiên |
|---|---|---|
| Dự án demo | Source FE + BE trên GitHub, file APK, video demo dự phòng 3–5 phút | P1 |
| Tài liệu hướng dẫn | Mỗi chủ đề 1 hướng dẫn từng bước (trang HTML trên GitHub Pages hoặc Markdown), kèm 2–3 bài lab | P1 |
| Link và mã QR chia sẻ | QR dẫn tới repo, trang hướng dẫn và file APK | P1 |
| Slide trình bày | Mỗi chủ đề: khái niệm → cách làm → demo, theo đúng dàn ý đề bài | P1 |

## 6. Thiết kế cần có trước khi code nhiều

| # | Tài liệu | Người làm | Ưu tiên |
|---|---|---|---|
| X1 | ERD đầy đủ | Phụ trách Database | P1 |
| X2 | Wireframe/mockup Figma cho các màn hình MVP | Phụ trách FE từng chủ đề | P1 |
| X3 | Sequence diagram cho 3 luồng khó: đăng nhập OTP, thanh toán VNPay (có IPN), push notification | Phụ trách chủ đề tương ứng | P2 |
| X4 | State diagram trạng thái `Booking` | Phụ trách Database | P2 |
