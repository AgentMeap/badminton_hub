import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../booking/presentation/slot_selection_screen.dart';
import '../../venue/data/fake_venue_repository.dart';
import '../../venue/presentation/venue_detail_screen.dart';

/// Model mot tin nhan trong khung Chat AI C-13.
class AiChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final String timestamp;
  final List<VenueDetailModel> recommendedVenues;
  final bool isReported;

  const AiChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.recommendedVenues = const [],
    this.isReported = false,
  });

  AiChatMessage copyWith({bool? isReported}) {
    return AiChatMessage(
      id: id,
      isUser: isUser,
      text: text,
      timestamp: timestamp,
      recommendedVenues: recommendedVenues,
      isReported: isReported ?? this.isReported,
    );
  }
}

/// FE-45: Man hinh C-13 Chat AI tu van tim san & dat san:
/// - Khung chat tuong tac giua Customer va Tro ly AI
/// - Goi y cau hoi nhanh ("Toi nay 7h con san nao gan toi?", v.v.)
/// - Cau tra loi kem The san de xuat + nut "Dat ngay" dieu huong thang sang C-05
/// - Nut "Bao cao cau tra loi" tren tung phan hoi cua AI
/// - Hieu ung "Tro ly AI dang tra loi..."
class CustomerAiChatScreen extends StatefulWidget {
  const CustomerAiChatScreen({super.key});

  @override
  State<CustomerAiChatScreen> createState() => _CustomerAiChatScreenState();
}

class _CustomerAiChatScreenState extends State<CustomerAiChatScreen> {
  final FakeVenueRepository _venueRepo = const FakeVenueRepository();
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isAiTyping = false;

  late final List<AiChatMessage> _messages;

  static const List<String> _quickPrompts = [
    'Tối nay 7h còn sân nào gần tôi?',
    'Sân nào ở Bình Thạnh có thảm Yonex?',
    'Tìm sân giá dưới 100.000đ/giờ',
    'Chính sách hoàn cọc khi hủy sân thế nào?',
  ];

  @override
  void initState() {
    super.initState();
    final allVenues = _venueRepo.getAllVenueDetails();
    _messages = [
      AiChatMessage(
        id: 'MSG-01',
        isUser: false,
        text:
            'Xin chào! Tôi là Trợ lý AI Badminton Hub. Bạn muốn tìm sân cầu lông khu vực nào, khung giờ mấy giờ tối nay hay cần tra cứu quy định đặt cọc PayOS?',
        timestamp: '18:00',
        recommendedVenues: [allVenues.first],
      ),
    ];
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String rawText) async {
    final query = rawText.trim();
    if (query.isEmpty || _isAiTyping) return;

    _inputCtrl.clear();
    setState(() {
      _messages.add(
        AiChatMessage(
          id: 'MSG-U-${DateTime.now().millisecondsSinceEpoch}',
          isUser: true,
          text: query,
          timestamp: '18:02',
        ),
      );
      _isAiTyping = true;
    });
    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    final reply = _generateSmartReply(query);
    setState(() {
      _isAiTyping = false;
      _messages.add(reply);
    });
    _scrollToBottom();
  }

