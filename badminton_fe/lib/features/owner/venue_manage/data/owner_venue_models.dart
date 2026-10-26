import 'package:flutter/foundation.dart';
import '../../../../core/theme/app_tokens.dart';

/// San con trong mot co so san (O-07).
@immutable
class OwnerSubCourt {
  final String id;
  final String name;
  final bool isMaintenance;
  final int futureBookingsCount;

  const OwnerSubCourt({
    required this.id,
    required this.name,
    this.isMaintenance = false,
    this.futureBookingsCount = 0,
  });

  OwnerSubCourt copyWith({
    String? name,
    bool? isMaintenance,
    int? futureBookingsCount,
  }) {
    return OwnerSubCourt(
      id: id,
      name: name ?? this.name,
      isMaintenance: isMaintenance ?? this.isMaintenance,
      futureBookingsCount: futureBookingsCount ?? this.futureBookingsCount,
    );
  }
}

/// Quy tac gia theo khung gio (O-08): Ngay thuong vs Cuoi tuan.
@immutable
class VenuePriceRule {
  final String id;
  final bool isWeekend;
  final int startHour;
  final int endHour;
  final int pricePerHourVnd;

  const VenuePriceRule({
    required this.id,
    required this.isWeekend,
    required this.startHour,
    required this.endHour,
    required this.pricePerHourVnd,
  });

  VenuePriceRule copyWith({
    int? startHour,
    int? endHour,
    int? pricePerHourVnd,
  }) {
    return VenuePriceRule(
      id: id,
      isWeekend: isWeekend,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      pricePerHourVnd: pricePerHourVnd ?? this.pricePerHourVnd,
    );
  }

  /// Kiem tra loi chong lan khung gio ngay khi nhap (theo O-08 trong 03-danh-sach-man-hinh.md).
  static String? findOverlapError(List<VenuePriceRule> rules) {
    for (int i = 0; i < rules.length; i++) {
      final a = rules[i];
      if (a.startHour >= a.endHour) {
        return 'Khung giờ #${i + 1} (${a.startHour}:00 - ${a.endHour}:00) có giờ bắt đầu lớn hơn hoặc bằng giờ kết thúc.';
      }
      for (int j = i + 1; j < rules.length; j++) {
        final b = rules[j];
        if (a.startHour < b.endHour && a.endHour > b.startHour) {
          return 'Khung giờ (${a.startHour}:00 - ${a.endHour}:00) đang bị chồng lấn với (${b.startHour}:00 - ${b.endHour}:00). Bạn hãy chỉnh lại mốc giờ.';
        }
      }
    }
    return null;
  }
}

/// Lich mo cua 7 ngay trong tuan (O-08).
@immutable
class OperatingDaySchedule {
  final String dayName;
  final bool isClosed;
  final int openHour;
  final int closeHour;

  const OperatingDaySchedule({
    required this.dayName,
    this.isClosed = false,
    this.openHour = 5,
    this.closeHour = 23,
  });

  OperatingDaySchedule copyWith({
    bool? isClosed,
    int? openHour,
    int? closeHour,
  }) {
    return OperatingDaySchedule(
      dayName: dayName,
      isClosed: isClosed ?? this.isClosed,
      openHour: openHour ?? this.openHour,
      closeHour: closeHour ?? this.closeHour,
    );
  }
}

/// Ho so mot co so san cua Chu san (O-04 -> O-08).
@immutable
class OwnerVenueRecord {
  final String id;
  final String name;
  final String address;
  final String description;
  final double latitude;
  final double longitude;
  final int depositPercent;
  final List<String> photos;
  final List<String> amenities;
  final CourtBookingStatus status;
  final String statusLabel;
  final List<OwnerSubCourt> courts;

  const OwnerVenueRecord({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.depositPercent,
    required this.photos,
    required this.amenities,
    required this.status,
    required this.statusLabel,
    required this.courts,
  });

  OwnerVenueRecord copyWith({
    String? name,
    String? address,
    String? description,
    double? latitude,
    double? longitude,
    int? depositPercent,
    List<String>? photos,
    List<String>? amenities,
    CourtBookingStatus? status,
    String? statusLabel,
    List<OwnerSubCourt>? courts,
  }) {
    return OwnerVenueRecord(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      depositPercent: depositPercent ?? this.depositPercent,
      photos: photos ?? this.photos,
      amenities: amenities ?? this.amenities,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      courts: courts ?? this.courts,
    );
  }

  static List<String> get availableAmenities => const [
        'Bãi đậu ô tô',
        'Giữ xe máy miễn phí',
        'Phòng tắm nước nóng',
        'Căng vợt lấy liền',
        'Cho thuê vợt & giày',
        'Wifi tốc độ cao',
        'Quầy nước giải khát',
        'Ghế trọng tài tiêu chuẩn',
      ];

  static List<OwnerVenueRecord> initialSampleVenues() {
    return const [
      OwnerVenueRecord(
        id: 'ov-01',
        name: 'Sân Cầu Lông Phú Thọ Arena',
        address: '219 Lý Thường Kiệt, Phường 15, Quận 11, TP.HCM',
        description:
            'Cụm 6 sân thảm PVC Yonex tiêu chuẩn thi đấu, trần cao 11m chống chói.',
        latitude: 10.768820,
        longitude: 106.657410,
        depositPercent: 50,
        photos: [
          'anh_toan_canh_san_so_1.jpg',
          'khu_vuc_ghe_ngoi_cho.jpg',
          'quay_nuoc_va_phu_kien.jpg',
        ],
        amenities: [
          'Bãi đậu ô tô',
          'Phòng tắm nước nóng',
          'Wifi tốc độ cao',
          'Quầy nước giải khát',
        ],
        status: CourtBookingStatus.activeConfirmed,
        statusLabel: 'Hoạt động',
        courts: [
          OwnerSubCourt(
            id: 'c1',
            name: 'Sân 01 (Thảm VIP)',
            futureBookingsCount: 4,
          ),
          OwnerSubCourt(
            id: 'c2',
            name: 'Sân 02 (Thảm VIP)',
            futureBookingsCount: 2,
          ),
          OwnerSubCourt(
            id: 'c3',
            name: 'Sân 03 (Tiêu chuẩn)',
            futureBookingsCount: 0,
          ),
          OwnerSubCourt(
            id: 'c4',
            name: 'Sân 04 (Đang thay lưới)',
            isMaintenance: true,
            futureBookingsCount: 0,
          ),
        ],
      ),
      OwnerVenueRecord(
        id: 'ov-02',
        name: 'CLB Cầu Lông Bình Thạnh Sport',
        address: '88 Điện Biên Phủ, Phường 17, Bình Thạnh, TP.HCM',
        description: 'Cơ sở mới khai trương, đang hoàn thiện bảng giá cuối tuần.',
        latitude: 10.799140,
        longitude: 106.706230,
        depositPercent: 30,
        photos: ['mat_tien_co_so_binh_thanh.jpg'],
        amenities: ['Giữ xe máy miễn phí', 'Cho thuê vợt & giày'],
        status: CourtBookingStatus.draftOrExpired,
        statusLabel: 'Nháp',
        courts: [
          OwnerSubCourt(id: 'c1', name: 'Sân A', futureBookingsCount: 0),
          OwnerSubCourt(id: 'c2', name: 'Sân B', futureBookingsCount: 0),
        ],
      ),
    ];
  }
}
