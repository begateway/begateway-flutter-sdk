import 'package:begateway_flutter_sdk/src/models/save_card_model.dart';
import 'package:begateway_flutter_sdk/src/pages/begateway_pages.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state_scope.dart';
import 'package:begateway_flutter_sdk/src/providers/payment_config.dart';
import 'package:begateway_flutter_sdk/src/utils/storage_service.dart';
import 'package:flutter/material.dart';

class Begateway extends StatefulWidget {
  const Begateway({
    super.key,
    required this.pages,
    required this.storage,
    required this.showIsBegateway,
    required this.getAnswearFromBegateway,
    required this.publicKey,
    required this.test,
    required this.transactionType,
    required this.amount,
    required this.currency,
    required this.description,
    required this.language,
    required this.holder,
    required this.customerCountry,
    required this.customerEmail,
    required this.customerContract,
    required this.buttonText,
    required this.applePayConfig,
    required this.paymentItems,
    required this.googlePayConfig,
    // данные клиента (пустые по умолчанию)
    this.customerAddress = '',
    this.customerCity = '',
    this.deviceId = '',
    // необязательные параметры оформления
    // номер карты
    this.cardNumberColor,
    this.cardNumberSize,
    this.cardNumberHintColor,
    this.cardNumberHintSize,
    this.cardNumberHintText,
    this.cardNumberTitleColor,
    this.cardNumberTitleSize,
    this.cardNumberTitleText,
    this.cardNumberHintHide,
    this.cardNumberTitleHide,
    // срок действия
    this.expireDateColor,
    this.expireDateSize,
    this.expireDateHintColor,
    this.expireDateHintSize,
    this.expireDateHintText,
    this.expireDateTitleColor,
    this.expireDateTitleSize,
    this.expireDateTitleText,
    this.expireDateHintHide,
    this.expireDateTitleHide,
    // код безопасности CVC/CVV
    this.cvcCvvColor,
    this.cvcCvvSize,
    this.cvcCvvHintColor,
    this.cvcCvvHintSize,
    this.cvcCvvHintText,
    this.cvcCvvTitleColor,
    this.cvcCvvTitleSize,
    this.cvcCvvTitleText,
    this.cvcHideText,
    this.cvcCvvHintHide,
    this.cvcCvvTitleHide,
    // имя держателя
    this.cardholderColor,
    this.cardholderSize,
    this.cardholderHintColor,
    this.cardholderHintSize,
    this.cardholderHintText,
    this.cardholderTitleColor,
    this.cardholderTitleSize,
    this.cardholderTitleText,
    this.cardholderHintHide,
    this.cardholderTitleHide,
    // рамка
    this.borderColor,
    this.borderFocusColor,
    this.borderWidth,
    this.borderFocusWidth,
    // ошибки
    this.errorBorderColor,
    this.errorBorderWidth,
    this.errorBorderFocusColor,
    this.errorBorderFocusWidth,
    this.errorTextColor,
    this.errorTextSize,
    this.errorCardNumberText,
    this.errorExpireDateText,
    this.errorCvcCvvText,
    this.errorCardholderText,
    this.errorTextHide,
  });

  /// Реализация страниц оплаты: ядро не содержит UI, всё
  /// рисует приложение (см. [BegatewayPages]).
  final BegatewayPages pages;

  /// Реализация хранилища сохранённых карт и данных платежа
  /// (см. [StorageService]).
  final StorageService storage;
  final void Function(bool) showIsBegateway;
  final void Function(Map<String, dynamic>) getAnswearFromBegateway;
  final String publicKey;
  final bool test;
  final String transactionType;
  final int amount;
  final String currency;
  final String description;
  final String language;
  final String holder;
  final String customerCountry;
  final String customerEmail;
  final bool customerContract;
  final String buttonText;
  final String applePayConfig;
  final String googlePayConfig;
  final List<Map<String, dynamic>> paymentItems;

  /// Данные клиента для запросов к API — см. [PaymentConfig].
  final String customerAddress;
  final String customerCity;
  final String deviceId;
  // необязательные параметры оформления
  // номер карты
  final int? cardNumberColor;
  final double? cardNumberSize;

