import 'dart:convert';
import 'dart:io';

import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:begateway_flutter_sdk/src/api/checkout_request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_http.dart';

/// Состояние платежа для теста + запись колбэков наружу.
class _Harness {
  _Harness({
    String publicKey = '',
    String customerAddress = '',
    String customerCity = '',
    String deviceId = '',
  }) {
    state = AppState(
      config: PaymentConfig(
        publicKey: publicKey,
        test: true,
        transactionType: 'payment',
        amount: 100,
        currency: 'USD',
        description: 'тестовый платёж',
        language: 'ru',
        holder: 'Rick Astley',
        customerCountry: 'BY',
        customerEmail: 'buyer@example.com',
        customerContract: false,
        buttonText: 'Оплатить',
        applePayConfig: '',
        googlePayConfig: '',
        paymentItems: const [],
        customerAddress: customerAddress,
        customerCity: customerCity,
        deviceId: deviceId,
      ),
      storage: InMemoryStorage(),
      updateIsBegateway: closes.add,
      answearBegateway: answers.add,
    );
  }

  late final AppState state;

  /// Значения, пришедшие в `updateIsBegateway` (закрытие виджета).
  final closes = <bool>[];

  /// Тела ответов, пришедшие в `answearBegateway`.
  final answers = <Map<String, dynamic>>[];

  /// Тело последнего запроса к эндпоинту, путь которого содержит [pathPart].
  Map<String, dynamic> bodySentTo(FakeHttpClient client, String pathPart) =>
      client.requests.lastWhere((r) => r.url.path.contains(pathPart)).json;
}

/// Валидный результат Apple Pay, как его отдаёт пакет `pay`.
Map<String, dynamic> _applePayResult() => {
      'token': jsonEncode({
        'data': 'data',
        'signature': 'signature',
        'version': 'EC_v1',
        'header': {
          'publicKeyHash': 'public-key-hash',
          'ephemeralPublicKey': 'ephemeral-key',
          'transactionId': 'transaction-id',
        },
      }),
      'paymentMethod': {
        'displayName': 'Visa 1111',
        'network': 'Visa',
        'type': 'debit',
      },
      'transactionIdentifier': 'identifier',
    };

/// Валидный результат Google Pay.
Map<String, dynamic> _googlePayResult() => {
      'apiVersion': 2,
      'apiVersionMinor': 0,
      'paymentMethodData': {
        'description': 'Visa •••• 1111',
        'type': 'CARD',
        'info': {'cardNetwork': 'VISA', 'cardDetails': '1111'},
        'tokenizationData': {
          'type': 'PAYMENT_GATEWAY',
          'token': 'google-token',
        },
      },
    };

/// Маршрутизация запросов как у bePaid: checkout по POST, статус — GET.
FakeHttpHandler _bePaid({
  required FakeHttpResponse payment,
  FakeHttpResponse? checkout,
  FakeHttpResponse? status,
}) =>
    (request) async {
      if (request.method == 'POST' &&
          request.url.path.contains('/checkouts/')) {
        return checkout ??
            FakeHttpResponse(
              201,
              jsonEncode({
                'checkout': {'token': 'checkout-token'},
              }),
            );
      }
      if (request.method == 'POST') {
        return payment;
      }
      return status ??
          FakeHttpResponse(
            200,
            jsonEncode({
              'checkout': {'status': 'pending'},
            }),
          );
    };

