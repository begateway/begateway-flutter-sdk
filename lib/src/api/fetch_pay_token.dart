import 'dart:convert';

import 'package:begateway_flutter_sdk/src/api/api_client.dart';
import 'package:begateway_flutter_sdk/src/api/checkout_request.dart';
import 'package:begateway_flutter_sdk/src/constants/constants.dart';
import 'package:begateway_flutter_sdk/src/models/checkout_token.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:flutter/material.dart';

/// Авторизационный токен для платёжных эндпоинтов (Apple/Google Pay).
///
/// Если [PaymentConfig.publicKey] длинный (более 64 символов) — это
/// публичный ключ, который сам по себе токеном не является: сначала
/// создаётся checkout и берётся его токен ([fetchPayToken]). Короткий
/// ключ — токен уже лежит в [AppState.token].
///
/// Возвращает пустую строку, если токен получить не удалось: ошибка
/// при этом уже доведена до состояния (индикатор снят, торговец
/// уведомлён), вызывающий код просто прекращает работу.
Future<String> resolveToken(AppState appState) async {
  if (appState.config.publicKey.length > 64) {
    final token = await fetchPayToken(appState) ?? '';
    appState.setToken(token);
    return token;
  }
  return appState.token;
}

/// Создание checkout и получение токена платежа.
///
/// Возвращает токен или null, если запрос не выполнен — в этом
/// случае индикатор загрузки снимается здесь, чтобы он не завис.
Future<String?> fetchPayToken(
  AppState appState,
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
      return CheckoutToken.fromJson(answearSend).token;
    }
    // запрос не выполнен
    appState.setIsLoading(false);
    appState.answearBegateway(answearSend);
  } catch (e) {
    // обработка ошибок
    appState.setIsLoading(false);
    debugPrint('Error: $e');
  }
  return null;
}