  AiChatMessage _generateSmartReply(String query) {
    final lower = query.toLowerCase();
    final allVenues = _venueRepo.getAllVenueDetails();
    final id = 'MSG-AI-${DateTime.now().millisecondsSinceEpoch}';

    if (lower.contains('hủy') ||
        lower.contains('hoàn') ||
        lower.contains('cọc')) {
      return AiChatMessage(
        id: id,
        isUser: false,
        text:
            'Theo quy định chung của các cơ sở sân trên Badminton Hub:\n'
            '1. Hủy trước giờ chơi từ 24 giờ trở lên: Hoàn 100% tiền đã thanh toán qua PayOS.\n'
            '2. Hủy trước từ 12 giờ đến dưới 24 giờ: Hoàn 50% tiền cọc.\n'
            '3. Hủy sát giờ dưới 12 giờ: Không hoàn tiền cọc.\n'
            'Dưới đây là cơ sở có chính sách linh hoạt nhất gần bạn:',
        timestamp: '18:02',
        recommendedVenues: [allVenues.first],
      );
    }

    if (lower.contains('100') || lower.contains('rẻ') || lower.contains('giá')) {
      final affordable = allVenues
          .where((v) => v.summary.minPricePerHour <= 100000)
          .toList();
      return AiChatMessage(
        id: id,
        isUser: false,
        text:
            'Tôi tìm thấy ${affordable.length} cơ sở sân có mức giá từ 85.000đ - 100.000đ/giờ kèm chỗ để xe miễn phí. Bạn có thể bấm "Đặt ngay" để giữ chỗ trong 10 phút:',
        timestamp: '18:02',
        recommendedVenues:
            affordable.isNotEmpty ? affordable : [allVenues.first],
      );
    }

    if (lower.contains('bình thạnh') || lower.contains('yonex')) {
      final matched = allVenues
          .where((v) =>
              v.district.toLowerCase().contains('bình thạnh') ||
              v.district.toLowerCase().contains('gò vấp'))
          .toList();
      return AiChatMessage(
        id: id,
        isUser: false,
        text:
            'Khu vực Bình Thạnh & Gò Vấp hiện còn trống khung 19:00 - 21:00 tối nay trên mặt thảm PVC chuẩn thi đấu. Bạn chọn sân bên dưới để vào thẳng lưới chọn giờ C-05 nhé:',
        timestamp: '18:02',
        recommendedVenues: matched.isNotEmpty ? matched : allVenues.take(2).toList(),
      );
    }

    // Mặc định gợi ý tối nay 7h gần tôi
    final availableTonight =
        allVenues.where((v) => v.summary.availableCourtCount > 0).toList();
    return AiChatMessage(
      id: id,
      isUser: false,
      text:
          'Tối nay lúc 19:00 quanh vị trí của bạn (bán kính 5 km) đang có ${availableTonight.length} cơ sở còn sân trống. Bạn bấm "Đặt ngay" trên thẻ sân để chọn sân con nhé:',
      timestamp: '18:02',
      recommendedVenues: availableTonight.take(2).toList(),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 180,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openReportDialog(AiChatMessage message) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    String selectedReason = 'Thông tin giá hoặc giờ trống chưa chính xác';

    final reasons = [
      'Thông tin giá hoặc giờ trống chưa chính xác',
      'Cơ sở sân được gợi ý đã ngừng hoạt động',
      'Câu trả lời không liên quan đến cầu lông',
    ];

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDlgState) {
            return AlertDialog(
              backgroundColor: t.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(t.radiusCard),
              ),
              title: Text(
                'Báo cáo câu trả lời AI (Gửi tới Admin A-11)',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chọn lý do báo cáo để đội ngũ quản trị cải thiện Trợ lý AI:',
                    style: textTheme.bodySmall,
                  ),
                  SizedBox(height: t.space3),
                  ...reasons.map((r) {
                    final isSelected = selectedReason == r;
                    return Padding(
                      padding: EdgeInsets.only(bottom: t.space2),
                      child: InkWell(
                        onTap: () => setDlgState(() => selectedReason = r),
                        borderRadius: BorderRadius.circular(t.radiusControl),
                        child: Container(
                          padding: EdgeInsets.all(t.space3),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? t.statusActive.background
                                : t.surfaceMuted,
                            borderRadius: BorderRadius.circular(t.radiusControl),
                            border: Border.all(
                              color: isSelected
                                  ? t.statusActive.border
                                  : t.borderSubtle,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                size: 18,
                                color: isSelected
                                    ? t.statusActive.foreground
                                    : t.textSecondary,
                              ),
                              SizedBox(width: t.space2),
                              Expanded(
                                child: Text(r, style: textTheme.bodySmall),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              actions: [
                AppButton(
                  label: 'Hủy',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                AppButton(
                  label: 'Gửi báo cáo',
                  variant: AppButtonVariant.danger,
                  onPressed: () {
                    final idx =
                        _messages.indexWhere((m) => m.id == message.id);
                    if (idx != -1) {
                      setState(() {
                        _messages[idx] =
                            _messages[idx].copyWith(isReported: true);
                      });
                    }
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Đã gửi báo cáo câu trả lời AI tới hệ thống quản trị.',
                        ),
                      ),
                    );
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

    return Scaffold(
      backgroundColor: t.surfaceMuted,
      appBar: AppBar(
        title: const Text('C-13 Trợ lý AI Tìm & Đặt sân'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: t.space3),
            child: const Center(
              child: StatusChip(
                status: CourtBookingStatus.activeConfirmed,
                customLabel: 'AI Online',
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Thanh goi y cau hoi nhanh (Quick Prompts)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: t.space4,
              vertical: t.space2,
            ),
            decoration: BoxDecoration(
              color: t.surfaceCard,
              border: Border(bottom: BorderSide(color: t.borderSubtle)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickPrompts.map((prompt) {
                  return Padding(
                    padding: EdgeInsets.only(right: t.space2),
                    child: ActionChip(
                      avatar: Icon(
                        Icons.auto_awesome_outlined,
                        size: 16,
                        color: t.actionPrimary,
                      ),
                      label: Text(prompt),
                      onPressed: () => _sendMessage(prompt),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 2. Danh sach tin nhan va The san "Dat ngay"
          Expanded(
            child: ListView.separated(
              controller: _scrollCtrl,
              padding: EdgeInsets.all(t.space4),
              itemCount: _messages.length + (_isAiTyping ? 1 : 0),
              separatorBuilder: (_, _) => SizedBox(height: t.space3),
              itemBuilder: (ctx, index) {
                if (index == _messages.length && _isAiTyping) {
                  return _buildTypingIndicator(context);
                }
                final msg = _messages[index];
                return _buildMessageBubble(context, msg);
              },
            ),
          ),

          // 3. Khung nhap cau hoi chat
          SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.all(t.space3),
              decoration: BoxDecoration(
                color: t.surfaceCard,
                border: Border(top: BorderSide(color: t.borderSubtle)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _inputCtrl,
                      label: 'Nhập câu hỏi cho Trợ lý AI',
                      hintText: 'VD: Tối nay 19h còn sân nào gần tôi?',
                      prefixIcon: Icons.chat_bubble_outline_rounded,
                    ),
                  ),
                  SizedBox(width: t.space2),
                  AppButton(
                    label: 'Gửi',
                    leadingIcon: Icons.send_rounded,
                    variant: AppButtonVariant.primary,
                    onPressed: () => _sendMessage(_inputCtrl.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: t.space4,
          vertical: t.space3,
        ),
        decoration: BoxDecoration(
          color: t.surfaceCard,
          borderRadius: BorderRadius.circular(t.radiusCard),
          border: Border.all(color: t.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: t.actionPrimary,
              ),
            ),
            SizedBox(width: t.space3),
            Text(
              'Trợ lý AI đang kiểm tra lịch sân trống...',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, AiChatMessage msg) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: EdgeInsets.all(t.space4),
          decoration: BoxDecoration(
            color: t.actionPrimary,
            borderRadius: BorderRadius.circular(t.radiusCard),
          ),
          child: Text(
            msg.text,
            style: textTheme.bodyMedium?.copyWith(
              color: t.onActionPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620),
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
                Row(
                  children: [
                    Icon(
                      Icons.smart_toy_outlined,
                      size: 18,
                      color: t.actionPrimary,
                    ),
                    SizedBox(width: t.space2),
                    Text(
                      'Trợ lý AI Badminton Hub',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: t.actionPrimary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: msg.isReported ? null : () => _openReportDialog(msg),
                  borderRadius: BorderRadius.circular(t.radiusControl),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: t.space2,
                      vertical: 2,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 14,
                          color: msg.isReported
                              ? t.statusCancelled.foreground
                              : t.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          msg.isReported ? 'Đã báo cáo' : 'Báo cáo',
                          style: textTheme.labelSmall?.copyWith(
                            color: msg.isReported
                                ? t.statusCancelled.foreground
                                : t.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: t.space2),
            Text(msg.text, style: textTheme.bodyMedium),
            if (msg.recommendedVenues.isNotEmpty) ...[
              SizedBox(height: t.space3),
              ...msg.recommendedVenues.map(
                (venue) => _buildRecommendedVenueCard(context, venue),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// The san kem nut "Dat ngay" -> C-05 theo dac ta FE-45
  Widget _buildRecommendedVenueCard(
    BuildContext context,
    VenueDetailModel venue,
  ) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final s = venue.summary;

    return Padding(
      padding: EdgeInsets.only(top: t.space2),
      child: Container(
        padding: EdgeInsets.all(t.space3),
        decoration: BoxDecoration(
          color: t.surfaceMuted,
          borderRadius: BorderRadius.circular(t.radiusControl),
          border: Border.all(color: t.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    s.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                StatusChip(
                  status: s.availableCourtCount > 0
                      ? CourtBookingStatus.activeConfirmed
                      : CourtBookingStatus.maintenanceOrOccupied,
                  customLabel: s.availableCourtCount > 0
                      ? 'Còn ${s.availableCourtCount} sân trống'
                      : 'Hết sân',
                ),
              ],
            ),
            SizedBox(height: t.space1),
            Text(
              '${s.address} (Cách ${s.distanceKm.toStringAsFixed(1)} km)',
              style: textTheme.bodySmall,
            ),
            SizedBox(height: t.space2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PriceText(
                  amountVnd: s.minPricePerHour,
                  suffix: '/giờ',
                ),
                Row(
                  children: [
                    AppButton(
                      label: 'Chi tiết (C-03)',
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => VenueDetailScreen(venue: venue),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: t.space2),
                    AppButton(
                      label: 'Đặt ngay (C-05)',
                      leadingIcon: Icons.flash_on_rounded,
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => SlotSelectionScreen(venue: venue),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
