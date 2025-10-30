// Basic widget test for Interactive Chart Demo

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('Interactive Chart Demo loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app bar title is present
    expect(find.text('Interactive Chart Demo'), findsOneWidget);

    // Verify that the dark mode toggle button is present
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    // Verify that the chart toggle button is present
    expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
  });
}
