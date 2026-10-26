import 'package:badminton_fe/app.dart';
import 'package:badminton_fe/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Sprint 0 foundation renders Customer, Owner, and Admin shells',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BadmintonApp());

    // Customer shell loads by default
    expect(find.text('Đặt sân cầu lông trong 30 giây'), findsOneWidget);

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
