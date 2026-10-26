import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/slot_grid.dart';
import '../../../../core/widgets/venue_card.dart';

/// FakeVenueRepository phuc vu lam UI truoc khi Backend xong API (theo docs/README.md).
class FakeVenueRepository {
  const FakeVenueRepository();

  List<VenueSummaryItem> getSampleVenues() {
    return const [
      VenueSummaryItem(
        id: 'venue-01',
        name: 'Sân Cầu Lông Phú Thọ Arena',
        address: '219 Lý Thường Kiệt, Phường 15, Quận 11, TP.HCM',
        distanceKm: 1.2,
        rating: 4.8,
        reviewCount: 142,
        minPricePerHour: 120000,
        availableCourtCount: 4,
        status: CourtBookingStatus.activeConfirmed,
      ),
      VenueSummaryItem(
        id: 'venue-02',
        name: 'CLB Cầu Lông Viettel Hoàng Hoa Thám',
        address: '158 Hoàng Hoa Thám, Phường 12, Tân Bình, TP.HCM',
        distanceKm: 2.6,
        rating: 4.6,
        reviewCount: 89,
        minPricePerHour: 140000,
        availableCourtCount: 2,
        status: CourtBookingStatus.activeConfirmed,
      ),
      VenueSummaryItem(
        id: 'venue-03',
        name: 'Sân Cầu Lông Tada Thảo Điền',
        address: '42 Xuân Thủy, Thảo Điền, TP. Thủ Đức',
        distanceKm: 4.5,
        rating: 4.9,
        reviewCount: 215,
        minPricePerHour: 160000,
        availableCourtCount: 0,
        status: CourtBookingStatus.maintenanceOrOccupied,
      ),
    ];
  }

  static const List<String> sampleCourtNames = [
    'Sân 01',
    'Sân 02',
    'Sân 03',
    'Sân 04',
  ];

  static const List<int> sampleHours = [17, 18, 19, 20, 21];

  Map<String, CourtSlotCell> getSampleSlotMatrix() {
    final map = <String, CourtSlotCell>{};
    for (int c = 0; c < sampleCourtNames.length; c++) {
      final courtId = 'C${c + 1}';
      final courtName = sampleCourtNames[c];
      for (final h in sampleHours) {
        final price = (h >= 18 && h <= 20) ? 140000 : 110000;
        CourtBookingStatus status = CourtBookingStatus.activeConfirmed;
        String? note;

        if (c == 0 && h == 18) {
          status = CourtBookingStatus.maintenanceOrOccupied;
          note = 'Đã đặt';
        } else if (c == 1 && h == 19) {
          status = CourtBookingStatus.pending;
          note = 'Giữ chỗ';
        } else if (c == 2 && h == 20) {
          status = CourtBookingStatus.maintenanceOrOccupied;
          note = 'Đã đặt';
        } else if (c == 3 && h == 17) {
          status = CourtBookingStatus.draftOrExpired;
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