/// Ждёт выполнения условия — для неожидаемых (fire-and-forget) вызовов.
Future<void> _waitUntil(bool Function() condition) async {
  for (var i = 0; i < 200; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('условие не выполнилось за секунду');
}

void main() {
  setUpAll(() {
    // Ошибки в тестах ожидаемы — не засоряем вывод.
    debugPrint = (String? message, {int? wrapWidth}) {};
  });

  group('заголовки', () {
    test('paymentHeaders: один набор, авторизация из токена', () {
      expect(paymentHeaders('checkout-token'), {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Version': '2.1',
        'Authorization': 'checkout-token',
      });
    });

    test('checkoutHeaders: авторизуется публичным ключом', () {
      final h = _Harness(publicKey: 'short-key');

      expect(checkoutHeaders(h.state)['Authorization'], 'short-key');
    });
  });

  group('данные клиента', () {
    test('по умолчанию пустые — хардкода нет', () {
      final config = PaymentConfig.empty();

      expect(config.customerAddress, '');
      expect(config.customerCity, '');
      expect(config.deviceId, '');
    });

    test('checkoutBody: пустые адрес и город по умолчанию', () {
      final checkout =
          checkoutBody(AppState.empty())['checkout'] as Map<String, dynamic>;
      final customer = checkout['customer'] as Map<String, dynamic>;

      expect(customer['address'], '');
      expect(customer['city'], '');
    });

    test('checkoutBody: адрес и город берутся из конфига', () {
      final h =
          _Harness(customerAddress: 'ул. Ленина, 1', customerCity: 'Минск');

      final checkout =
          checkoutBody(h.state)['checkout'] as Map<String, dynamic>;
      final customer = checkout['customer'] as Map<String, dynamic>;

      expect(customer['address'], 'ул. Ленина, 1');
      expect(customer['city'], 'Минск');
    });
  });

  group('resolveToken', () {
    test('короткий ключ — это уже токен из состояния', () async {
      final h = _Harness(publicKey: 'short-key');
      h.state.setToken('state-token');

      expect(await resolveToken(h.state), 'state-token');
    });

    test('длинный ключ → создаётся checkout, токен берётся из ответа',
        () async {
      final h = _Harness(publicKey: 'k' * 80);
      final client = FakeHttpClient(
        _bePaid(payment: FakeHttpResponse(201, '{}')),
      );

      final token = await HttpOverrides.runZoned(
        () => resolveToken(h.state),
        createHttpClient: (_) => client,
      );

      expect(token, 'checkout-token');
      expect(h.state.token, 'checkout-token');
      expect(client.requests, hasLength(1));
      expect(client.requests.single.url.path, '/ctp/api/checkouts/');
    });

    test('длинный ключ и сбой checkout → пустая строка, индикатор снят',
        () async {
      final h = _Harness(publicKey: 'k' * 80);
      final client = FakeHttpClient(
        (_) async => FakeHttpResponse(500, jsonEncode({'message': 'сбой'})),
      );

      final token = await HttpOverrides.runZoned(
        () => resolveToken(h.state),
        createHttpClient: (_) => client,
      );

      expect(token, '');
      expect(h.state.isLoading.value, false);
      expect(h.answers.single['message'], 'сбой');
    });
  });

  test('fetchPayToken: не-201 → null, индикатор снят, ответ отдан наружу',
      () async {
    final h = _Harness(publicKey: 'k' * 80);
    final client = FakeHttpClient(
      (_) async => FakeHttpResponse(422, jsonEncode({'message': 'нет'})),
    );

    final token = await HttpOverrides.runZoned(
      () => fetchPayToken(h.state),
      createHttpClient: (_) => client,
    );

    expect(token, isNull);
    expect(h.state.isLoading.value, false);
    expect(h.answers.single['message'], 'нет');
  });

  group('Apple Pay', () {
    test('ошибка платежа → ответ наружу, индикатор снят, виджет не закрыт',
        () async {
      final h = _Harness(
        publicKey: 'k' * 80,
        customerAddress: 'ул. Ленина, 1',
        customerCity: 'Минск',
      );
      final client = FakeHttpClient(
        _bePaid(
            payment: FakeHttpResponse(400, jsonEncode({'message': 'отказ'}))),
      );

      await HttpOverrides.runZoned(
        () => fetchApplePay(_applePayResult(), h.state),
        createHttpClient: (_) => client,
      );

      expect(h.answers.single['message'], 'отказ');
      expect(h.state.isLoading.value, false,
          reason: 'индикатор не должен зависнуть');
      expect(h.closes, isEmpty, reason: 'новых точек закрытия не добавляли');

      final payment = h.bodySentTo(client, '/apple_pay/payment/');
      final customer = payment['customer'] as Map<String, dynamic>;
      expect(payment['token'], 'checkout-token');
      expect(customer['address'], 'ул. Ленина, 1');
      expect(customer['city'], 'Минск');
    });

    test('успешный платёж → опрос статуса закрывает виджет', () async {
      final h = _Harness(publicKey: 'k' * 80);
      final client = FakeHttpClient(
        _bePaid(
          payment: FakeHttpResponse(201, jsonEncode({'status': 'ok'})),
          status: FakeHttpResponse(
            200,
            jsonEncode({
              'checkout': {
                'status': 'successful',
                'company': {'name': 'ООО Ромашка'},
              },
            }),
          ),
        ),
      );

      await HttpOverrides.runZoned(
        () => fetchApplePay(_applePayResult(), h.state),
        createHttpClient: (_) => client,
      );
      await _waitUntil(() => h.closes.isNotEmpty);

      expect(h.closes, [false]);
      expect(await h.state.storage.getCompanyName(), 'ООО Ромашка');
    });

    test('без токена запрос не отправляется', () async {
      final h = _Harness(publicKey: 'short-key');
      final client = FakeHttpClient(
        _bePaid(payment: FakeHttpResponse(201, '{}')),
      );

      await HttpOverrides.runZoned(
        () => fetchApplePay(_applePayResult(), h.state),
        createHttpClient: (_) => client,
      );

      expect(client.requests, isEmpty);
    });
  });

  test('Google Pay: данные клиента из конфига, ошибка отдаётся наружу',
      () async {
    final h = _Harness(
      publicKey: 'short-key',
      customerAddress: 'ул. Ленина, 1',
      customerCity: 'Минск',
    );
    h.state.setToken('checkout-token');
    final client = FakeHttpClient(
      _bePaid(payment: FakeHttpResponse(400, jsonEncode({'message': 'отказ'}))),
    );

    await HttpOverrides.runZoned(
      () => fetchGooglePay(_googlePayResult(), h.state),
      createHttpClient: (_) => client,
    );

    final payment = h.bodySentTo(client, '/google_pay/payment/');
    final customer = payment['customer'] as Map<String, dynamic>;
    expect(customer['address'], 'ул. Ленина, 1');
    expect(customer['city'], 'Минск');
    expect(customer['email'], 'buyer@example.com');
    expect(h.answers.single['message'], 'отказ');
  });

  test('fetchPayCard: device_id берётся из конфига, а не хардкодится',
      () async {
    final h = _Harness(deviceId: 'device-42');
    final client = FakeHttpClient(
      (_) async => FakeHttpResponse(
        200,
        jsonEncode({
          'response': {'status': 'error'},
        }),
      ),
    );

    await HttpOverrides.runZoned(
      () => fetchPayCard(
        h.state,
        'checkout-token',
        'Rick Astley',
        '4200000000000000',
        '12/30',
        '123',
        false,
        '',
      ),
      createHttpClient: (_) => client,
    );

    final payment = h.bodySentTo(client, '/payments/');
    final request = payment['request'] as Map<String, dynamic>;
    final customer = request['customer'] as Map<String, dynamic>;
    expect(customer['device_id'], 'device-42');
  });
}
