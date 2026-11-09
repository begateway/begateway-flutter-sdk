import 'package:begateway_flutter_sdk/src/api/checkout_request.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppState.empty() отдаёт значения по умолчанию', () {
    final state = AppState.empty();

    expect(state.config.language, 'en');
    expect(state.config.publicKey, '');
    expect(state.config.amount, 0);
    expect(state.config.test, false);
    expect(state.config.customerContract, false);
    expect(state.config.paymentItems, isEmpty);
    expect(state.isLoading.value, false);

    // style-поля не заданы — остаются дефолтными
    expect(state.config.cardNumber.color, isNull);
    expect(state.config.error.hideText, false);
  });

  testWidgets('без AppStateScope.of() возвращает пустой AppState, не бросает',
      (tester) async {
    late AppState captured;

    await tester.pumpWidget(
      Builder(
        builder: (context) {
          captured = AppStateScope.of(context);
          return const SizedBox();
        },
      ),
    );

    expect(captured.config.language, 'en');
    expect(captured.config.publicKey, '');
  });

  testWidgets('AppStateScope.of() возвращает переданный notifier',
      (tester) async {
    final state = AppState.empty();
    late AppState captured;

    await tester.pumpWidget(
      AppStateScope(
        notifier: state,
        child: Builder(
          builder: (context) {
            captured = AppStateScope.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(identical(captured, state), isTrue);
  });

  testWidgets('listen: false также находит AppState', (tester) async {
    final state = AppState.empty();
    late AppState captured;

    await tester.pumpWidget(
      AppStateScope(
        notifier: state,
        child: Builder(
          builder: (context) {
            captured = AppStateScope.of(context, listen: false);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(identical(captured, state), isTrue);
  });

  test('ValueNotifier не уведомляет при повторении значения', () {
    // На этом опирается _isValid.value = ... в форме: присваивание
    // без реального изменения не вызывает перестройку.
    final notifier = ValueNotifier<bool>(false);
    var notified = 0;
    notifier.addListener(() => notified++);

    notifier.value = false;
    expect(notified, 0);

    notifier.value = true;
    expect(notified, 1);

    notifier.value = true;
    expect(notified, 1);

    notifier.dispose();
  });

  test('checkoutBody: без сохранённой карты платёжная страница не открывается',
      () {
    final checkout =
        checkoutBody(AppState.empty())['checkout'] as Map<String, dynamic>;

    expect(checkout.containsKey('payment_method'), isFalse);
    final settings = checkout['settings'] as Map<String, dynamic>;
    expect(settings.containsKey('return_url'), isFalse);

    // По документации bePaid именно contract возвращает токен карты
    // для последующих списаний.
    final order = checkout['order'] as Map<String, dynamic>;
    final additionalData = order['additional_data'] as Map<String, dynamic>;
    expect(additionalData['contract'], ['recurring', 'card_on_file']);
  });

  test('checkoutBody: сохранённая карта уходит в payment_method', () {
    final state = AppState.empty()..setSaveCardToken('saved-token-123');

    final checkout = checkoutBody(state)['checkout'] as Map<String, dynamic>;

    final paymentMethod = checkout['payment_method'] as Map<String, dynamic>;
    final creditCard = paymentMethod['credit_card'] as Map<String, dynamic>;
    expect(creditCard['token'], 'saved-token-123');

    // Возврат с платёжной страницы перехватывает WebView.
    final settings = checkout['settings'] as Map<String, dynamic>;
    expect(settings['return_url'], savedCardReturnUrl);
  });

  test('опрос статуса: прошлый таймер отменяется, накопления нет', () async {
    final state = AppState.empty();
    var checks = 0;

    state.scheduleStatusCheck(() => checks++,
        delay: const Duration(milliseconds: 30));
    state.scheduleStatusCheck(() => checks++,
        delay: const Duration(milliseconds: 10));

    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(checks, 1, reason: 'должен сработать только последний таймер');
  });

  test('cancelStatusCheck останавливает опрос', () async {
    final state = AppState.empty();
    var checks = 0;

    state.scheduleStatusCheck(() => checks++,
        delay: const Duration(milliseconds: 10));
    state.cancelStatusCheck();

    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(checks, 0);
  });

  test('dispose отменяет опрос статуса', () async {
    final state = AppState.empty();
    var checks = 0;

    state.scheduleStatusCheck(() => checks++,
        delay: const Duration(milliseconds: 10));
    state.dispose();

    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(checks, 0);
  });
}
