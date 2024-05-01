import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_application/main.dart';

void main() {
  testWidgets('Weather application displays weather information',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the initial UI shows a text field for entering a city name.
    expect(find.byType(TextField), findsOneWidget);

    // Enter a city name in the text field.
    await tester.enterText(find.byType(TextField), 'New York');

    // Tap the search icon to fetch weather data.
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    // Verify that the loading indicator is shown.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the weather data to be loaded.
    await tester.pump(const Duration(seconds: 2));

    // Verify that the weather information is displayed.
    expect(find.text('New York'), findsOneWidget);
    expect(find.byType(Icon),
        findsOneWidget); // You can further refine this check based on your actual UI
    expect(find.byType(Text), findsWidgets);
  });
}