  final int? cardNumberHintColor;
  final double? cardNumberHintSize;
  final String? cardNumberHintText;

  final int? cardNumberTitleColor;
  final double? cardNumberTitleSize;
  final String? cardNumberTitleText;

  final bool? cardNumberHintHide;
  final bool? cardNumberTitleHide;
  // срок действия
  final int? expireDateColor;
  final double? expireDateSize;

  final int? expireDateHintColor;
  final double? expireDateHintSize;
  final String? expireDateHintText;

  final int? expireDateTitleColor;
  final double? expireDateTitleSize;
  final String? expireDateTitleText;

  final bool? expireDateHintHide;
  final bool? expireDateTitleHide;
  // код безопасности CVC/CVV
  final int? cvcCvvColor;
  final double? cvcCvvSize;

  final int? cvcCvvHintColor;
  final double? cvcCvvHintSize;
  final String? cvcCvvHintText;

  final int? cvcCvvTitleColor;
  final double? cvcCvvTitleSize;
  final String? cvcCvvTitleText;

  final bool? cvcHideText;

  final bool? cvcCvvHintHide;
  final bool? cvcCvvTitleHide;
  // имя держателя
  final int? cardholderColor;
  final double? cardholderSize;
  final int? cardholderHintColor;
  final double? cardholderHintSize;
  final String? cardholderHintText;
  final int? cardholderTitleColor;
  final double? cardholderTitleSize;
  final String? cardholderTitleText;

  final bool? cardholderHintHide;
  final bool? cardholderTitleHide;
  // рамка
  final int? borderColor;
  final int? borderFocusColor;
  final double? borderWidth;
  final double? borderFocusWidth;
  // ошибки
  final int? errorBorderColor;
  final double? errorBorderWidth;
  final int? errorBorderFocusColor;
  final double? errorBorderFocusWidth;

  final int? errorTextColor;
  final double? errorTextSize;
  final String? errorCardNumberText;
  final String? errorExpireDateText;
  final String? errorCvcCvvText;
  final String? errorCardholderText;
  final bool? errorTextHide;

  @override
  BegatewayContainerState createState() => BegatewayContainerState();
}

class BegatewayContainerState extends State<Begateway> {
  /// Пока читаются сохранённые карты — показывается заставка.
  final _isLoading = ValueNotifier<bool>(true);

