import 'package:begateway_flutter_sdk/src/providers/app_state.dart';

/// Заглушка для `settings.return_url`.
///
/// Платёжная страница bePaid перенаправляет покупателя сюда после оплаты,
/// WebView перехватывает переход по этому адресу и закрывает себя
/// (см. `WebViewApp`), после чего запрашивается статус транзакции.
const String savedCardReturnUrl = 'https://begateway.flutter/return';

/// Заголовки checkout-запроса (создание токена платежа).
///
/// Authorization для checkout — публичный ключ магазина.
Map<String, String> checkoutHeaders(AppState appState) =>
    paymentHeaders(appState.config.publicKey);

/// Заголовки API-запросов SDK: используются и для checkout, и для
/// платёжных эндпоинтов (оплата по карте, Apple Pay, Google Pay) —
/// набор один и тот же, меняется только авторизация.
///
/// Для checkout это публичный ключ магазина (см. [checkoutHeaders]),
/// для платёжных эндпоинтов — токен checkout (см. `resolveToken`).
Map<String, String> paymentHeaders(String token) => {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-Version': '2.1',
      'Authorization': token,
    };

/// Тело checkout-запроса. Идентично для оплаты по карте
/// (`fetchPayWithToken`) и для Apple/Google Pay (`fetchPayToken`).
///
/// Если в [AppState.saveCardToken] лежит токен сохранённой карты, запрос
/// становится инициализацией оплаты по ней: токен уходит в
/// `payment_method.credit_card.token`, а покупатель подтверждает платёж
/// на платёжной странице bePaid (документация bePaid, «Платежи по
/// сохранённым данным карты» → «Интеграция через платёжную страницу»).
Map<String, dynamic> checkoutBody(AppState appState) {
  final savedCardToken = appState.saveCardToken;

  return {
    'checkout': {
      'test': appState.config.test,
      'transaction_type': appState.config.transactionType,
      'attempts': 3,
      'settings': {
        'save_card_toggle': {
          'customer_contract': appState.config.customerContract,
        },
        'auto_return': 0,
        'button_text': appState.config.buttonText,
        'language': appState.config.language,
        // После оплаты по сохранённой карте покупатель сразу возвращается
        // на ссылку, которую перехватывает WebView.
        if (savedCardToken.isNotEmpty) 'return_url': savedCardReturnUrl,
        'customer_fields': {
          'visible': ['first_name', 'last_name'],
          'read_only': ['email'],
        },
        'credit_card_fields': {
          'holder': appState.config.holder,
          'read_only': ['holder'],
        },
      },
      'order': {
        'currency': appState.config.currency,
        'amount': appState.config.amount,
        'description': appState.config.description,
        'additional_data': {
          // По документации bePaid эти значения заставляют систему вернуть
          // токен карты для последующих списаний без повторного ввода
          // реквизитов. `card_on_file` работает не со всеми эквайерами.
          'contract': ['recurring', 'card_on_file'],
        },
      },
      if (savedCardToken.isNotEmpty)
        'payment_method': {
          'credit_card': {'token': savedCardToken},
        },
      'customer': {
        'address': appState.config.customerAddress,
        'country': appState.config.customerCountry,
        'city': appState.config.customerCity,
        'email': appState.config.customerEmail,
      },
    },
  };
}
