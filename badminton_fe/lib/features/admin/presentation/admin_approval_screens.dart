import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_chip.dart';

/// Ho so chu san cho Admin duyet o man A-02.
@immutable
class PendingOwnerApplication {
  final String id;
  final String ownerName;
  final String email;
  final String phone;
  final String taxCode;
  final String licenseFileName;
  final CourtBookingStatus status;
  final String? rejectionReason;

  const PendingOwnerApplication({
    required this.id,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.taxCode,
    required this.licenseFileName,
    this.status = CourtBookingStatus.pending,
    this.rejectionReason,
  });

  PendingOwnerApplication copyWith({
    CourtBookingStatus? status,
    String? rejectionReason,
  }) {
    return PendingOwnerApplication(
      id: id,
      ownerName: ownerName,
      email: email,
      phone: phone,
      taxCode: taxCode,
      licenseFileName: licenseFileName,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

/// Co so san cho Admin duyet o man A-03 (co ban do marker doi chieu dia chi).
@immutable
class PendingVenueSubmission {
  final String id;
  final String venueName;
  final String ownerName;
  final String address;
  final double latitude;
  final double longitude;
  final int courtCount;
  final int depositPercent;
  final List<String> amenities;
  final CourtBookingStatus status;
  final String statusLabel;
  final String? adminNote;

  const PendingVenueSubmission({
    required this.id,
    required this.venueName,
    required this.ownerName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.courtCount,
    required this.depositPercent,
    required this.amenities,
    this.status = CourtBookingStatus.pending,
    this.statusLabel = 'Chờ duyệt',
    this.adminNote,
  });

  PendingVenueSubmission copyWith({
    CourtBookingStatus? status,
    String? statusLabel,
    String? adminNote,
  }) {
    return PendingVenueSubmission(
      id: id,
      venueName: venueName,
      ownerName: ownerName,
      address: address,
      latitude: latitude,
      longitude: longitude,
      courtCount: courtCount,
      depositPercent: depositPercent,
      amenities: amenities,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      adminNote: adminNote ?? this.adminNote,
    );
  }
}

/// FE-24: Man hinh A-02 Duyet ho so chu san & A-03 Duyet co so san (co ban do doi chieu).
class AdminApprovalCenterView extends StatefulWidget {
  const AdminApprovalCenterView({super.key});

  @override
  State<AdminApprovalCenterView> createState() =>
      _AdminApprovalCenterViewState();
}

class _AdminApprovalCenterViewState extends State<AdminApprovalCenterView> {
  bool _showVenueApprovals = false;

  final List<PendingOwnerApplication> _ownerApps = [
    const PendingOwnerApplication(
      id: 'app-01',
      ownerName: 'Nguyễn Văn Minh',
      email: 'minh.owner@gmail.com',
      phone: '0909888777',
      taxCode: '0316892410',
      licenseFileName: 'giay_phep_kinh_doanh_phu_tho_arena.pdf (2.4 MB)',
    ),
    const PendingOwnerApplication(
      id: 'app-02',
      ownerName: 'Trần Thị Thu Thảo',
      email: 'thao.court@gmail.com',
      phone: '0912345678',
      taxCode: '0319001122',
      licenseFileName: 'gpdk_ho_kinh_doanh_thao_dien.jpg (3.1 MB)',
    ),
  ];

  final List<PendingVenueSubmission> _venueSubmissions = [
    const PendingVenueSubmission(
      id: 'vs-01',
      venueName: 'Cơ sở Cầu Lông Bình Thạnh Sport',
      ownerName: 'Nguyễn Văn Minh',
      address: '88 Điện Biên Phủ, Phường 17, Bình Thạnh, TP.HCM',
      latitude: 10.799140,
      longitude: 106.706230,
      courtCount: 6,
      depositPercent: 30,
      amenities: [
        'Bãi đậu ô tô',
        'Phòng tắm nước nóng',
        'Wifi tốc độ cao',
      ],
    ),
    const PendingVenueSubmission(
      id: 'vs-02',
      venueName: 'Sân Cầu Lông Nam Sài Gòn Quận 7',
      ownerName: 'Lê Hoàng Nam',
      address: '120 Nguyễn Thị Thập, Phường Bình Thuận, Quận 7, TP.HCM',
      latitude: 10.738120,
      longitude: 106.719450,
      courtCount: 8,
      depositPercent: 50,
      amenities: [
        'Bãi đậu ô tô',
        'Cho thuê vợt & giày',
        'Căng vợt lấy liền',
      ],
    ),
  ];

  Future<String?> _promptRequiredReason(
    BuildContext context, {
    required String dialogTitle,
    required String actionButtonLabel,
  }) async {
    final ctrl = TextEditingController();
    String? errorText;

    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final t = ctx.tokens;
            return AlertDialog(
              backgroundColor: t.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(t.radiusCard),
                side: BorderSide(color: t.borderSubtle),
              ),
              title: Text(
                dialogTitle,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              content: SizedBox(
                width: 400,
                child: AppTextField(
                  label: 'Lý do bắt buộc gửi cho Chủ sân',
                  hintText: 'Ví dụ: Ảnh giấy phép bị mờ hoặc tọa độ ghim lệch địa chỉ...',
                  controller: ctrl,
                  errorText: errorText,
                  prefixIcon: Icons.rate_review_outlined,
                ),
              ),
              actions: [
                AppButton(
                  label: 'Quay lại',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                AppButton(
                  label: actionButtonLabel,
                  variant: AppButtonVariant.danger,
                  onPressed: () {
                    final reason = ctrl.text.trim();
                    if (reason.length < 5) {
                      setDialogState(() {
                        errorText =
                            'Bạn bắt buộc phải nhập lý do cụ thể (tối thiểu 5 ký tự).';
                      });
                      return;
                    }
                    Navigator.of(ctx).pop(reason);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.all(t.space4),
      children: [
        // Chuyen tab A-02 (Ho so Chu san) va A-03 (Co so san + Ban do)
        Wrap(
          spacing: t.space2,
          runSpacing: t.space2,
          children: [
            ChoiceChip(
              label: Text('A-02 Duyệt hồ sơ Chủ sân (${_ownerApps.length})'),
              selected: !_showVenueApprovals,
              onSelected: (_) => setState(() => _showVenueApprovals = false),
            ),
            ChoiceChip(
              label: Text(
                'A-03 Duyệt cơ sở sân & Bản đồ (${_venueSubmissions.length})',
              ),
              selected: _showVenueApprovals,
              onSelected: (_) => setState(() => _showVenueApprovals = true),
            ),
          ],
        ),
        SizedBox(height: t.space4),

        if (!_showVenueApprovals) ...[
          Text(
            'A-02 Kiểm tra giấy phép & Duyệt hồ sơ Chủ sân',
            style: textTheme.headlineSmall,
          ),
          SizedBox(height: t.space3),
          if (_ownerApps.isEmpty)
            const EmptyState(
              icon: Icons.fact_check_outlined,
              title: 'Không có hồ sơ chủ sân nào chờ duyệt',
              description: 'Tất cả đơn đăng ký chủ sân đã được xử lý.',
            )
          else
            ...List.generate(_ownerApps.length, (i) {
              final app = _ownerApps[i];
              return Padding(
                padding: EdgeInsets.only(bottom: t.space4),
                child: Container(
                  padding: EdgeInsets.all(t.space4),
                  decoration: BoxDecoration(
                    color: t.surfaceCard,
                    borderRadius: BorderRadius.circular(t.radiusCard),
                    border: Border.all(color: t.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(app.ownerName, style: textTheme.titleLarge),
                          StatusChip(
                            status: app.status,
                            customLabel: app.status ==
                                    CourtBookingStatus.activeConfirmed
                                ? 'Đã duyệt'
                                : (app.status ==
                                        CourtBookingStatus.cancelledOrSuspended
                                    ? 'Đã từ chối'
                                    : 'Chờ duyệt'),
                          ),
                        ],
                      ),
                      SizedBox(height: t.space2),
                      Text(
                        'Email: ${app.email} · SĐT: ${app.phone} · Mã số thuế/HKD: ${app.taxCode}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      SizedBox(height: t.space3),
                      // Khung xem tep giay phep kinh doanh
                      Container(
                        padding: EdgeInsets.all(t.space3),
                        decoration: BoxDecoration(
                          color: t.surfaceMuted,
                          borderRadius: BorderRadius.circular(t.radiusControl),
                          border: Border.all(color: t.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf_outlined,
                              color: t.actionPrimary,
                            ),
                            SizedBox(width: t.space2),
                            Expanded(
                              child: Text(
                                'Tệp đính kèm: ${app.licenseFileName}',
                                style: textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (app.rejectionReason != null) ...[
                        SizedBox(height: t.space2),
                        Text(
                          'Lý do từ chối: ${app.rejectionReason}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: t.actionDanger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      SizedBox(height: t.space4),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: t.space2,
                        runSpacing: t.space2,
                        children: [
                          AppButton(
                            label: 'Từ chối (Bắt buộc lý do)',
                            variant: AppButtonVariant.danger,
                            onPressed: () async {
                              final reason = await _promptRequiredReason(
                                context,
                                dialogTitle:
                                    'Từ chối hồ sơ của ${app.ownerName}',
                                actionButtonLabel: 'Xác nhận từ chối',
                              );
                              if (reason != null) {
                                setState(() {
                                  _ownerApps[i] = app.copyWith(
                                    status: CourtBookingStatus
                                        .cancelledOrSuspended,
                                    rejectionReason: reason,
                                  );
                                });
                              }
                            },
                          ),
                          AppButton(
                            label: 'Duyệt Chủ sân',
                            variant: AppButtonVariant.primary,
                            onPressed: () {
                              setState(() {
                                _ownerApps[i] = app.copyWith(
                                  status: CourtBookingStatus.activeConfirmed,
                                  rejectionReason: null,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ] else ...[
          Text(
            'A-03 Duyệt cơ sở sân & Đối chiếu tọa độ bản đồ',
            style: textTheme.headlineSmall,
          ),
          SizedBox(height: t.space3),
          ...List.generate(_venueSubmissions.length, (i) {
            final v = _venueSubmissions[i];
            return Padding(
              padding: EdgeInsets.only(bottom: t.space4),
              child: Container(
                padding: EdgeInsets.all(t.space4),
                decoration: BoxDecoration(
                  color: t.surfaceCard,
                  borderRadius: BorderRadius.circular(t.radiusCard),
                  border: Border.all(color: t.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(v.venueName, style: textTheme.titleLarge),
                        ),
                        StatusChip(
                          status: v.status,
                          customLabel: v.statusLabel,
                        ),
                      ],
                    ),
                    SizedBox(height: t.space2),
                    Text(
                      'Chủ sân: ${v.ownerName} · Số sân con: ${v.courtCount} · Đặt cọc: ${v.depositPercent}%',
                      style: textTheme.bodyMedium,
                    ),
                    SizedBox(height: t.space1),
                    Text(
                      'Địa chỉ khai báo: ${v.address}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: t.space3),

                    // Ban do marker dat canh dia chi de Admin doi chieu (A-03)
                    Container(
                      padding: EdgeInsets.all(t.space4),
                      decoration: BoxDecoration(
                        color: t.surfaceMuted,
                        borderRadius: BorderRadius.circular(t.radiusControl),
                        border: Border.all(color: t.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 32,
                            color: t.actionDanger,
                          ),
                          SizedBox(width: t.space3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tọa độ ghim trên bản đồ (Đối chiếu địa chỉ):',
                                  style: textTheme.labelLarge,
                                ),
                                Text(
                                  'Lat: ${v.latitude.toStringAsFixed(6)} · Lng: ${v.longitude.toStringAsFixed(6)} (Khớp với ${v.address})',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (v.adminNote != null) ...[
                      SizedBox(height: t.space2),
                      Text(
                        'Ghi chú từ Admin: ${v.adminNote}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: t.actionDanger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    SizedBox(height: t.space4),
                    Wrap(
                      spacing: t.space2,
                      runSpacing: t.space2,
                      alignment: WrapAlignment.end,
                      children: [
                        AppButton(
                          label: 'Tạm ngưng',
                          variant: AppButtonVariant.danger,
                          onPressed: () async {
                            final reason = await _promptRequiredReason(
                              context,
                              dialogTitle: 'Tạm ngưng ${v.venueName}?',
                              actionButtonLabel: 'Xác nhận tạm ngưng',
                            );
                            if (reason != null) {
                              setState(() {
                                _venueSubmissions[i] = v.copyWith(
                                  status:
                                      CourtBookingStatus.cancelledOrSuspended,
                                  statusLabel: 'Tạm ngưng',
                                  adminNote: reason,
                                );
                              });
                            }
                          },
                        ),
                        AppButton(
                          label: 'Yêu cầu sửa',
                          variant: AppButtonVariant.secondary,
                          onPressed: () async {
                            final reason = await _promptRequiredReason(
                              context,
                              dialogTitle: 'Yêu cầu chỉnh sửa ${v.venueName}',
                              actionButtonLabel: 'Gửi yêu cầu sửa',
                            );
                            if (reason != null) {
                              setState(() {
                                _venueSubmissions[i] = v.copyWith(
                                  status: CourtBookingStatus.draftOrExpired,
                                  statusLabel: 'Cần chỉnh sửa',
                                  adminNote: reason,
                                );
                              });
                            }
                          },
                        ),
                        AppButton(
                          label: 'Duyệt hiển thị lên C-01',
                          variant: AppButtonVariant.primary,
                          onPressed: () {
                            setState(() {
                              _venueSubmissions[i] = v.copyWith(
                                status: CourtBookingStatus.activeConfirmed,
                                statusLabel: 'Hoạt động trên bản đồ',
                                adminNote: null,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
