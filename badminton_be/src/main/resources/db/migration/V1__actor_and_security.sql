-- V1: RBAC tables (role, permission, role_permission, users, user_role) and security tables (SQLite)

CREATE TABLE role (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code VARCHAR(32) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    created_at VARCHAR(64) NOT NULL
);

CREATE INDEX idx_role_code ON role(code);

CREATE TABLE permission (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    module VARCHAR(64) NOT NULL,
    created_at VARCHAR(64) NOT NULL
);

CREATE INDEX idx_permission_code ON permission(code);

CREATE TABLE role_permission (
    role_id INTEGER NOT NULL REFERENCES role(id) ON DELETE CASCADE,
    permission_id INTEGER NOT NULL REFERENCES permission(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    firebase_uid VARCHAR(128) UNIQUE,
    auth_provider VARCHAR(32) NOT NULL DEFAULT 'LOCAL',
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(160) NOT NULL UNIQUE,
    phone VARCHAR(24),
    password_hash VARCHAR(255),
    avatar_url VARCHAR(500),
    status VARCHAR(32) NOT NULL DEFAULT 'PENDING_VERIFICATION',
    failed_login_count INTEGER NOT NULL DEFAULT 0,
    locked_until VARCHAR(64),
    created_at VARCHAR(64) NOT NULL,
    updated_at VARCHAR(64) NOT NULL
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX idx_users_status ON users(status);

CREATE TABLE user_role (
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES role(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE INDEX idx_user_role_role ON user_role(role_id);

CREATE TABLE otp_code (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ticket VARCHAR(64) NOT NULL UNIQUE,
    purpose VARCHAR(32) NOT NULL,
    code_hash VARCHAR(255) NOT NULL,
    encrypted_pending_secret VARCHAR(512),
    attempt_count INTEGER NOT NULL DEFAULT 0,
    expires_at VARCHAR(64) NOT NULL,
    consumed_at VARCHAR(64),
    created_at VARCHAR(64) NOT NULL
);

CREATE INDEX idx_otp_ticket ON otp_code(ticket);
CREATE INDEX idx_otp_user_purpose ON otp_code(user_id, purpose, created_at);

CREATE TABLE trusted_device (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(128) NOT NULL,
    device_name VARCHAR(160),
    last_used_at VARCHAR(64) NOT NULL,
    created_at VARCHAR(64) NOT NULL,
    CONSTRAINT ux_trusted_device_user UNIQUE (user_id, device_id)
);

CREATE INDEX idx_trusted_device_user ON trusted_device(user_id, device_id);

CREATE TABLE auth_session (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token_hash VARCHAR(128) NOT NULL UNIQUE,
    device_id VARCHAR(128),
    ip_address VARCHAR(64),
    expires_at VARCHAR(64) NOT NULL,
    revoked_at VARCHAR(64),
    created_at VARCHAR(64) NOT NULL
);

CREATE INDEX idx_auth_session_refresh_hash ON auth_session(refresh_token_hash);
CREATE INDEX idx_auth_session_user ON auth_session(user_id);

CREATE TABLE login_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    role_code VARCHAR(32) NOT NULL,
    email VARCHAR(160) NOT NULL,
    device_id VARCHAR(128),
    ip_address VARCHAR(64),
    success INTEGER NOT NULL DEFAULT 0,
    failure_reason VARCHAR(160),
    created_at VARCHAR(64) NOT NULL
);

CREATE INDEX idx_login_log_email ON login_log(email, created_at);
CREATE INDEX idx_login_log_user ON login_log(user_id, created_at);

CREATE TABLE account_action_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    target_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    performed_by_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    action_type VARCHAR(64) NOT NULL,
    reason VARCHAR(255),
    created_at VARCHAR(64) NOT NULL
);

CREATE INDEX idx_account_action_target ON account_action_log(target_user_id, created_at);
