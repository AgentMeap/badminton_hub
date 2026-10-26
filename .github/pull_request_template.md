## Nội dung thay đổi

<!-- Mô tả ngắn gọn PR này làm gì -->

## Liên quan

- Task: <!-- BE-xx / FE-xx -->
- Story: <!-- US-C13, US-O05... -->
- Màn hình: <!-- C-05, O-07... (nếu là FE) -->

## Loại thay đổi

- [ ] Tính năng mới
- [ ] Sửa lỗi
- [ ] Refactor
- [ ] Tài liệu
- [ ] Database migration (thêm file `V__*.sql`)

## Cách kiểm tra

<!-- Các bước để reviewer tự chạy lại. Ví dụ: chạy BE, gọi POST /api/v1/customer/bookings trên Swagger với body ... -->

1.
2.

## Ảnh chụp màn hình (bắt buộc với PR giao diện)

| Trước | Sau |
|---|---|
|  |  |

## Checklist

- [ ] Đạt acceptance criteria của story liên quan
- [ ] BE: API hiển thị trên Swagger, lỗi trả đúng định dạng chung
- [ ] FE: có trạng thái loading / rỗng / lỗi, dùng component trong `lib/core/widgets/`
- [ ] Không commit khóa bí mật, file build, file cấu hình cá nhân
- [ ] `./gradlew build` hoặc `flutter analyze` không lỗi
- [ ] Đã cập nhật tài liệu trong `docs/` nếu đổi API hoặc database