  /// Сохранённые карты: непустой список → экран выбора карты,
  /// иначе — форма оплаты.
  final _savedCards = ValueNotifier<List<SaveCardModel>>(const []);

  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState(
      storage: widget.storage,
      config: PaymentConfig(
        publicKey: widget.publicKey,
        test: widget.test,
        transactionType: widget.transactionType,
        amount: widget.amount,
        currency: widget.currency,
        description: widget.description,
        language: widget.language,
        holder: widget.holder,
        customerCountry: widget.customerCountry,
        customerEmail: widget.customerEmail,
        customerContract: widget.customerContract,
        buttonText: widget.buttonText,
        applePayConfig: widget.applePayConfig,
        googlePayConfig: widget.googlePayConfig,
        paymentItems: widget.paymentItems,
        customerAddress: widget.customerAddress,
        customerCity: widget.customerCity,
        deviceId: widget.deviceId,
        cvcHideText: widget.cvcHideText ?? false,
        cardNumber: CardFieldStyle(
          color: widget.cardNumberColor,
          size: widget.cardNumberSize,
          hintColor: widget.cardNumberHintColor,
          hintSize: widget.cardNumberHintSize,
          hintText: widget.cardNumberHintText,
          titleColor: widget.cardNumberTitleColor,
          titleSize: widget.cardNumberTitleSize,
          titleText: widget.cardNumberTitleText,
          hideHint: widget.cardNumberHintHide ?? false,
          hideTitle: widget.cardNumberTitleHide ?? false,
        ),
        expireDate: CardFieldStyle(
          color: widget.expireDateColor,
          size: widget.expireDateSize,
          hintColor: widget.expireDateHintColor,
          hintSize: widget.expireDateHintSize,
          hintText: widget.expireDateHintText,
          titleColor: widget.expireDateTitleColor,
          titleSize: widget.expireDateTitleSize,
          titleText: widget.expireDateTitleText,
          hideHint: widget.expireDateHintHide ?? false,
          hideTitle: widget.expireDateTitleHide ?? false,
        ),
        cvcCvv: CardFieldStyle(
          color: widget.cvcCvvColor,
          size: widget.cvcCvvSize,
          hintColor: widget.cvcCvvHintColor,
          hintSize: widget.cvcCvvHintSize,
          hintText: widget.cvcCvvHintText,
          titleColor: widget.cvcCvvTitleColor,
          titleSize: widget.cvcCvvTitleSize,
          titleText: widget.cvcCvvTitleText,
          hideHint: widget.cvcCvvHintHide ?? false,
          hideTitle: widget.cvcCvvTitleHide ?? false,
        ),
        cardholder: CardFieldStyle(
          color: widget.cardholderColor,
          size: widget.cardholderSize,
          hintColor: widget.cardholderHintColor,
          hintSize: widget.cardholderHintSize,
          hintText: widget.cardholderHintText,
          titleColor: widget.cardholderTitleColor,
          titleSize: widget.cardholderTitleSize,
          titleText: widget.cardholderTitleText,
          hideHint: widget.cardholderHintHide ?? false,
          hideTitle: widget.cardholderTitleHide ?? false,
        ),
        border: FieldBorderStyle(
          color: widget.borderColor,
          focusColor: widget.borderFocusColor,
          width: widget.borderWidth,
          focusWidth: widget.borderFocusWidth,
        ),
        error: ErrorStyle(
          borderColor: widget.errorBorderColor,
          borderWidth: widget.errorBorderWidth,
          focusColor: widget.errorBorderFocusColor,
          focusWidth: widget.errorBorderFocusWidth,
          textColor: widget.errorTextColor,
          textSize: widget.errorTextSize,
          cardNumberText: widget.errorCardNumberText,
          expireDateText: widget.errorExpireDateText,
          cvcCvvText: widget.errorCvcCvvText,
          cardholderText: widget.errorCardholderText,
          hideText: widget.errorTextHide ?? false,
        ),
      ),
      updateIsBegateway: widget.showIsBegateway,
      answearBegateway: widget.getAnswearFromBegateway,
    );
    initSaveCards();
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _savedCards.dispose();
    _appState.dispose();
    super.dispose();
  }

  Future<void> initSaveCards() async {
    final savedCards = await _appState.storage.getCards();
    _savedCards.value = savedCards;
    _isLoading.value = false;
  }

  /// Удаление сохранённой карты: обновляет хранилище и список —
  /// ядро перестроит страницу выбора карт (или уйдёт на форму,
  /// если карт не осталось).
  void _removeCard(String token) {
    _savedCards.value = [
      for (final card in _savedCards.value)
        if (card.saveToken != token) card,
    ];
    _appState.storage.removeCard(token);
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: Stack(
        children: [
          // Активная страница флоу: заставка → выбор карт / форма.
          ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (context, isLoading, _) => isLoading
                ? const Scaffold(
                    backgroundColor: Color(0xFFFFFFFF),
                    body: Center(
                      child: Text(
                        'beGateway',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ))
                : ValueListenableBuilder<List<SaveCardModel>>(
                    valueListenable: _savedCards,
                    builder: (context, cards, _) => cards.isNotEmpty
                        ? widget.pages
                            .buildChoosePayPage(context, cards, _removeCard)
                        : widget.pages.buildPaymentPage(context),
                  ),
          ),
          // WebView (платёжная страница / 3D Secure) поверх активной
          // страницы: закрой — и вернёшься к ней с сохранённым
          // состоянием. Раньше флаг читала только форма, поэтому
          // оплата с экрана выбора карт не показывала WebView.
          ValueListenableBuilder<bool>(
            valueListenable: _appState.isShowWebview,
            builder: (context, showWebView, _) => showWebView
                ? widget.pages.buildWebViewPage(context)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
