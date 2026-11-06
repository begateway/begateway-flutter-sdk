import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:begateway_flutter_sdk/src/api/api_client.dart';
import 'package:begateway_flutter_sdk/src/api/checkout_request.dart';
import 'package:begateway_flutter_sdk/src/api/fetch_pay_token.dart';
import 'package:begateway_flutter_sdk/src/models/google_pay_payment.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:begateway_flutter_sdk/src/utils/customer_name.dart';
import '../constants/constants.dart';
import 'fetch_pay_check.dart';

Future<void> fetchGooglePay(
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

    final url = Uri.parse(ApiConstants.googlePayUrl);

    // PaymentData от Google Pay (PaymentData.toJson()):
    // {apiVersion, apiVersionMinor,
    //  paymentMethodData: {description, info, tokenizationData, type}}.
    // Раньше эти значения были захардкожены в запросе — теперь структура
    // проверяется паттерном, а тело запроса собирается из модели.
    // Строковый JSON-токен от Google остаётся строкой, как у официальной
    // JS-библиотеки bePaid (js.bepaid.by/widget/google_pay.js).
    final payment = GooglePayPayment.fromJson(result);
    final customerName = parseCustomerName(appState.config.holder);

    final requestData = {
      "request": payment.toJson(),
      "token": token,
      "customer": {
        "first_name": customerName.firstName,
        "last_name": customerName.lastName,
        "address": appState.config.customerAddress,
        "country": appState.config.customerCountry,
        "city": appState.config.customerCity,
        "zip": "",
        "state": "",
        "phone": "",
        // согласовано с Apple Pay: раньше здесь была пустая строка
        "email": appState.config.customerEmail,
      },
      "contract": appState.config.customerContract,
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
