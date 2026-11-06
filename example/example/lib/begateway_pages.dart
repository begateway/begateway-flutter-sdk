import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter/material.dart';

import 'pages/card_payment_form.dart';
import 'pages/choose_pay.dart';
import 'pages/webview.dart';

/// Реализация страниц оплаты для примера: ядро SDK не содержит UI,
/// всё рисует приложение (см. `BegatewayPages`).
class ExampleBegatewayPages extends BegatewayPages {
  const ExampleBegatewayPages();

  @override
  Widget buildPaymentPage(BuildContext context) {
    final lang = AppStateScope.of(context).config.language.toString();
    return CardPaymentForm(lang: lang);
  }

  @override
  Widget buildChoosePayPage(
    BuildContext context,
    List<SaveCardModel> cards,
    ValueChanged<String> removeCard,
  ) {
    final lang = AppStateScope.of(context).config.language.toString();
    return ChoosePay(savedCards: cards, lang: lang, removeCard: removeCard);
  }

  @override
  Widget buildWebViewPage(BuildContext context) => const WebViewApp();
}
