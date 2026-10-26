import '../../../../core/theme/app_tokens.dart';

/// Hinh thuc thanh toan
enum BookingPaymentType {
  full('Thanh toán 100%'),
  deposit('Đặt cọc'),
  payAtVenue('Trả tại sân');

  final String label;
  const BookingPaymentType(this.label);
}

/// Thong tin mot ca san con
class BookingSlotItem {
  final String courtId;
  final String courtName;
  final int hour;
  final int priceVnd;

  const BookingSlotItem({
    required this.courtId,
    required this.courtName,
    required this.hour,
    required this.priceVnd,
  });

  String get timeRangeLabel {
    final startStr = '${hour.toString().padLeft(2, '0')}:00';
    final endStr = '${(hour + 1).toString().padLeft(2, '0')}:00';
    return '$startStr - $endStr';
  }
}

/// Ma giam gia (Voucher)
class VoucherPromo {
  final String code;
  final String description;
  final int discountPercent;
  final int discountFixedVnd;
  final int minOrderVnd;

  const VoucherPromo({
    required this.code,
    required this.description,
    this.discountPercent = 0,
    this.discountFixedVnd = 0,
    this.minOrderVnd = 0,
  });

  int calculateDiscount(int orderTotalVnd) {
    if (orderTotalVnd < minOrderVnd) return 0;
    if (discountFixedVnd > 0) return discountFixedVnd;
    if (discountPercent > 0) {
      return (orderTotalVnd * discountPercent / 100).round();
    }
    return 0;
  }
}

/// Don dat san cua khach hang (Customer Booking Order)
class CustomerBookingOrder {
  final String id;
  final String bookingCode;
  final String venueId;
  final String venueName;
  final String venueAddress;
  final String venuePhone;
  final DateTime playDate;
  final List<BookingSlotItem> slots;
  final int totalAmountVnd;
  final int discountAmountVnd;
  final int depositPercentage;
  final int paidAmountVnd;
  final BookingPaymentType paymentType;
  final CourtBookingStatus status;
  final DateTime createdAt;
  final String qrCodePayload;
  final String? invoiceCode;
  final String? cancelReason;
  final DateTime? cancelledAt;

  const CustomerBookingOrder({
    required this.id,
    required this.bookingCode,
    required this.venueId,
    required this.venueName,
    required this.venueAddress,
    required this.venuePhone,
    required this.playDate,
    required this.slots,
    required this.totalAmountVnd,
    this.discountAmountVnd = 0,
    required this.depositPercentage,
    required this.paidAmountVnd,
    required this.paymentType,
    required this.status,
    required this.createdAt,
    required this.qrCodePayload,
    this.invoiceCode,
    this.cancelReason,
    this.cancelledAt,
  });

  int get finalTotalVnd => (totalAmountVnd - discountAmountVnd).clamp(0, 999999999);

  int get remainingAmountVnd => (finalTotalVnd - paidAmountVnd).clamp(0, 999999999);

  bool get isPaidInFull => paidAmountVnd >= finalTotalVnd;

