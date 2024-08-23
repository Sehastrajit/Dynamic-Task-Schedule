import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('MyApp widget test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}