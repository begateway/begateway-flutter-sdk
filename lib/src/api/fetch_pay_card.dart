import 'dart:convert';
import 'package:begateway_flutter_sdk/src/api/api_client.dart';
import 'package:begateway_flutter_sdk/src/api/checkout_request.dart';
import 'package:begateway_flutter_sdk/src/api/fetch_pay_check.dart';
import 'package:begateway_flutter_sdk/src/constants/constants.dart';
import 'package:begateway_flutter_sdk/src/models/payment_response.dart';
import 'package:begateway_flutter_sdk/src/models/save_card_model.dart';

import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:begateway_flutter_sdk/src/utils/customer_name.dart';

import 'package:flutter/material.dart';

Future<void> fetchPayCard(
  AppState appState,
  String token,
  String nameHolder,
  String cardNumber,
  String expiration,
  String cvv,
  bool isSaveCard,
  String saveCardToken,
) async {
  final url = Uri.parse(ApiConstants.paymentUrl);

  final customerName = parseCustomerName(nameHolder);

  final paymentData = {
    'request': {
      'customer': {
        'first_name': customerName.firstName,
        'last_name': customerName.lastName,
        'device_id': appState.config.deviceId,
      },
      'payment_method': 'credit_card',
      'token': token,
      'credit_card': saveCardToken.isEmpty
          ? {
              'save_card': isSaveCard,
              'holder': nameHolder,
              'number': cardNumber,
              'exp_date': expiration,
              'verification_value': cvv,
            }
          : {'token': saveCardToken},
    },
  };

  try {
    final httpResponse = await ApiClient.post(
      url,
      headers: paymentHeaders(token),
      body: paymentData,
    );

    // Тело декодируется один раз: раньше здесь было шесть json.decode
    // по одному и тому же response.body.
    final answearSend = json.decode(httpResponse.body) as Map<String, dynamic>;
    // Структура ответа проверяется паттерном: credit_card может
    // отсутствовать (например, при статусе error).
    final payment = PaymentResponse.fromJson(answearSend);
    final creditCard = payment.creditCard;

    Future<void> saveCardIfRequested() async {
      final saveToken = creditCard?.saveToken;
      if (saveToken != null && appState.isSaveCard.value) {
        await appState.storage.addCard(SaveCardModel(
          brand: creditCard?.brand,
          lastFourNumbers: creditCard?.lastFourNumbers,
          saveToken: saveToken,
        ));
      }
    }

    if (payment.status == 'incomplete') {
      await saveCardIfRequested();
      final url = payment.url;
      final resultUrl = payment.resultUrl;
      if (url == null || resultUrl == null) {
        throw ArgumentError('Incomplete payment without url: $answearSend');
      }
      appState.openWebView(url: url, resultUrl: resultUrl);
      return;
    } else if (payment.status == 'successful' || payment.status == 'failed') {
      await saveCardIfRequested();
      fetchPayCheck(appState);
      return;
    } else if (payment.status == 'error') {
      appState.answearBegateway(answearSend);
      appState.updateIsBegateway(false);
      appState.setIsLoading(false);
      return;
    }
  } catch (e) {
    appState.setIsLoading(false);
    debugPrint('Error: $e');
  }
}
