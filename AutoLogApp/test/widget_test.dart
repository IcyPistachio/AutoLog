import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart'; 

void main() {
  testWidgets('Login page renders correctly', (WidgetTester tester) async {
    // Build the LoginPage widget
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Verify that certain widgets are present
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(2)); // Login and Sign Up buttons
    expect(find.byType(TextButton), findsOneWidget); // Forgot Password button
  });

  testWidgets('Login form validation works', (WidgetTester tester) async {
    // Build the LoginPage widget
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Find the email and password fields
    final emailField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);

    // Enter invalid email and password
    await tester.enterText(emailField, '');
    await tester.enterText(passwordField, '');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();

    // Verify error messages are displayed
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    // Enter valid email and password
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();

    // Verify that no error messages are displayed
    expect(find.text('Please enter your email'), findsNothing);
    expect(find.text('Please enter your password'), findsNothing);
  });

  testWidgets('Register button enabled with valid inputs', (WidgetTester tester) async {
    // Build the RegisterPage widget
    await tester.pumpWidget(MaterialApp(home: RegisterPage()));

    // Enter valid input in all fields
    await tester.enterText(find.byType(TextFormField).at(0), 'John'); // First Name
    await tester.enterText(find.byType(TextFormField).at(1), 'Doe');  // Last Name
    await tester.enterText(find.byType(TextFormField).at(2), 'vehiclehub4331@gmail.com'); // Email
    await tester.enterText(find.byType(TextFormField).at(3), 'Password123!'); // Password
    await tester.enterText(find.byType(TextFormField).at(4), 'Password123!'); // Confirm Password

    // Rebuild the widget to reflect changes
    await tester.pump();

    // Check if the Register button is enabled
    final registerButton = find.widgetWithText(ElevatedButton, 'Register');
    expect(tester.widget<ElevatedButton>(registerButton).enabled, isTrue);
  });

  testWidgets('Error message displayed for mismatched passwords', (WidgetTester tester) async {
    // Build the RegisterPage widget
    await tester.pumpWidget(MaterialApp(home: RegisterPage()));

    // Enter input where passwords do not match
    await tester.enterText(find.byType(TextFormField).at(0), 'John'); // First Name
    await tester.enterText(find.byType(TextFormField).at(1), 'Doe');  // Last Name
    await tester.enterText(find.byType(TextFormField).at(2), 'vehiclehub4331@gmail.com'); // Email
    await tester.enterText(find.byType(TextFormField).at(3), 'Password123!'); // Password
    await tester.enterText(find.byType(TextFormField).at(4), 'Password123'); // Confirm Password

    // Tap the Register button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));

    // Rebuild the widget to reflect changes
    await tester.pump();

    // Verify that the error message for mismatched passwords is displayed
    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
