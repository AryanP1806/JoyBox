// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:joybox/main.dart';

void main() {
  testWidgets('Home screen loads correctly', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const PartyModeratorApp());

    // Let all frames render
    await tester.pumpAndSettle();

    // Verify main title exists
    expect(find.text('Party Moderator'), findsOneWidget);

    // Verify Mr White game card exists
    expect(find.text('Mr White'), findsOneWidget);
  });
}
