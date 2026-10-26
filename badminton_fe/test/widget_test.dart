import 'package:badminton_fe/app.dart';
import 'package:badminton_fe/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Sprint 0-2 renders Customer Explore map (C-01) and route guards',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BadmintonApp());

    // Customer shell loads C-01 Explore screen by default
    expect(
      find.text('C-01 Tìm sân cầu lông theo tên hoặc đường'),
      findsOneWidget,
    );

    // Route guard redirects unauthorized access to current role base path
    expect(
      AppRouteGuard.resolveAllowedPath(
        currentRole: UserRole.customer,
        requestedPath: '/owner/revenue',
      ),
      equals('/customer'),
    );
  });
}
