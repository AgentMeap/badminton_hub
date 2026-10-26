# 04 – Luồng điều hướng

ID màn hình tra ở [03-danh-sach-man-hinh.md](03-danh-sach-man-hinh.md).

## 1. Vào app và xác thực (MF1)

```mermaid
flowchart TD
    S01[S-01 Splash] -->|còn phiên| Shell{Role trong token}
    S01 -->|hết phiên| S02[S-02 Đăng nhập]
    S02 -->|Đăng ký người chơi| S03[S-03 Đăng ký]
    S02 -->|Đăng ký chủ sân| O01[O-01 Đăng ký chủ sân]
    S03 --> S04a[S-04 OTP xác thực email]
    O01 --> S04a
    S04a -->|Customer| Shell
    S04a -->|Owner| O02[O-02 Trạng thái hồ sơ]
    O02 -->|đã duyệt| Shell
    S02 -->|đúng, thiết bị quen| Shell
    S02 -->|thiết bị lạ / Owner / Admin| S04b[S-04 OTP đăng nhập] --> Shell
    S02 -->|Quên mật khẩu| S05[S-05] --> S04c[S-04 OTP] --> S06[S-06 Mật khẩu mới] --> S02
    Shell -->|CUSTOMER| CS[Customer shell: C-01]
    Shell -->|OWNER| OS[Owner shell: O-03]
    Shell -->|ADMIN| AS[Admin shell: A-01]
```

## 2. Customer – Đặt sân & thanh toán (MF2, luồng demo chính)

```mermaid
flowchart TD
    C01[C-01 Bản đồ] -->|lọc| C02[C-02 Bộ lọc] --> C01
    C13[C-13 Chat AI] -->|Đặt ngay| C05
    C01 -->|chạm thẻ sân| C03[C-03 Chi tiết sân]
    C03 -->|Chỉ đường| GM[[Ứng dụng Google Maps]]
    C03 -->|Đặt sân| C05[C-05 Chọn khung giờ]
    C05 -->|giữ chỗ OK| C07[C-07 Xác nhận & thanh toán]
    C05 -->|409 trùng giờ| C05
    C07 -->|PayOS VietQR| C08[C-08 Thanh toán PayOS]
    C07 -->|Trả tại sân| C10
    C08 -->|thành công| C10[C-10 Chi tiết lượt đặt + QR]
    C08 -->|thất bại, còn giữ chỗ| C07
    C07 -->|hết 10 phút| C05
    PUSH[[Push: Đặt sân thành công]] --> C10
```

## 3. Customer – Sau khi đặt (MF3, MF4)

```mermaid
flowchart LR
    C09[C-09 Lịch đặt của tôi] --> C10[C-10 Chi tiết lượt đặt]
    REM[[Push nhắc lịch]] --> C10
    C10 -->|Hủy| C11[C-11 Hủy lượt đặt] --> C09
    C10 -->|sau khi chơi| C12[C-12 Đánh giá]
    C14[C-14 Tài khoản] --> C16[C-16 Hoàn tiền & khiếu nại]
    C14 --> C15[C-15 Sửa hồ sơ]
    C14 --> S07[S-07 Đổi mật khẩu]
    C14 --> S09[S-09 Cài đặt thông báo]
```

## 4. CourtOwner – Đưa sân lên và vận hành (MF5, MF6)

```mermaid
flowchart TD
    O04[O-04 Cơ sở của tôi] -->|Thêm| O05[O-05 Tạo cơ sở]
    O05 --> O06[O-06 Ghim vị trí]
    O05 --> O07[O-07 Sân con]
    O05 --> O08[O-08 Giá & giờ mở cửa]
    O05 --> O09[O-09 Chính sách hủy & FAQ]
    O05 -->|Gửi duyệt| WAIT((Chờ Admin A-03))
    O03[O-03 Hôm nay] --> O13[O-13 Quét QR]
    O03 --> O10[O-10 Timeline] --> O11[O-11 Chi tiết lượt đặt]
    O10 -->|ô trống| O12[O-12 Đặt thủ công]
    PUSH[[Push: lượt đặt mới]] --> O11
```

## 5. Admin – Duyệt (phần MVP của MF5)

```mermaid
flowchart LR
    A01[A-01 Tổng quan] --> A02[A-02 Duyệt hồ sơ chủ sân]
    A01 --> A03[A-03 Duyệt cơ sở sân]
    A02 -->|Duyệt| N1[[Push + email cho chủ sân]]
    A03 -->|Duyệt| LIVE((Sân hiện trên C-01))
    A03 -->|Yêu cầu sửa| N2[[Thông báo chủ sân]]
```

## 6. Điều hướng khi chạm thông báo

| `data.type` | Mở màn hình |
|---|---|
| `BOOKING` | C-10 (Customer) / O-11 (Owner) |
| `REFUND` | C-16 / O-15 |
| `OWNER_APPLICATION` | O-02 |
| `VENUE_REVIEW` | O-05 |
| `ANNOUNCEMENT` | S-08 (mở rộng nội dung) |
