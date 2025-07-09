import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_admin_dashboard/main.dart'; // make sure this matches your file structure

void main() {
  testWidgets('Admin login page loads and navigates to dashboard after valid login', (WidgetTester tester) async {
    // Load the admin app
    await tester.pumpWidget(const FruitAdminApp());

    // Verify login screen is shown
    expect(find.text('Admin Login'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Enter valid credentials
    await tester.enterText(find.byType(TextFormField).at(0), 'admin@fruit.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin123');

    // Tap on login button
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Expect dashboard after login
    expect(find.text('Admin Home'), findsOneWidget); // Change if your homepage uses a different title
  });
}
