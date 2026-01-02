// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazari_app/main.dart' as hazari;

void main() {
  testWidgets('Hazari App loads login screen', (WidgetTester tester) async {
    // Build Hazari App
    await tester.pumpWidget(hazari.HazariApp());

    // Verify login screen loads
    await tester.pumpAndSettle();
    expect(find.text('Hazari'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.byIcon(Icons.construction), findsOneWidget);
    expect(find.text('NEW USER? REGISTER'), findsOneWidget);
  });
}
