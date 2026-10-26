# Hướng dẫn đóng góp

Quy ước đầy đủ nằm ở [docs/02-quy-uoc-lam-viec.md](docs/02-quy-uoc-lam-viec.md). Tóm tắt:

1. Nhận task trong backlog ([BE](badminton_be/docs/06-backlog-be.md), [FE](badminton_fe/docs/05-backlog-fe.md)) hoặc trong GitHub Issues.
2. Tạo nhánh từ `develop`:

   ```bash
   git checkout develop
   git pull
   git checkout -b feature/BE-12-otp-login
   ```

3. Commit theo Conventional Commits, kèm ID task:

   ```
   feat(auth): gửi OTP khi đăng nhập thiết bị mới [BE-12]
   ```

4. Push và mở Pull Request vào `develop`, điền đủ mẫu PR.
5. Cần ít nhất 1 người review trước khi merge. Không push thẳng lên `main` hay `develop`.

Không bao giờ commit khóa bí mật (mật khẩu DB, JWT secret, khóa VNPay, khóa AI, `google-services.json`). Nếu lỡ commit, báo nhóm ngay để đổi khóa; xóa file trong commit sau là chưa đủ vì khóa vẫn còn trong lịch sử Git.
