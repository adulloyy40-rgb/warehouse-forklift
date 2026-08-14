import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/presentation/app/app.dart';

void main() {
  testWidgets(
    'Warehouse Forklift app loads successfully',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const WarehouseForkliftApp(),
      );

      expect(
        find.text('Warehouse Forklift'),
        findsOneWidget,
      );
    },
  );
}
