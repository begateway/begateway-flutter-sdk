import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/pages/card_payment_form.dart';

void main() {
  testWidgets('ошибка поля приходит по ValueNotifier и снимается при вводе',
      (tester) async {
    await tester.pumpWidget(
      AppStateScope(
        notifier: AppState.empty(),
        child: const MaterialApp(
          home: Scaffold(body: CardPaymentForm(lang: 'en')),
        ),
      ),
    );
    await tester.pump();

    // Изначально ошибок нет.
    expect(find.text('Card number is required'), findsNothing);

    // Тап по полю срока действия валидирует номер карты: значение
    // уведомителя меняется → ListenableBuilder перестраивает форму.
    await tester.tap(find.byType(TextFormField).at(1));
    await tester.pump();
    expect(find.text('Card number is required'), findsOneWidget);

    // Ввод валидного номера снимает ошибку.
    await tester.enterText(
        find.byType(TextFormField).first, '4111 1111 1111 1111');
    await tester.pump();
    expect(find.text('Card number is required'), findsNothing);
  });

  testWidgets('кнопка оплаты блокируется, пока форма невалидна',
      (tester) async {
    await tester.pumpWidget(
      AppStateScope(
        notifier: AppState.empty(),
        child: const MaterialApp(
          home: Scaffold(body: CardPaymentForm(lang: 'en')),
        ),
      ),
    );
    await tester.pump();

    final button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(button.onPressed, isNull);

    await tester.enterText(
        find.byType(TextFormField).first, '4111 1111 1111 1111');
    await tester.pump();

    // Номер валиден, но остальные поля пусты — кнопка всё ещё заблокирована.
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull);
  });
}
