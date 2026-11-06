import 'dart:convert';

import 'package:begateway_flutter_sdk/src/models/apple_pay_payment.dart';
import 'package:begateway_flutter_sdk/src/models/checkout_status.dart';
import 'package:begateway_flutter_sdk/src/models/checkout_token.dart';
import 'package:begateway_flutter_sdk/src/models/google_pay_payment.dart';
import 'package:begateway_flutter_sdk/src/models/payment_response.dart';
import 'package:begateway_flutter_sdk/src/models/save_card_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckoutToken', () {
    test('токен читается из реального тела ответа', () {
      final json = jsonDecode('{"checkout":{"token":"ch_123"}}');
      final checkout = CheckoutToken.fromJson(json);

      expect(checkout.token, 'ch_123');
      expect(checkout.redirectUrl, isNull);
    });

    test('redirect_url читается, когда есть', () {
      final json = jsonDecode(
          '{"checkout":{"token":"ch_123","redirect_url":"https://x/y"}}');
      final checkout = CheckoutToken.fromJson(json);

      expect(checkout.redirectUrl, 'https://x/y');
    });

    test('без checkout — ArgumentError', () {
      expect(() => CheckoutToken.fromJson(const {}), throwsArgumentError);
    });

    test('без checkout.token — ArgumentError', () {
      expect(
        () => CheckoutToken.fromJson(const {
          'checkout': {'status': 'pending'}
        }),
        throwsArgumentError,
      );
    });
  });

  group('CheckoutStatus', () {
    test('статус читается, company ещё нет', () {
      final json = jsonDecode('{"checkout":{"status":"pending"}}');
      final status = CheckoutStatus.fromJson(json);

      expect(status.status, 'pending');
      expect(status.companyName, isNull);
    });

    test('company.name читается при финальном статусе', () {
      final json = jsonDecode(
          '{"checkout":{"status":"successful","company":{"name":"Example"}}}');
      final status = CheckoutStatus.fromJson(json);

      expect(status.status, 'successful');
      expect(status.companyName, 'Example');
    });

    test('без checkout.status — ArgumentError', () {
      expect(() => CheckoutStatus.fromJson(const {'checkout': {}}),
          throwsArgumentError);
    });
  });

  group('PaymentResponse', () {
    test('успешный платёж с картой: ключи сервера приведены к модели', () {
      final json = jsonDecode('{"response":{"status":"successful",'
          '"credit_card":{"brand":"VISA","last_4":"1111","token":"save_tok"}}}');
      final payment = PaymentResponse.fromJson(json);

      expect(payment.status, 'successful');
      expect(payment.creditCard?.brand, 'VISA');
      expect(payment.creditCard?.lastFourNumbers, '1111');
      expect(payment.creditCard?.saveToken, 'save_tok');
      expect(payment.url, isNull);
    });

    test('3D Secure: url и result_url читаются', () {
      final json = jsonDecode('{"response":{"status":"incomplete",'
          '"url":"https://3ds","result_url":"https://return"}}');
      final payment = PaymentResponse.fromJson(json);

      expect(payment.status, 'incomplete');
      expect(payment.url, 'https://3ds');
      expect(payment.resultUrl, 'https://return');
      expect(payment.creditCard, isNull);
    });

    test('ошибка без credit_card не роняет парсинг', () {
      // Раньше data['credit_card'] as Map падал, и ответ торговцу
      // терялся в catch.
      final json = jsonDecode('{"response":{"status":"error"}}');
      final payment = PaymentResponse.fromJson(json);

      expect(payment.status, 'error');
      expect(payment.creditCard, isNull);
    });

    test('без response — ArgumentError', () {
      expect(() => PaymentResponse.fromJson(const {'error': 'boom'}),
          throwsArgumentError);
    });
  });

  group('SaveCardModel', () {
    test('читает записанные карты', () {
      final json = jsonDecode(
          '{"brand":"VISA","lastFourNumbers":"1111","saveToken":"t1"}');
      final card = SaveCardModel.fromJson(json);

      expect(card.brand, 'VISA');
      expect(card.lastFourNumbers, '1111');
      expect(card.saveToken, 't1');
    });

    test('отсутствующие ключи дают null, а не исключение', () {
      final card = SaveCardModel.fromJson(const {});

      expect(card.brand, isNull);
      expect(card.lastFourNumbers, isNull);
      expect(card.saveToken, isNull);
    });

    test('значение не-строки даёт null, а не TypeError', () {
      final card = SaveCardModel.fromJson(
          const {'brand': 123, 'lastFourNumbers': '1111', 'saveToken': 't'});

      expect(card.brand, isNull);
      expect(card.saveToken, 't');
    });
  });

  group('ApplePayPayment', () {
    final result = <String, dynamic>{
      'token': jsonEncode({
        'data': 'base64data',
        'signature': 'base64sig',
        'version': 'EC_v1',
        'header': {
          'publicKeyHash': 'hash',
          'ephemeralPublicKey': 'eph',
          'transactionId': 'txn',
        },
      }),
      'paymentMethod': {
        'displayName': 'Visa 1111',
        'network': 'Visa',
        'type': 'debit',
      },
      'transactionIdentifier': 'abc-123',
    };

    test('токен декодируется один раз, поля читаются', () {
      final payment = ApplePayPayment.fromJson(result);

      expect(payment.data, 'base64data');
      expect(payment.signature, 'base64sig');
      expect(payment.version, 'EC_v1');
      expect(payment.publicKeyHash, 'hash');
      expect(payment.ephemeralPublicKey, 'eph');
      expect(payment.transactionId, 'txn');
      expect(payment.displayName, 'Visa 1111');
      expect(payment.network, 'Visa');
      expect(payment.type, 'debit');
      expect(payment.transactionIdentifier, 'abc-123');
    });

    test('toJson собирает узел token в исходной структуре', () {
      final token = ApplePayPayment.fromJson(result).toJson();

      expect(token.keys.toList(),
          ['paymentData', 'paymentMethod', 'transactionIdentifier']);
      final paymentData = token['paymentData'] as Map<String, Object?>;
      expect(paymentData.keys.toList(),
          ['data', 'signature', 'header', 'version']);
      final header = paymentData['header'] as Map<String, Object?>;
      expect(header.keys.toList(),
          ['publicKeyHash', 'ephemeralPublicKey', 'transactionId']);
      expect(token['transactionIdentifier'], 'abc-123');
    });

    test('битый token — FormatException', () {
      final broken = <String, dynamic>{...result, 'token': 'not json'};

      expect(() => ApplePayPayment.fromJson(broken), throwsFormatException);
    });

    test('без header в токене — ArgumentError', () {
      final broken = <String, dynamic>{
        ...result,
        'token': jsonEncode({'data': 'd', 'signature': 's', 'version': 'v'}),
      };

      expect(() => ApplePayPayment.fromJson(broken), throwsArgumentError);
    });

    test('без paymentMethod — ArgumentError', () {
      final broken = <String, dynamic>{
        'token': result['token'],
        'transactionIdentifier': 'abc-123',
      };

      expect(() => ApplePayPayment.fromJson(broken), throwsArgumentError);
    });
  });

  group('GooglePayPayment', () {
    final result = <String, dynamic>{
      'apiVersion': 2,
      'apiVersionMinor': 0,
      'paymentMethodData': {
        'description': 'Visa •••• 1111',
        'type': 'CARD',
        'info': {'cardNetwork': 'VISA', 'cardDetails': '•••• 1111'},
        'tokenizationData': {
          'type': 'PAYMENT_GATEWAY',
          'token': '{"token":"json-token"}',
        },
      },
    };

    test('все поля читаются из результата', () {
      final payment = GooglePayPayment.fromJson(result);

      expect(payment.apiVersion, 2);
      expect(payment.apiVersionMinor, 0);
      expect(payment.paymentMethodData.description, 'Visa •••• 1111');
      expect(payment.paymentMethodData.type, 'CARD');
      expect(payment.paymentMethodData.info.cardNetwork, 'VISA');
      expect(payment.paymentMethodData.info.cardDetails, '•••• 1111');
      expect(payment.paymentMethodData.tokenizationType, 'PAYMENT_GATEWAY');
      expect(payment.paymentMethodData.token, '{"token":"json-token"}');
    });

    test('без версий — дефолты 2 и 0', () {
      final withoutVersions = Map<String, dynamic>.of(result)
        ..remove('apiVersion')
        ..remove('apiVersionMinor');
      final payment = GooglePayPayment.fromJson(withoutVersions);

      expect(payment.apiVersion, 2);
      expect(payment.apiVersionMinor, 0);
    });

    test('без paymentMethodData — ArgumentError', () {
      expect(() => GooglePayPayment.fromJson(const {}), throwsArgumentError);
    });

    test('без tokenizationData.token — ArgumentError', () {
      final broken = <String, dynamic>{
        'paymentMethodData': {
          'tokenizationData': {'type': 'PAYMENT_GATEWAY'},
        },
      };

      expect(() => GooglePayPayment.fromJson(broken), throwsArgumentError);
    });

    test('toJson: токен остаётся строкой, пустые поля опущены', () {
      final minimal = <String, dynamic>{
        'paymentMethodData': {
          'tokenizationData': {'token': '{"token":"x"}'},
        },
      };
      final request = GooglePayPayment.fromJson(minimal).toJson();

      expect(request['apiVersion'], 2);
      expect(request['apiVersionMinor'], 0);
      final methodData = request['paymentMethodData'] as Map<String, Object?>;
      expect(methodData.containsKey('description'), isFalse);
      expect(methodData.containsKey('type'), isFalse);
      expect(methodData['info'], isEmpty);
      final tokenization =
          methodData['tokenizationData'] as Map<String, Object?>;
      expect(tokenization['type'], 'PAYMENT_GATEWAY');
      // Строковый JSON-токен не декодируется — уходит строкой,
      // как в официальной JS-библиотеке bePaid.
      expect(tokenization['token'], '{"token":"x"}');
      expect(tokenization['token'], isA<String>());
    });

    test('toJson повторяет структуру полного результата', () {
      final request = GooglePayPayment.fromJson(result).toJson();

      expect(request.keys.toList(),
          ['apiVersionMinor', 'apiVersion', 'paymentMethodData']);
      final methodData = request['paymentMethodData'] as Map<String, Object?>;
      expect(methodData['description'], 'Visa •••• 1111');
      expect(methodData['type'], 'CARD');
      expect(methodData['info'],
          {'cardNetwork': 'VISA', 'cardDetails': '•••• 1111'});
    });
  });
}
