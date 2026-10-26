import 'package:flutter/foundation.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/slot_grid.dart';
import '../../../../core/widgets/venue_card.dart';

/// Cau hoi thuong gap (FAQ) cua co so san hien thi tren C-03.
@immutable
class VenueFaqItem {
  final String question;
  final String answer;

  const VenueFaqItem({
    required this.question,
    required this.answer,
  });
}

/// Thong tin chi tiet co so san phuc vu C-01, C-02, C-03, C-05.
@immutable
class VenueDetailModel {
  final VenueSummaryItem summary;
  final String district;
  final double mapX; // Vi tri tuong doi tren ban do (0.1 -> 0.9)
  final double mapY;
  final String openHoursText;
  final int weekdayMorningPrice;
  final int weekdayPeakPrice;
  final int weekendPrice;
  final List<String> photoCaptions;
  final List<String> amenities;
  final List<String> cancellationPolicies;
  final List<VenueFaqItem> faqs;
  final int depositPercentage;

  const VenueDetailModel({
    required this.summary,
    required this.district,
    required this.mapX,
    required this.mapY,
    required this.openHoursText,
    required this.weekdayMorningPrice,
    required this.weekdayPeakPrice,
    required this.weekendPrice,
    required this.photoCaptions,
    required this.amenities,
    required this.cancellationPolicies,
    required this.faqs,
    this.depositPercentage = 30,
  });
}

/// Tuy chon sap xep trong C-02 Bo loc.
enum VenueSortOption {
  nearest('Gần nhất'),
  priceAsc('Giá thấp đến cao'),
  ratingDesc('Đánh giá cao nhất');

  final String label;
  const VenueSortOption(this.label);
}

/// Bo loc tim kiem san C-02.
@immutable
class VenueFilterCriteria {
  final String searchQuery;
  final double radiusKm;
  final String selectedDistrict;
  final double maxPriceVnd;
  final Set<String> requiredAmenities;
  final VenueSortOption sortBy;

  const VenueFilterCriteria({
    this.searchQuery = '',
    this.radiusKm = 5.0,
    this.selectedDistrict = 'Tất cả',
    this.maxPriceVnd = 220000,
    this.requiredAmenities = const {},
    this.sortBy = VenueSortOption.nearest,
  });

