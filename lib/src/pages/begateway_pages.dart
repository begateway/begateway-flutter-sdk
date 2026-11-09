import 'package:flutter/material.dart';

import '../models/save_card_model.dart';

/// Абстракция страниц платёжного сценария.
///
/// Ядро SDK не содержит UI-кода: приложение реализует [BegatewayPages]
/// и передаёт экземпляр в `Begateway.pages`. Ядро само решает, какая
/// страница активна (загрузка карт → выбор карты / форма оплаты),
/// и поверх активной страницы показывает WebView, когда
/// `appState.isShowWebview` становится true.
abstract class BegatewayPages {
  const BegatewayPages();

  /// Форма оплаты новой картой.
  ///
  /// Язык и стили читаются из `AppStateScope.of(context).config`.
  Widget buildPaymentPage(BuildContext context);

  /// Выбор сохранённой карты.
  ///
  /// * [cards] — карты из хранилища устройства;
  /// * [removeCard] — удаление карты по токену: обновляет хранилище
  ///   и список, после чего ядро перестроит страницу.
  Widget buildChoosePayPage(
    BuildContext context,
    List<SaveCardModel> cards,
    ValueChanged<String> removeCard,
  );

  /// Страница 3D Secure / платёжной страницы в WebView.
  ///
  /// Ссылки берутся из состояния: `appState.urlLink` — куда вести,
  /// `appState.resultUrl` — префикс возврата; перехват возврата
  /// завершается вызовом `fetchPayCheck(appState)`. Закрытие —
  /// `appState.setIsShowWebview(false)`.
  Widget buildWebViewPage(BuildContext context);
}
