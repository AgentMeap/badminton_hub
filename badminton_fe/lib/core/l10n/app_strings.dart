/// Chuoi giao dien Tieng Viet gom tap trung theo 02-design-system.md (muc 5).
/// Xung "ban", cau ngan, dong tu o dau nut, thong bao loi huong dan buoc tiep theo.
class AppStrings {
  AppStrings._();

  static const String appTitle = 'Badminton Court Manager';

  // Vai tro
  static const String roleCustomer = 'Người chơi';
  static const String roleOwner = 'Chủ sân';
  static const String roleAdmin = 'Quản trị';

  // Bottom Navigation: Customer (C)
  static const String navExplore = 'Khám phá';
  static const String navMyBookings = 'Lịch đặt';
  static const String navAiChat = 'Chat AI';
  static const String navNotifications = 'Thông báo';
  static const String navAccount = 'Tài khoản';

  // Bottom Navigation: Owner (O)
  static const String navToday = 'Hôm nay';
  static const String navVenues = 'Cơ sở sân';
  static const String navRevenue = 'Doanh thu';

  // Bottom Navigation: Admin (A)
  static const String navOverview = 'Tổng quan';
  static const String navApprovals = 'Duyệt hồ sơ';
  static const String navUsers = 'Tài khoản';
  static const String navTransactions = 'Giao dịch';
  static const String navSettings = 'Cấu hình';

  // Nut hanh dong
  static const String actionBookNow = 'Đặt sân ngay';
  static const String actionConfirmPayment = 'Thanh toán giữ chỗ';
  static const String actionCancelBooking = 'Hủy lượt đặt';
  static const String actionRetry = 'Thử lại';
  static const String actionResendOtp = 'Gửi lại mã';
  static const String actionClose = 'Đóng';
  static const String actionFilter = 'Lọc sân';
  static const String actionDirections = 'Chỉ đường';

  // Thong bao loi & trang thai
  static const String errSlotTaken =
      'Khung giờ vừa có người đặt. Bạn hãy chọn khung giờ khác.';
  static const String errHoldExpired =
      'Thời gian giữ chỗ 10 phút đã hết. Bạn hãy chọn lại khung giờ.';
  static const String errOtpTooMany =
      'Bạn đã nhập sai quá số lần quy định. Hãy bấm Gửi lại mã mới.';
  static const String emptyBookingsTitle = 'Chưa có lượt đặt sân nào';
  static const String emptyBookingsBody =
      'Chọn sân gần bạn trên bản đồ để đặt khung giờ tập luyện đầu tiên.';
}
