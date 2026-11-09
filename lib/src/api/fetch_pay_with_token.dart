import 'dart:convert';

import 'package:begateway_flutter_sdk/src/api/api_client.dart';
import 'package:begateway_flutter_sdk/src/api/checkout_request.dart';
import 'package:begateway_flutter_sdk/src/api/fetch_pay_card.dart';
import 'package:begateway_flutter_sdk/src/constants/constants.dart';
import 'package:begateway_flutter_sdk/src/models/checkout_token.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:flutter/material.dart';

Future<void> fetchPayWithToken(
  AppState appState,
  String cardNumber,
  String expiration,
  String cvv,
  String nameHolder,
) async {
  try {
    appState.setIsLoading(true);
    final response = await ApiClient.post(
      Uri.parse(ApiConstants.checkoutUrl),
      headers: checkoutHeaders(appState),
      body: checkoutBody(appState),
    );

    final answearSend = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201) {
      // Successful request: структура ответа проверяется паттерном.
      final checkout = CheckoutToken.fromJson(answearSend);
      appState.setToken(checkout.token);

      if (appState.saveCardToken.isNotEmpty) {
        // Оплата по сохранённой карте: покупатель подтверждает платёж
        // на платёжной странице bePaid, WebView перехватывает возврат
        // по savedCardReturnUrl и запрашивает статус транзакции.
        final redirectUrl = checkout.redirectUrl;
        if (redirectUrl == null) {
          throw ArgumentError('No redirect_url in checkout: $answearSend');
        }
        appState.openWebView(url: redirectUrl, resultUrl: savedCardReturnUrl);
        // Токен уже ушёл в checkout — сбрасываем, чтобы он не попал
        // в следующие запросы (Apple Pay, Google Pay, новая карта).
        appState.setSaveCardToken('');
        return;
      }

      await fetchPayCard(appState, checkout.token, nameHolder, cardNumber,
          expiration, cvv, appState.isSaveCard.value, appState.saveCardToken);
    } else {
      // запрос не выполнен
      appState.updateIsBegateway(false);
      appState.answearBegateway(answearSend);
      appState.setIsLoading(false);
    }
  } catch (e) {
    // обработка ошибок
    appState.setIsLoading(false);
    debugPrint('Error: $e');
  }
}
