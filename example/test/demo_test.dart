import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iraqi_license_plate_example/main.dart';

void main() {
  testWidgets('random plate, gallery, parse and arabic all work', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();
    expect(find.text('11 A 70634'), findsOneWidget);

    var changed = false;
    for (var i = 0; i < 5 && !changed; i++) {
      await tester.tap(find.text('Random plate'));
      await tester.pumpAndSettle();
      changed = find.text('11 A 70634').evaluate().isEmpty;
    }
    expect(changed, isTrue);

    await tester.tap(find.byIcon(Icons.grid_view));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cargo').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Baghdad · Cargo'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.keyboard));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '١٤ ب ٤٨٢١');
    await tester.pumpAndSettle();
    expect(find.textContaining('Basra'), findsOneWidget);

    await tester.tap(find.text('عربي'));
    await tester.pumpAndSettle();
    expect(find.text('قراءة'), findsOneWidget);
  });
}
