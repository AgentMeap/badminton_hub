# 02 – Design System

Mục tiêu: 6 người cùng làm nhưng app nhìn như do một người làm. Mọi màu, cỡ chữ, khoảng cách lấy từ `lib/core/theme/`, **không hard-code** trong màn hình.

Bản thiết kế chính đặt trên Figma (một file chung của nhóm, mỗi role một page). Dán link Figma vào đây: `<link Figma>`

## 1. Màu

Dùng Material 3 với màu chủ đạo xanh lá (gợi mặt sân), sinh bảng màu bằng `ColorScheme.fromSeed`.

| Token | Giá trị | Dùng cho |
|---|---|---|
| `seed` / primary | `#1B8A5A` | Nút chính, tab đang chọn, marker sân |
| secondary | `#F4A62A` | Điểm nhấn, khuyến mãi, sao đánh giá |
| error | `#D93025` | Lỗi, nút hủy, thao tác nguy hiểm |
| surface | `#FFFFFF` / `#121212` (tối) | Nền |

### Màu trạng thái (dùng thống nhất cho chip, ô lịch, timeline)

| Trạng thái | Nền | Chữ | Áp dụng |
|---|---|---|---|
| Trống / Hoạt động / Đã xác nhận | `#E2EFDA` | `#2E7D32` | Ô lịch, venue `ACTIVE`, booking `CONFIRMED` |
| Chờ (thanh toán, xác nhận, duyệt) | `#FFF2CC` | `#8A6D00` | `PENDING_*` |
| Bảo trì / Đã đặt | `#FCE4D6` | `#B85C00` | Court `MAINTENANCE`, ô đã có người đặt |
| Tạm ngưng / Đã hủy / Thất bại | `#F8CBAD` | `#B3261E` | `SUSPENDED`, `CANCELLED` |
| Nháp / Đã qua / Vắng mặt | `#EDEDED` | `#616161` | `DRAFT`, ô quá giờ, `NO_SHOW` |
| Đã check-in / Hoàn thành | `#DDEBF7` | `#1F4E78` | `CHECKED_IN`, `COMPLETED` |

Không dùng màu làm tín hiệu duy nhất: chip luôn có chữ, ô lịch có biểu tượng hoặc mô tả khi chạm.

## 2. Chữ

Font **Be Vietnam Pro** (Google Fonts, hiển thị tiếng Việt tốt), khai báo qua `TextTheme`.

| Style | Cỡ / độ đậm | Dùng cho |
|---|---|---|
| headlineSmall | 24 / SemiBold | Tiêu đề màn hình lớn |
| titleLarge | 20 / SemiBold | Tên sân, tiêu đề section |
| titleMedium | 16 / Medium | Tiêu đề thẻ |
| bodyLarge | 16 / Regular | Nội dung chính |
| bodyMedium | 14 / Regular | Nội dung phụ |
| labelLarge | 14 / SemiBold | Nút |
| labelSmall | 11 / Medium | Chip, chú thích |

Số tiền dùng `fontFeatures: [FontFeature.tabularFigures()]` để các số thẳng cột.

## 3. Khoảng cách, bo góc, kích thước

| Token | Giá trị |
|---|---|
| Spacing | Bội số của 4: `4, 8, 12, 16, 24, 32` (lề màn hình 16) |
| Bo góc | Nút, ô nhập 12 · Thẻ 16 · Bottom sheet 24 (góc trên) |
| Vùng chạm tối thiểu | 48 × 48 dp |
| Ảnh sân | Tỷ lệ 16:9 |

## 4. Component dùng chung (`lib/core/widgets/`)

| Component | Mô tả | Người làm (Sprint 0) |
|---|---|---|
| `AppButton` | primary / secondary / text / danger, trạng thái loading | Nền tảng chung |
| `AppTextField` | Label, gợi ý, lỗi, ẩn/hiện mật khẩu | Nền tảng chung |
| `OtpInput` | 6 ô, dán mã, đếm ngược, gửi lại | Bảo mật |
| `StatusChip` | Nhận enum trạng thái, tự chọn màu theo bảng trên | Nền tảng chung |
| `VenueCard` | Ảnh, tên, khoảng cách, giá từ, rating | Map |
| `PriceText` | Định dạng `140.000đ` | Nền tảng chung |
| `AsyncView` | Bọc `AsyncValue` của Riverpod: loading / error (nút thử lại) / empty / data | Nền tảng chung |
| `EmptyState` | Minh họa + câu hướng dẫn + nút hành động | Nền tảng chung |
| `ConfirmDialog` | Hộp xác nhận cho thao tác không hoàn tác được | Nền tảng chung |
| `SlotGrid` | Lưới sân con × khung giờ, dùng ở C-05 và O-10 | Database |

## 5. Văn phong giao diện

- Tiếng Việt, xưng "bạn", câu ngắn, động từ ở đầu nút: "Đặt sân", "Thanh toán", "Gửi lại mã".
- Thông báo lỗi nói điều người dùng làm được tiếp: "Khung giờ vừa có người đặt. Hãy chọn khung giờ khác."
- Chuỗi giao diện gom vào một file (`lib/core/l10n/strings.dart` hoặc `intl` ARB) để dễ thêm tiếng Anh.
