import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:midterm_app/main.dart';

void main() {
  testWidgets('Crypto Portfolio app renders portfolio screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Crypto Portfolio'), findsWidgets);
    expect(find.text('All Coins'), findsOneWidget);
    expect(find.text('My Portfolio'), findsOneWidget);
  });
}
