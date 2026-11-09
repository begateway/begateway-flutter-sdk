import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:begateway_flutter_sdk/src/api/api_client.dart';
import 'package:begateway_flutter_sdk/src/api/checkout_request.dart';
import 'package:begateway_flutter_sdk/src/api/fetch_pay_token.dart';
import 'package:begateway_flutter_sdk/src/models/apple_pay_payment.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:begateway_flutter_sdk/src/utils/customer_name.dart';
import '../constants/constants.dart';
import 'fetch_pay_check.dart';

Future<void> fetchApplePay(
  Map<String, dynamic> result,
  AppState appState,
) async {
  try {
    // Токен и заголовки — внутри try: раньше блок токена стоял до try
    // и при сбое падал необработанным исключением.
    final token = await resolveToken(appState);
    if (token.isEmpty) {
      // Ошибка уже доведена до состояния (индикатор снят, торговец
      // уведомлён) — продолжать нечего.
      return;
    }

    final url = Uri.parse(ApiConstants.applePayUrl);

    // Структура результата Apple Pay проверяется паттерном; тело
    // payment-токена декодируется один раз (раньше по нему было шесть
    // json.decode по одному и тому же result["token"]).
    final payment = ApplePayPayment.fromJson(result);
    final customerName = parseCustomerName(appState.config.holder);

    final requestData = {
      'request': {'token': payment.toJson()},
      'token': token,
      'customer': {
        'first_name': customerName.firstName,
        'last_name': customerName.lastName,
        'address': appState.config.customerAddress,
        'country': appState.config.customerCountry,
        'city': appState.config.customerCity,
        'zip': '',
        'state': '',
        'phone': '',
        'email': appState.config.customerEmail,
      },
      'contract': appState.config.customerContract,
      'additional_data': {
        'contract': ["card_on_file"],
        'request_id': '',
      },
      // при необходимости добавьте другие поля данных
    };

    final response = await ApiClient.post(
      url,
      headers: paymentHeaders(token),
      body: requestData,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Платёж создан — опрашиваем статус checkout.
      fetchPayCheck(appState);
    } else {
      // Платёж не создан: индикатор снимаем здесь, тело ответа отдаём
      // наружу. Закрытие виджета не добавляем — оно остаётся только
      // там, где было.
      appState.setIsLoading(false);
      appState.answearBegateway(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
  } catch (e) {
    // обработка ошибок
    appState.setIsLoading(false);
    debugPrint('Error: $e');
  }
}