  VenueFilterCriteria copyWith({
    String? searchQuery,
    double? radiusKm,
    String? selectedDistrict,
    double? maxPriceVnd,
    Set<String>? requiredAmenities,
    VenueSortOption? sortBy,
  }) {
    return VenueFilterCriteria(
      searchQuery: searchQuery ?? this.searchQuery,
      radiusKm: radiusKm ?? this.radiusKm,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      maxPriceVnd: maxPriceVnd ?? this.maxPriceVnd,
      requiredAmenities: requiredAmenities ?? this.requiredAmenities,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// FakeVenueRepository phuc vu Sprint 0 - Sprint 2.
class FakeVenueRepository {
  const FakeVenueRepository();

  static const List<String> districts = [
    'Tất cả',
    'Quận 10',
    'Quận 11',
    'Tân Bình',
    'Bình Thạnh',
    'TP. Thủ Đức',
  ];

  static const List<String> filterableAmenities = [
    'Bãi đậu ô tô',
    'Phòng tắm nước nóng',
    'Wifi tốc độ cao',
    'Cho thuê vợt & giày',
    'Căng vợt lấy liền',
    'Quầy nước giải khát',
  ];

  List<VenueDetailModel> getAllVenueDetails() {
    return const [
      VenueDetailModel(
        summary: VenueSummaryItem(
          id: 'venue-01',
          name: 'Sân Cầu Lông Phú Thọ Arena',
          address: '219 Lý Thường Kiệt, Phường 15, Quận 11, TP.HCM',
          distanceKm: 1.2,
          rating: 4.8,
          reviewCount: 142,
          minPricePerHour: 110000,
          availableCourtCount: 4,
          status: CourtBookingStatus.activeConfirmed,
        ),
        district: 'Quận 11',
        mapX: 0.34,
        mapY: 0.42,
        openHoursText: '05:00 - 23:00 (Thứ 2 - Chủ Nhật)',
        weekdayMorningPrice: 110000,
        weekdayPeakPrice: 140000,
        weekendPrice: 150000,
        photoCaptions: [
          'Toàn cảnh 6 sân thảm PVC Yonex chuẩn thi đấu quốc tế',
          'Hệ thống đèn LED chống chói trần cao 11m',
          'Khu vực ghế chờ có quạt mát và quầy nước giải khát',
          'Phòng thay đồ và tắm nước nóng riêng biệt nam/nữ',
        ],
        amenities: [
          'Bãi đậu ô tô',
          'Phòng tắm nước nóng',
          'Wifi tốc độ cao',
          'Quầy nước giải khát',
          'Căng vợt lấy liền',
        ],
        cancellationPolicies: [
          'Hủy trước giờ chơi trên 24 giờ: Hoàn 100% tiền cọc.',
          'Hủy trước giờ chơi từ 6 đến 24 giờ: Hoàn 50% tiền cọc.',
          'Hủy sát giờ dưới 6 giờ: Không hoàn tiền cọc.',
        ],
        faqs: [
          VenueFaqItem(
            question: 'Sân có bắt buộc mang giày đế kếp chuyên dụng không?',
            answer:
                'Có. Để bảo vệ mặt thảm PVC, người chơi cần mang giày cầu lông đế kếp hoặc thuê giày tại quầy (20.000đ/buổi).',
          ),
          VenueFaqItem(
            question: 'Đến sân nhận sân bằng cách nào?',
            answer:
                'Bạn chỉ cần mở màn hình Chi tiết lượt đặt (C-10) và đưa mã QR cho nhân viên quầy quét check-in.',
          ),
        ],
      ),
      VenueDetailModel(
        summary: VenueSummaryItem(
          id: 'venue-02',
          name: 'CLB Cầu Lông Viettel Hoàng Hoa Thám',
          address: '158 Hoàng Hoa Thám, Phường 12, Tân Bình, TP.HCM',
          distanceKm: 2.6,
          rating: 4.6,
          reviewCount: 89,
          minPricePerHour: 120000,
          availableCourtCount: 2,
          status: CourtBookingStatus.activeConfirmed,
        ),
        district: 'Tân Bình',
        mapX: 0.62,
        mapY: 0.28,
        openHoursText: '05:30 - 22:30 (Thứ 2 - Chủ Nhật)',
        weekdayMorningPrice: 120000,
        weekdayPeakPrice: 150000,
        weekendPrice: 160000,
        photoCaptions: [
          'Mặt thảm mới thay tháng 09/2026 độ bám cao',
          'Bãi đỗ xe máy và ô tô rộng rãi có mái che',
          'Cửa hàng dụng cụ và căng vợt điện tử tại sân',
        ],
        amenities: [
          'Bãi đậu ô tô',
          'Wifi tốc độ cao',
          'Cho thuê vợt & giày',
          'Căng vợt lấy liền',
        ],
        cancellationPolicies: [
          'Hủy trước 12 giờ: Hoàn 100% tiền đặt cọc.',
          'Hủy dưới 12 giờ: Không hoàn tiền đặt cọc.',
        ],
        faqs: [
          VenueFaqItem(
            question: 'Sân có bán ống cầu lông tại quầy không?',
            answer:
                'Có sẵn cầu Hải Yến, Thành Công và Yonex chính hãng tại quầy tiếp tân.',
          ),
        ],
      ),
      VenueDetailModel(
        summary: VenueSummaryItem(
          id: 'venue-03',
          name: 'Sân Cầu Lông Kỳ Hòa Arena',
          address: '796 Sư Vạn Hạnh, Phường 12, Quận 10, TP.HCM',
          distanceKm: 1.8,
          rating: 4.9,
          reviewCount: 204,
          minPricePerHour: 130000,
          availableCourtCount: 3,
          status: CourtBookingStatus.activeConfirmed,
        ),
        district: 'Quận 10',
        mapX: 0.48,
        mapY: 0.64,
        openHoursText: '05:00 - 23:30 (Thứ 2 - Chủ Nhật)',
        weekdayMorningPrice: 130000,
        weekdayPeakPrice: 160000,
        weekendPrice: 170000,
        photoCaptions: [
          'Cụm 8 sân thảm thi đấu có khán đài mini',
          'Phòng chờ máy lạnh và tủ khóa thông minh',
        ],
        amenities: [
          'Bãi đậu ô tô',
          'Phòng tắm nước nóng',
          'Wifi tốc độ cao',
          'Cho thuê vợt & giày',
          'Quầy nước giải khát',
        ],
        cancellationPolicies: [
          'Hủy trước 24 giờ: Hoàn 100% tiền cọc.',
          'Hủy dưới 24 giờ: Hoàn 50% tiền cọc.',
        ],
        faqs: [
          VenueFaqItem(
            question: 'Có nhận đặt sân cố định theo tháng không?',
            answer:
                'Có. Bạn có thể chọn tính năng Đặt định kỳ (C-06) hoặc liên hệ trực tiếp quản lý sân.',
          ),
        ],
      ),
      VenueDetailModel(
        summary: VenueSummaryItem(
          id: 'venue-04',
          name: 'Sân Cầu Lông Tada Thảo Điền',
          address: '42 Xuân Thủy, Thảo Điền, TP. Thủ Đức',
          distanceKm: 6.4,
          rating: 4.7,
          reviewCount: 118,
          minPricePerHour: 150000,
          availableCourtCount: 0,
          status: CourtBookingStatus.maintenanceOrOccupied,
        ),
        district: 'TP. Thủ Đức',
        mapX: 0.78,
        mapY: 0.52,
        openHoursText: '06:00 - 22:00 (Thứ 2 - Chủ Nhật)',
        weekdayMorningPrice: 150000,
        weekdayPeakPrice: 180000,
        weekendPrice: 190000,
        photoCaptions: [
          'Không gian thoáng mát ven sông Sài Gòn',
          'Khu vực cafe và căng vợt chuyên nghiệp',
        ],
        amenities: [
          'Bãi đậu ô tô',
          'Phòng tắm nước nóng',
          'Wifi tốc độ cao',
          'Quầy nước giải khát',
        ],
        cancellationPolicies: [
          'Hủy trước 24 giờ: Hoàn 100% tiền cọc.',
        ],
        faqs: [],
      ),
    ];
  }

  List<VenueSummaryItem> getSampleVenues() {
    return getAllVenueDetails().map((e) => e.summary).toList();
  }

  List<VenueDetailModel> filterVenues(VenueFilterCriteria criteria) {
    final q = criteria.searchQuery.trim().toLowerCase();
    final filtered = getAllVenueDetails().where((item) {
      if (item.summary.distanceKm > criteria.radiusKm) return false;
      if (item.summary.minPricePerHour > criteria.maxPriceVnd) return false;
      if (criteria.selectedDistrict != 'Tất cả' &&
          item.district != criteria.selectedDistrict) {
        return false;
      }
      if (q.isNotEmpty &&
          !item.summary.name.toLowerCase().contains(q) &&
          !item.summary.address.toLowerCase().contains(q)) {
        return false;
      }
      for (final req in criteria.requiredAmenities) {
        if (!item.amenities.contains(req)) return false;
      }
      return true;
    }).toList();

    switch (criteria.sortBy) {
      case VenueSortOption.nearest:
        filtered.sort(
          (a, b) => a.summary.distanceKm.compareTo(b.summary.distanceKm),
        );
      case VenueSortOption.priceAsc:
        filtered.sort(
          (a, b) =>
              a.summary.minPricePerHour.compareTo(b.summary.minPricePerHour),
        );
      case VenueSortOption.ratingDesc:
        filtered.sort(
          (a, b) => b.summary.rating.compareTo(a.summary.rating),
        );
    }
    return filtered;
  }

  static const List<String> sampleCourtNames = [
    'Sân 01',
    'Sân 02',
    'Sân 03',
    'Sân 04',
  ];

  static const List<int> sampleHours = [17, 18, 19, 20, 21];

  Map<String, CourtSlotCell> getSampleSlotMatrix({int dayOffset = 0}) {
    final map = <String, CourtSlotCell>{};
    for (int c = 0; c < sampleCourtNames.length; c++) {
      final courtId = 'C${c + 1}';
      final courtName = sampleCourtNames[c];
      for (final h in sampleHours) {
        final price = (h >= 18 && h <= 20) ? 140000 : 110000;
        CourtBookingStatus status = CourtBookingStatus.activeConfirmed;
        String? note;

        if (dayOffset == 0 && h == 17 && c == 3) {
          status = CourtBookingStatus.draftOrExpired;
          note = 'Đã qua';
        } else if ((c + dayOffset) % 3 == 0 && h == 18) {
          status = CourtBookingStatus.maintenanceOrOccupied;
          note = 'Đã đặt';
        } else if (c == 1 && h == 19 && dayOffset % 2 == 0) {
          status = CourtBookingStatus.pending;
          note = 'Giữ chỗ';
        } else if (c == 2 && h == 20) {
          status = CourtBookingStatus.maintenanceOrOccupied;
          note = 'Bảo trì';
        }

        map['${courtId}_$h'] = CourtSlotCell(
          courtId: courtId,
          courtName: courtName,
          hour: h,
          priceVnd: price,
          status: status,
          bookedByNote: note,
        );
      }
    }
    return map;
  }
}
