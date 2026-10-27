-- V2: Owner onboarding tables and RBAC seed roles/permissions (SQLite)

CREATE TABLE owner_application (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(180) NOT NULL,
    tax_code VARCHAR(64),
    address VARCHAR(255) NOT NULL,
    license_file_url VARCHAR(500) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
    reject_reason VARCHAR(500),
    reviewed_by_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at VARCHAR(64),
    submitted_at VARCHAR(64) NOT NULL
);

CREATE INDEX idx_owner_application_user ON owner_application(user_id, submitted_at);
CREATE INDEX idx_owner_application_status ON owner_application(status);

CREATE TABLE bank_account (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bank_code VARCHAR(32) NOT NULL,
    bank_name VARCHAR(120) NOT NULL,
    account_number_encrypted VARCHAR(255) NOT NULL,
    account_holder_name VARCHAR(120) NOT NULL,
    is_verified INTEGER NOT NULL DEFAULT 0,
    created_at VARCHAR(64) NOT NULL,
    updated_at VARCHAR(64) NOT NULL
);

CREATE INDEX idx_bank_account_user ON bank_account(user_id);

-- Seed 3 standard RBAC roles
INSERT INTO role (code, name, description, created_at) VALUES
('CUSTOMER', 'Khach dat san', 'Nguoi dung tim kiem san, giu cho, thanh toan PayOS va chat AI', '2026-10-27T00:00:00Z'),
('OWNER', 'Chu san', 'Chu co so cau long quan ly san, bang gia, lich dat va quet QR check-in', '2026-10-27T00:00:00Z'),
('ADMIN', 'Quan tri vien', 'Quan tri he thong, duyet ho so chu san, kiem duyet san va xu ly tranh chap', '2026-10-27T00:00:00Z');

-- Seed standard permissions
INSERT INTO permission (code, name, module, created_at) VALUES
('BOOKING_CREATE', 'Tao luot dat san va giu cho', 'BOOKING', '2026-10-27T00:00:00Z'),
('BOOKING_VIEW_OWN', 'Xem lich su dat san ca nhan', 'BOOKING', '2026-10-27T00:00:00Z'),
('CHAT_AI_USE', 'Su dung tro ly AI tu van san', 'CHAT', '2026-10-27T00:00:00Z'),
('VENUE_MANAGE_OWN', 'Quan ly co so san va bang gia cua minh', 'VENUE', '2026-10-27T00:00:00Z'),
('BOOKING_TIMELINE_MANAGE', 'Xem timeline, dat thu cong va quet QR check-in', 'BOOKING', '2026-10-27T00:00:00Z'),
('OWNER_APPLICATION_REVIEW', 'Duyet hoac tu choi ho so dang ky chu san', 'ADMIN', '2026-10-27T00:00:00Z'),
('VENUE_APPROVE', 'Kiem duyet co so san moi', 'ADMIN', '2026-10-27T00:00:00Z'),
('USER_LOCK_MANAGE', 'Khoa va mo khoa tai khoan nguoi dung', 'ADMIN', '2026-10-27T00:00:00Z');
