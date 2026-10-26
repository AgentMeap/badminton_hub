/// Cac ma loi nghiep vu tu Backend theo tai lieu 01-kien-truc.md.
enum ApiErrorCode {
  slotAlreadyBooked('SLOT_ALREADY_BOOKED'),
  holdExpired('HOLD_EXPIRED'),
  emailNotVerified('EMAIL_NOT_VERIFIED'),
  accountLocked('ACCOUNT_LOCKED'),
  otpTooManyAttempts('OTP_TOO_MANY_ATTEMPTS'),
  unauthorized('UNAUTHORIZED'),
  networkError('NETWORK_ERROR'),
  unknown('UNKNOWN');

  final String raw;
  const ApiErrorCode(this.raw);

  static ApiErrorCode fromString(String? code) {
    if (code == null) return ApiErrorCode.unknown;
    for (final item in ApiErrorCode.values) {
      if (item.raw == code) return item;
    }
    return ApiErrorCode.unknown;
  }
}

/// Ngoai le chuan hoa cho moi loi tra ve tu Backend {code, message}.
class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  ApiErrorCode get errorCode => ApiErrorCode.fromString(code);

  bool get shouldReloadSlots =>
      errorCode == ApiErrorCode.slotAlreadyBooked ||
      errorCode == ApiErrorCode.holdExpired;

  bool get isAccountLocked => errorCode == ApiErrorCode.accountLocked;

  bool get isOtpLocked => errorCode == ApiErrorCode.otpTooManyAttempts;

  factory ApiException.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    return ApiException(
      code: (json['code'] as String?) ?? 'UNKNOWN',
      message: (json['message'] as String?) ??
          'Không thể kết nối máy chủ. Bạn hãy thử lại sau.',
      statusCode: statusCode,
    );
  }

  @override
  String toString() => 'ApiException($code, status: $statusCode): $message';
}
