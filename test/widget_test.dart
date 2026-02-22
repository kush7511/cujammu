import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cuj/main.dart';

void main() {
  testWidgets('Login screen renders expected fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CUJApp());

    expect(find.text('Central University of Jammu'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Enrollment Number'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}
