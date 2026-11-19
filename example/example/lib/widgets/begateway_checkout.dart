import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter/material.dart';

import '../begateway_pages.dart';
import '../configuration_apple_pay.dart';
import '../configuration_google_pay.dart';
import '../products.dart';
import '../utils/shared_prefs_storage.dart';

/// Конфигурация демо-платежа beGateway, вынесенная из экрана приложения.
///
/// Здесь только данные и колбэки — состояние флоу живёт в [CheckoutFlow],
/// поэтому виджет не создаёт вложенный MaterialApp/Scaffold.
class BegatewayCheckout extends StatelessWidget {
  const BegatewayCheckout({
    super.key,
    required this.onShowBegateway,
    required this.onAnswer,
  });

  /// Вызывается ядром при входе/выходе из платёжного флоу.
  final ValueChanged<bool> onShowBegateway;

  /// Ответ checkout от beGateway.
  final ValueChanged<Map<String, dynamic>> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Begateway(
      // реализация страниц оплаты
      pages: const ExampleBegatewayPages(),
      // реализация хранилища сохранённых карт
      storage: const SharedPrefsStorage(),
      // обязательные параметры
      showIsBegateway: onShowBegateway,
      getAnswearFromBegateway: onAnswer,
      publicKey:
          'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1s8MCrSYRgxX768baEW5tpkGEi8BwAWHAaJy1amnbv+nyGF6ponAic4up+FtiRw+LHLYZXx19RVKX8dCoK7vrYFMjb7INhNILzv7XJvPqcPdyYhSoZ88AteRrbHhtxm7V/3MQyzJNPa6Sgam7+y1n0ZVIvoQBlIo9oTxRWGoFWBJ8pK/RDnvzWSQYf5Ru0jU6hMO5GizkWoleDgujUQy/q0RQi27MGcEOcq0TugCuV3jxS3cLIvLRWth24lNAr1ZSGM8W54DwcLYR3ioqtpngi+c8SryUd2eDxRq8+q+p0XuXbG+jr/HKq4d+g1JOQYpvGNUBbN+Mc3djVgyNb6n5wIDAQAB',
      test: true,
      transactionType: 'payment',
      amount: 4299,
      currency: 'GBP',
      description: 'Some description about product',
      language: 'ru',
      holder: 'Rick Astley',
      customerCountry: 'GB',
      customerEmail: 'jake@example.com',
      customerContract: true,
      buttonText: 'Купить часы 42.99\$',
      applePayConfig: defaultApplePay,
      googlePayConfig: defaultGooglePay,
      paymentItems: products,

      // необязательные параметры оформления

      // cardNumberColor: 0xFF1d1d21,
      // cardNumberSize: 14,
      // cardNumberHintColor: 0xFF787982,
      // cardNumberHintSize: 14,
      // cardNumberHintText: 'Custom text',
      // cardNumberTitleColor: 0xFF0526fc,
      // cardNumberTitleSize: 14,
      // cardNumberTitleText: 'Custom title',
      // cardNumberHintHide: false,
      // cardNumberTitleHide: false,

      // expireDateColor: 0xFF1d1d21,
      // expireDateSize: 14,
      // expireDateHintColor: 0xFF787982,
      // expireDateHintSize: 14,
      // expireDateHintText: 'Text',
      // expireDateTitleColor: 0xFF0526fc,
      // expireDateTitleSize: 14,
      // expireDateTitleText: 'Custom title',
      // expireDateHintHide: false,
      // expireDateTitleHide: false,

      // cvcCvvColor: 0xFF1d1d21,
      // cvcCvvSize: 14,
      // cvcCvvHintColor: 0xFF787982,
      // cvcCvvHintSize: 14,
      // cvcCvvHintText: 'Custom text',
      // cvcCvvTitleColor: 0xFF0044FF,
      // cvcCvvTitleSize: 14,
      // cvcCvvTitleText: 'Custom title',
      // cvcHideText: false,
      // cvcCvvHintHide: false,
      // cvcCvvTitleHide: false,

      // cardholderColor: 0xFF1d1d21,
      // cardholderSize: 14,
      // cardholderHintColor: 0xFF787982,
      // cardholderHintSize: 14,
      // cardholderHintText: 'Custom text',
      // cardholderTitleColor: 0xFF0526fc,
      // cardholderTitleSize: 14,
      // cardholderTitleText: 'Custom title',
      // cardholderHintHide: false,
      // cardholderTitleHide: false,

      // borderColor: 0xFF787982,
      // borderFocusColor: 0xFF0526fc,
      // borderWidth: 1,
      // borderFocusWidth: 2,

      // errorBorderColor: 0xFFfc0505,
      // errorBorderWidth: 1,
      // errorBorderFocusColor: 0xFFfc0505,
      // errorBorderFocusWidth: 2,
      // errorTextColor: 0xFFfc0505,
      // errorTextSize: 10,

      // errorCardNumberText: 'Custom text error',
      // errorExpireDateText: 'Custom text error',
      // errorCvcCvvText: 'Custom text error',
      // errorCardholderText: 'Custom text error',
      // errorTextHide: true,
    );
  }
}
