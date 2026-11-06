import 'package:example/app.dart';
import 'package:example/pages/product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CheckoutFlow использует один MaterialApp и один Scaffold',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(ProductPage), findsOneWidget);
  });

  testWidgets('переход в beGateway не добавляет второй MaterialApp',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buy Now'));
    await tester.pumpAndSettle();

    // Ядро рисует свою страницу внутри того же MaterialApp.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(ProductPage), findsNothing);
  });
}
