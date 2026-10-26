# 05 – Hướng dẫn đưa dự án lên GitHub lần đầu

Chạy trong **Git Bash** hoặc **PowerShell**, tại thư mục `D:\badminton`. Chỉ một người (trưởng nhóm) làm các bước này; các thành viên khác chỉ cần `git clone`.

## 1. Tạo repo trống trên GitHub

Vào https://github.com/new, đặt tên (ví dụ `badminton`), chọn Private hoặc Public. **Không** tick "Add a README", ".gitignore" hay "license", vì repo đã có sẵn các file này.

## 2. Cấu hình Git (chỉ làm một lần trên máy)

```bash
git config --global user.name "Nguyen Huu Dat"
git config --global user.email "email-dang-ky-github@example.com"
git config --global core.autocrlf true      # Windows: tự đổi xuống dòng khi checkout
git config --global init.defaultBranch main
```

## 3. Khởi tạo repo và kiểm tra trước khi commit

```bash
cd /d/badminton            # PowerShell: cd D:\badminton
git init
git add .
git status
```

Đọc kỹ danh sách `git status`. **Không được xuất hiện:**

| Không được có | Vì sao |
|---|---|
| `badminton_fe/build/`, `badminton_be/build/`, `.gradle/`, `.dart_tool/`, `bin/` | File build, rất nặng, máy khác tự sinh lại |
| `.idea/`, `*.iml` | Cấu hình IDE cá nhân |
| `android/local.properties` | Chứa đường dẫn SDK trên máy bạn |
| `application-local.properties`, `google-services.json`, `.env`, `*.jks` | Khóa bí mật |

Kiểm tra nhanh một file có bị bỏ qua không và do dòng nào trong `.gitignore`:

```bash
git check-ignore -v badminton_fe/android/local.properties
```

**Bắt buộc có:**

| Phải có | Vì sao |
|---|---|
| `badminton_be/gradle/wrapper/gradle-wrapper.jar` | Thiếu thì máy khác không chạy được `./gradlew` |
| `badminton_fe/pubspec.lock` | Cả nhóm dùng đúng một phiên bản thư viện |
| `badminton_be/src/main/resources/application-local.example.properties` | File mẫu để mọi người tự tạo cấu hình |
| Các file `.gitkeep` trong `lib/features/` | Giữ thư mục trống trong Git |

Nếu lỡ `git add` một file không nên commit:

```bash
git rm -r --cached <đường-dẫn>
```

## 4. Cho phép chạy `gradlew` trên Linux/macOS

Windows không lưu quyền thực thi, nên đánh dấu thủ công để thành viên dùng Mac/Linux chạy được:

```bash
git update-index --chmod=+x badminton_be/gradlew
```

## 5. Commit và push

```bash
git commit -m "chore: khởi tạo dự án FE + BE và tài liệu"
git branch -M main
git remote add origin https://github.com/<tên-tài-khoản>/badminton.git
git push -u origin main

git checkout -b develop
git push -u origin develop
```

Lần đầu push, Git mở cửa sổ đăng nhập GitHub trên trình duyệt (Git Credential Manager). Nếu được hỏi mật khẩu trong terminal, dùng **Personal Access Token** thay cho mật khẩu tài khoản.

## 6. Thiết lập trên GitHub

1. **Settings → Collaborators**: mời các thành viên.
2. **Settings → General → Default branch**: đổi sang `develop` để PR mặc định vào `develop`.
3. **Settings → Branches → Add branch ruleset** cho `main` và `develop`: bắt buộc Pull Request, cần 1 approval, chặn force push.
4. **Issues**: tạo task từ backlog bằng mẫu "Task" (đã có trong `.github/ISSUE_TEMPLATE/`).
5. (Tùy chọn) **Projects**: tạo bảng Kanban với cột Todo / In progress / Review / Done.

## 7. Thành viên khác bắt đầu làm

```bash
git clone https://github.com/<tên-tài-khoản>/badminton.git
cd badminton
git checkout develop
git checkout -b feature/FE-20-map-home
```

Sau đó làm theo phần "Bắt đầu nhanh" trong [README](../README.md).