  CustomerBookingOrder copyWith({
    String? id,
    String? bookingCode,
    String? venueId,
    String? venueName,
    String? venueAddress,
    String? venuePhone,
    DateTime? playDate,
    List<BookingSlotItem>? slots,
    int? totalAmountVnd,
    int? discountAmountVnd,
    int? depositPercentage,
    int? paidAmountVnd,
    BookingPaymentType? paymentType,
    CourtBookingStatus? status,
    DateTime? createdAt,
    String? qrCodePayload,
    String? invoiceCode,
    String? cancelReason,
    DateTime? cancelledAt,
  }) {
    return CustomerBookingOrder(
      id: id ?? this.id,
      bookingCode: bookingCode ?? this.bookingCode,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      venuePhone: venuePhone ?? this.venuePhone,
      playDate: playDate ?? this.playDate,
      slots: slots ?? this.slots,
      totalAmountVnd: totalAmountVnd ?? this.totalAmountVnd,
      discountAmountVnd: discountAmountVnd ?? this.discountAmountVnd,
      depositPercentage: depositPercentage ?? this.depositPercentage,
      paidAmountVnd: paidAmountVnd ?? this.paidAmountVnd,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      qrCodePayload: qrCodePayload ?? this.qrCodePayload,
      invoiceCode: invoiceCode ?? this.invoiceCode,
      cancelReason: cancelReason ?? this.cancelReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}

/// Kho du lieu mau don dat san (In-memory Store cho Customer)
class FakeCustomerBookingRepository {
  static final FakeCustomerBookingRepository instance =
      FakeCustomerBookingRepository._internal();

  FakeCustomerBookingRepository._internal() {
    _initSampleData();
  }

  factory FakeCustomerBookingRepository() => instance;

  final List<CustomerBookingOrder> _bookings = [];

  static const List<VoucherPromo> sampleVouchers = [
    VoucherPromo(
      code: 'BADMINTON10',
      description: 'Giảm 10% cho đơn từ 100.000 đ',
      discountPercent: 10,
      minOrderVnd: 100000,
    ),
    VoucherPromo(
      code: 'SANDEP20K',
      description: 'Giảm 20.000 đ cho lượt đặt đầu tuần',
      discountFixedVnd: 20000,
      minOrderVnd: 150000,
    ),
  ];

  void _initSampleData() {
    final now = DateTime(2026, 10, 27);

    // 1. Sap toi (Active Confirmed)
    _bookings.add(
      CustomerBookingOrder(
        id: 'BK-001',
        bookingCode: 'BM-2026-0891',
        venueId: 'v1',
        venueName: 'Sân Cầu Lông Hỏa Châu',
        venueAddress: '124 Phan Văn Trị, Phường 12, Quận Bình Thạnh, TP.HCM',
        venuePhone: '0903123456',
        playDate: now.add(const Duration(days: 1)),
        slots: const [
          BookingSlotItem(
            courtId: 'c1',
            courtName: 'Sân 1 (Thảm Yonex)',
            hour: 18,
            priceVnd: 120000,
          ),
          BookingSlotItem(
            courtId: 'c1',
            courtName: 'Sân 1 (Thảm Yonex)',
            hour: 19,
            priceVnd: 120000,
          ),
        ],
        totalAmountVnd: 240000,
        discountAmountVnd: 24000,
        depositPercentage: 30,
        paidAmountVnd: 216000,
        paymentType: BookingPaymentType.full,
        status: CourtBookingStatus.activeConfirmed,
        createdAt: now.subtract(const Duration(hours: 2)),
        qrCodePayload: 'BM-PASS-20260891-V1-C1-1819',
        invoiceCode: 'INV-2026-8801',
      ),
    );

    // 2. Sap toi (Dang dat coc - pending deposit)
    _bookings.add(
      CustomerBookingOrder(
        id: 'BK-002',
        bookingCode: 'BM-2026-0942',
        venueId: 'v2',
        venueName: 'CLB Cầu Lông Đào Duy Anh',
        venueAddress: '21 Đào Duy Anh, Phường 9, Quận Phú Nhuận, TP.HCM',
        venuePhone: '0988776655',
        playDate: now.add(const Duration(days: 3)),
        slots: const [
          BookingSlotItem(
            courtId: 'c2',
            courtName: 'Sân 2 (Thảm Victor)',
            hour: 17,
            priceVnd: 100000,
          ),
        ],
        totalAmountVnd: 100000,
        discountAmountVnd: 0,
        depositPercentage: 30,
        paidAmountVnd: 30000,
        paymentType: BookingPaymentType.deposit,
        status: CourtBookingStatus.activeConfirmed,
        createdAt: now.subtract(const Duration(hours: 1)),
        qrCodePayload: 'BM-PASS-20260942-V2-C2-17',
        invoiceCode: 'INV-2026-8842',
      ),
    );

    // 3. Da hoan thanh (Completed)
    _bookings.add(
      CustomerBookingOrder(
        id: 'BK-003',
        bookingCode: 'BM-2026-0710',
        venueId: 'v1',
        venueName: 'Sân Cầu Lông Hỏa Châu',
        venueAddress: '124 Phan Văn Trị, Phường 12, Quận Bình Thạnh, TP.HCM',
        venuePhone: '0903123456',
        playDate: now.subtract(const Duration(days: 4)),
        slots: const [
          BookingSlotItem(
            courtId: 'c3',
            courtName: 'Sân 3 (Thảm Kumpoo)',
            hour: 20,
            priceVnd: 110000,
          ),
        ],
        totalAmountVnd: 110000,
        discountAmountVnd: 0,
        depositPercentage: 30,
        paidAmountVnd: 110000,
        paymentType: BookingPaymentType.full,
        status: CourtBookingStatus.completedOrCheckedIn,
        createdAt: now.subtract(const Duration(days: 5)),
        qrCodePayload: 'BM-PASS-20260710-V1-C3-20',
        invoiceCode: 'INV-2026-7710',
      ),
    );

    // 4. Da huy (Cancelled)
    _bookings.add(
      CustomerBookingOrder(
        id: 'BK-004',
        bookingCode: 'BM-2026-0520',
        venueId: 'v3',
        venueName: 'Nhà Thi Đấu Rạch Miễu',
        venueAddress: 'Số 1 Hoa Phượng, Phường 2, Quận Phú Nhuận, TP.HCM',
        venuePhone: '02838991234',
        playDate: now.subtract(const Duration(days: 8)),
        slots: const [
          BookingSlotItem(
            courtId: 'c1',
            courtName: 'Sân VIP 1',
            hour: 19,
            priceVnd: 150000,
          ),
        ],
        totalAmountVnd: 150000,
        discountAmountVnd: 0,
        depositPercentage: 50,
        paidAmountVnd: 75000,
        paymentType: BookingPaymentType.deposit,
        status: CourtBookingStatus.cancelledOrSuspended,
        createdAt: now.subtract(const Duration(days: 9)),
        qrCodePayload: 'BM-PASS-20260520-V3-C1-19',
        cancelReason: 'Bận công việc đột xuất trước 24h (Đã hoàn 100% tiền cọc)',
        cancelledAt: now.subtract(const Duration(days: 9, hours: 2)),
      ),
    );
  }

  List<CustomerBookingOrder> getBookingsByTab(int tabIndex) {
    switch (tabIndex) {
      case 0: // Sap toi
        return _bookings
            .where((b) => b.status == CourtBookingStatus.activeConfirmed)
            .toList();
      case 1: // Da qua
        return _bookings
            .where((b) => b.status == CourtBookingStatus.completedOrCheckedIn)
            .toList();
      case 2: // Da huy
        return _bookings
            .where((b) => b.status == CourtBookingStatus.cancelledOrSuspended)
            .toList();
      default:
        return _bookings;
    }
  }

  CustomerBookingOrder? getBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  void addBooking(CustomerBookingOrder order) {
    _bookings.insert(0, order);
  }

  bool cancelBooking({
    required String bookingId,
    required String reason,
  }) {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) return false;
    final target = _bookings[idx];
    _bookings[idx] = target.copyWith(
      status: CourtBookingStatus.cancelledOrSuspended,
      cancelReason: reason,
      cancelledAt: DateTime(2026, 10, 27, 3, 0),
    );
    return true;
  }

  bool payRemainingAmount(String bookingId) {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) return false;
    final target = _bookings[idx];
    _bookings[idx] = target.copyWith(
      paidAmountVnd: target.finalTotalVnd,
      paymentType: BookingPaymentType.full,
    );
    return true;
  }
}
