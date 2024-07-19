import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:autologapp/garage_page.dart';
import 'garage_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient client;

  setUp(() {
    client = MockClient();
  });

  group('CarUI', () {
    testWidgets('adds a car successfully', (WidgetTester tester) async {
      when(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
          (_) async => http.Response('{"error": "", "success": true}', 200));

      await tester.pumpWidget(MaterialApp(
        home: CarUI(
            userId: 1, firstName: 'test', lastName: 'test', email: 'test'),
      ));

      // Open the Add Car dialog
      await tester.tap(find.text('ADD VEHICLE'));
      await tester.pumpAndSettle();

      // Enter car details
      await tester.enterText(find.byType(TextFormField).at(0), 'Toyota');
      await tester.enterText(find.byType(TextFormField).at(1), 'Camry');
      await tester.enterText(find.byType(TextFormField).at(2), '2020');
      await tester.enterText(find.byType(TextFormField).at(3), '15000');
      await tester.enterText(find.byType(TextFormField).at(4), 'Blue');

      // Add the car
      await tester.tap(find.text('Add Vehicle'));
      await tester.pump();

      // Verify the car was added and the dialog was closed
      verify(client.post(
        Uri.parse('https://autolog-b358aa95bace.herokuapp.com/api/addcar'),
        headers: anyNamed('headers'),
        body: jsonEncode(<String, dynamic>{
          'userId': 1,
          'make': 'Toyota',
          'model': 'Camry',
          'year': '2020',
          'odometer': '15000',
          'color': 'Blue',
        }),
      )).called(1);

      // Ensure the dialog is closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('deletes a car successfully', (WidgetTester tester) async {
      when(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
          (_) async => http.Response('{"error": "", "success": true}', 200));

      await tester.pumpWidget(MaterialApp(
        home: CarUI(
            userId: 1, firstName: 'test', lastName: 'test', email: 'test'),
      ));

      // Add a car to the list (simulate initial state)
      final car = {
        'carId': 1,
        'make': 'Toyota',
        'model': 'Camry',
        'year': '2020',
        'odometer': '15000',
        'color': 'Blue',
      };
      final carUiState = tester.state<CarUIState>(find.byType(CarUI));
      carUiState.setState(() {
        carUiState.cars.add(car);
      });

      await tester.pump();

      // Open the menu and delete the car
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete').last);
      await tester.pump();

      // Verify the car was deleted
      verify(client.post(
        Uri.parse('https://autolog-b358aa95bace.herokuapp.com/api/deletecar'),
        headers: anyNamed('headers'),
        body: jsonEncode(<String, dynamic>{
          'userId': 1,
          'carId': 1,
        }),
      )).called(1);

      // Ensure the car is removed from the list
      expect(carUiState.cars, isEmpty);
    });
  });
}
