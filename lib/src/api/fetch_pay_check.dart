import 'dart:convert';

import 'package:begateway_flutter_sdk/src/api/api_client.dart';
import 'package:begateway_flutter_sdk/src/constants/constants.dart';
import 'package:begateway_flutter_sdk/src/models/checkout_status.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:flutter/material.dart';

Future<void> fetchPayCheck(
  AppState appState,
) async {
  final url = Uri.parse(ApiConstants.checkoutUrl + appState.token);
  // данные для заголовков запроса
  final headersData = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-Version': '2.1',
  };
  try {
    // запрос
    appState.setIsLoading(true);
    final response = await ApiClient.get(url, headers: headersData);

    // Тело декодируется один раз: раньше здесь было два json.decode
    // по одному и тому же response.body.
    final answear = json.decode(response.body) as Map<String, dynamic>;
    // Структура ответа проверяется паттерном; company может отсутствовать
    // до финального статуса — тогда companyName остаётся null.
    final checkout = CheckoutStatus.fromJson(answear);

    if (checkout.status == 'successful' ||
        checkout.status == 'failed' ||
        checkout.status == 'error') {
      // Successful request — опрос останавливаем: статус финальный.
      appState.cancelStatusCheck();
      appState.updateIsBegateway(false);
      appState.answearBegateway(answear);
      appState.setIsLoading(false);
      final nameCompany = checkout.companyName;
      if (nameCompany != null) {
        await appState.storage.setCompanyName(nameCompany);
      }
    } else {
      // Статус ещё не финальный — повторяем через 3 секунды. Один таймер
      // на замену старому, накопления опросов больше нет.
      appState.scheduleStatusCheck(() => fetchPayCheck(appState));
    }
  } catch (e) {
    // If Error — пробуем проверить статус ещё раз позже.
    appState.setIsLoading(false);
    debugPrint('Error: $e');
    appState.scheduleStatusCheck(() => fetchPayCheck(appState));
  }
}
