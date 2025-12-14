// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirapat_app/app/config/app_constants.dart';

void main() {
  group('AppConstants Tests', () {
    test('appName should be SiRapat App', () {
      expect(AppConstants.appName, 'SiRapat App');
    });

    test('baseUrl should return correct URL based on environment', () {
      // In test mode, should return production or local based on isProduction flag
      expect(AppConstants.baseUrl, isNotEmpty);
      expect(
          AppConstants.baseUrl,
          anyOf(
            equals(AppConstants.productionUrl),
            startsWith('http://'),
          ));
    });

    test('API timeout should be valid duration', () {
      expect(AppConstants.connectionTimeout.inSeconds, greaterThan(0));
      expect(AppConstants.receiveTimeout.inSeconds, greaterThan(0));
    });

    test('pagination constants should be valid', () {
      expect(AppConstants.defaultPageSize, greaterThan(0));
      expect(AppConstants.maxPageSize,
          greaterThanOrEqualTo(AppConstants.defaultPageSize));
    });
  });

  group('Widget Tests', () {
    testWidgets('Material app smoke test', (WidgetTester tester) async {
      // Build a simple MaterialApp to verify framework is working
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
