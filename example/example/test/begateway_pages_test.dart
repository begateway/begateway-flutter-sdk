import 'dart:convert';

import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:example/begateway_pages.dart';
import 'package:example/pages/card_payment_form.dart';
import 'package:example/pages/choose_pay.dart';
import 'package:example/utils/shared_prefs_storage.dart';

/// Конфигурация для тестового Begateway.
Begateway _begateway() => Begateway(
      pages: const ExampleBegatewayPages(),
      storage: const SharedPrefsStorage(),
      showIsBegateway: (_) {},
      getAnswearFromBegateway: (_) {},
      publicKey: 'test-public-key',
      test: true,
      transactionType: 'payment',
      amount: 4299,
      currency: 'USD',
      description: 'Test',
      language: 'en',
      holder: 'Rick Astley',
      customerCountry: 'GB',
      customerEmail: 'test@example.com',
      customerContract: true,
      buttonText: 'Pay',
      applePayConfig: '',
      googlePayConfig: '',
      paymentItems: const [],
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('нет сохранённых карт — ядро строит страницу оплаты',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: _begateway()));
    await tester.pumpAndSettle();

    expect(find.byType(CardPaymentForm), findsOneWidget);
    expect(find.byType(ChoosePay), findsNothing);
  });

  testWidgets('есть сохранённые карты — ядро строит страницу выбора',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'cardList': [
        jsonEncode({
          'brand': 'VISA',
          'lastFourNumbers': '1111',
          'saveToken': 'tok1',
        }),
      ],
    });

    await tester.pumpWidget(MaterialApp(home: _begateway()));
    await tester.pumpAndSettle();

    expect(find.byType(ChoosePay), findsOneWidget);
    expect(find.byType(CardPaymentForm), findsNothing);
    expect(find.text('****1111'), findsOneWidget);
  });

  testWidgets('удаление всех карт переводит на страницу оплаты',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'cardList': [
        jsonEncode({
          'brand': 'VISA',
          'lastFourNumbers': '1111',
          'saveToken': 'tok1',
        }),
      ],
    });

    await tester.pumpWidget(MaterialApp(home: _begateway()));
    await tester.pumpAndSettle();

    expect(find.byType(ChoosePay), findsOneWidget);

    // Удаляем единственную карту через колбэк ядра.
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(find.byType(CardPaymentForm), findsOneWidget);
    expect(find.byType(ChoosePay), findsNothing);
  });
}
