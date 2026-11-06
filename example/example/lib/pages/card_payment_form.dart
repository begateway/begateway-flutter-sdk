import 'dart:io';

import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:card_scanner/card_scanner.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/svg.dart';

import 'package:permission_handler/permission_handler.dart';

import '../utils/brands.dart';
import '../utils/form_validation.dart';
import '../utils/whitespace.dart';
import '../widgets/apple_pay_button.dart';
import '../widgets/google_pay_button.dart';
import '../widgets/nfc.dart';
import '../widgets/save_card_switch.dart';
import '../widgets/secure_info_widget.dart';
import '../widgets/styled_back_button.dart';
//import '../widgets/samsung_pay_button.dart';

class CardPaymentForm extends StatefulWidget {
  final String lang;
  const CardPaymentForm({super.key, required this.lang});

  @override
  CardPaymentFormState createState() => CardPaymentFormState();
}

class CardPaymentFormState extends State<CardPaymentForm> {
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryDateController;
  late TextEditingController _cvvController;
  late TextEditingController _holderNameController;

  // Ошибки полей и валидность формы: ValueNotifier вместо setState —
  // при изменении перестраивается только подписавшийся виджет.
  final _cardNumberError = ValueNotifier<String>('');
  final _expiryDateError = ValueNotifier<String>('');
  final _cvvError = ValueNotifier<String>('');
  final _holderNameError = ValueNotifier<String>('');
  final _isValid = ValueNotifier<bool>(false);

  /// Все уведомители формы одной связкой для ListenableBuilder.
  late final Listenable _formChanges = Listenable.merge([
    _cardNumberError,
    _expiryDateError,
    _cvvError,
    _holderNameError,
    _isValid,
  ]);

  // Флаги «автофокус уже сработал»: их не читает UI, поэтому без уведомлений.
  bool isNumber = false;
  bool isExpiry = false;
  bool isCvv = false;

  final FocusNode _cardNumberFocusNode = FocusNode();
  final FocusNode _expiryDateFocusNode = FocusNode();
  final FocusNode _cvvFocusNode = FocusNode();
  final FocusNode _holderNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _expiryDateController = TextEditingController();
    _cvvController = TextEditingController();
    _holderNameController = TextEditingController();

    _cardNumberController.addListener(_checkInputLength);
    _expiryDateController.addListener(_checkInputLength);
    _cvvController.addListener(_checkInputLength);
    _holderNameController.addListener(_checkInputLength);
    _holderNameFocusNode.addListener(_checkNameHolder);
    _expiryDateFocusNode.addListener(_checkDate);
  }

  CardScanOptions scanOptions = const CardScanOptions(
    scanCardHolderName: true,
    enableDebugLogs: false,
    validCardsToScanBeforeFinishingScan: 5,
    possibleCardHolderNamePositions: [
      CardHolderNameScanPosition.aboveCardNumber,
    ],
  );

  Future<void> scanCard() async {
    try {
      final CardDetails? cardDetails = await CardScanner.scanCard(
        scanOptions: scanOptions,
      );
      if (!mounted || cardDetails == null) return;
      // Контроллеры уведомляют слушателей сами — setState не нужен.
      _cardNumberController.text = formatCardNumber(cardDetails.cardNumber);
      _expiryDateController.text = cardDetails.expiryDate;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted && Platform.isIOS) {
      scanCard();
    } else if (status.isDenied) {
      return;
    }
  }

  void _checkNameHolder() {
    if (!_holderNameFocusNode.hasFocus) {
      _holderNameError.value =
          formValidation('holderName', _holderNameController, widget.lang);
    }
  }

  void _checkDate() {
    if (!_expiryDateFocusNode.hasFocus) {
      _expiryDateError.value =
          formValidation('expiration', _expiryDateController, widget.lang);
    }
  }

  void _checkInputLength() {
    if (_cardNumberController.text.length >= 19 &&
        _cardNumberError.value == '' &&
        !isNumber) {
      isNumber = true;
      FocusScope.of(context).requestFocus(_expiryDateFocusNode);
      if (_cardNumberController.text.length < 19 ||
          findCardBrand(_cardNumberController.text).name == '') {
        _cardNumberError.value =
            findTranslation(widget.lang, "begateway_card_number_invalid");
      }
    }

    if (_expiryDateController.text.length == 5 && !isExpiry) {
      isExpiry = true;
      FocusScope.of(context).requestFocus(_cvvFocusNode);
      _expiryDateError.value =
          formValidation('expiration', _expiryDateController, widget.lang);

      if (_expiryDateController.text.length != 5) {
        _expiryDateError.value =
            findTranslation(widget.lang, "begateway_expiration_invalid");
      }
    }
    if (_cvvController.text.length == 3 && !isCvv) {
      isCvv = true;
      FocusScope.of(context).requestFocus(_holderNameFocusNode);
    }

    // ValueNotifier сам не уведомит, если валидность не изменилась.
    _isValid.value = _holderNameController.text.length >= 2 &&
        _cvvController.text.length == 3 &&
        _expiryDateController.text.length == 5 &&
        _cardNumberController.text.length >= 19 &&
        _cardNumberError.value == '' &&
        _expiryDateError.value == '' &&
        _cvvError.value == '' &&
        _holderNameError.value == '';
  }

  @override
  void dispose() {
    /// Всё, что нужно освободить в [dispose]: контроллеры полей,
    /// уведомители ошибок и фокус-узлы. Один список — один цикл.
    for (var disposable in [
      _cardNumberController,
      _expiryDateController,
      _cvvController,
      _holderNameController,
      _cardNumberFocusNode,
      _expiryDateFocusNode,
      _cvvFocusNode,
      _holderNameFocusNode,
      _cardNumberError,
      _expiryDateError,
      _cvvError,
      _holderNameError,
      _isValid,
    ]) {
      disposable.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final config = appState.config;
    final lang = config.language;

    // номер карты
    final cardNumber = config.cardNumber;
    final cardNumberColor = cardNumber.color;
    final cardNumberSize = cardNumber.size;
    final cardNumberHintText = cardNumber.hideHint
        ? null
        : (cardNumber.hintText ??
            findTranslation(lang, "begateway_form_hint_card_number"));
    final cardNumberTitleText = cardNumber.hideTitle
        ? null
        : (cardNumber.titleText ??
            findTranslation(lang, "begateway_form_hint_card_number"));

    // срок действия
    final expireDate = config.expireDate;
    final expireDateColor = expireDate.color;
    final expireDateSize = expireDate.size;
    final expireDateHintText = expireDate.hideHint
        ? null
        : (expireDate.hintText ??
            findTranslation(lang, "begateway_form_hint_expiration"));
    final expireDateTitleText = expireDate.hideTitle
        ? null
        : (expireDate.titleText ??
            findTranslation(lang, "begateway_form_hint_expiration"));

    // код безопасности CVC/CVV
    final cvcCvv = config.cvcCvv;
    final cvvColor = cvcCvv.color;
    final cvvSize = cvcCvv.size;
    final cvvHintText = cvcCvv.hideHint
        ? null
        : (cvcCvv.hintText ?? findTranslation(lang, "begateway_cvv"));
    final cvvTitleText = cvcCvv.hideTitle
        ? null
        : (cvcCvv.titleText ?? findTranslation(lang, "begateway_cvv"));
    final cvcHideText = config.cvcHideText;

    // имя держателя
    final cardholder = config.cardholder;
    final cardholderColor = cardholder.color;
    final cardholderSize = cardholder.size;
    final cardholderHintText = cardholder.hideHint
        ? null
        : (cardholder.hintText ??
            findTranslation(lang, "begateway_form_hint_cardholder_name"));
    final cardholderTitleText = cardholder.hideTitle
        ? null
        : (cardholder.titleText ??
            findTranslation(lang, "begateway_form_hint_cardholder_name"));

    //error (рамки и цвета ошибок берутся из config.error в _fieldDecoration;
    // тексты ошибок читаются внутри ListenableBuilder — там, где меняется UI)
    final error = config.error;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // снять фокус с активного поля ввода
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: SafeArea(
            // Спиннер платёжной операции. WebView показывает ядро
            // поверх страницы (BegatewayPages.buildWebViewPage) —
            // форма его не монтирует.
            child: ValueListenableBuilder<bool>(
              valueListenable: appState.isLoading,
              builder: (context, isLoading, _) => isLoading
                  ? const Center(
                      child: CircularProgressIndicator(), // индикатор загрузки
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: ListenableBuilder(
                          listenable: _formChanges,
                          builder: (context, _) {
                            final errorCardNumberText =
                                error.cardNumberText ?? _cardNumberError.value;
                            final errorExpireDateText =
                                error.expireDateText ?? _expiryDateError.value;
                            final errorCvcCvvText =
                                error.cvcCvvText ?? _cvvError.value;
                            final errorCardholderText =
                                error.cardholderText ?? _holderNameError.value;
                            return Column(
                              children: [
                                Row(children: [
                                  StyledBackButton(
                                    onPressed: () {
                                      appState.updateIsBegateway(false);
                                    },
                                    text: findTranslation(lang, "back"),
                                  ),
                                ]),
                                const SizedBox(height: 18),
                                if (Platform.isIOS)
                                  const SizedBox(
                                    height: 56.0,
                                    width: double.infinity,
                                    child: ApplePay(),
                                  ),
                                if (Platform.isAndroid)
                                  const SizedBox(
                                    height: 56.0,
                                    width: double.infinity,
                                    child: GooglePay(),
                                  ),
                                // if (Platform.isAndroid)
                                //   const SizedBox(height: 12),
                                // if (Platform.isAndroid)
                                //   SamsungPayButton(
                                //     onPressed: () {
                                //       print('Samsung Pay button pressed');
                                //       // Add your Samsung Pay-related action here
                                //     },
                                //   ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(findTranslation(lang, "or_use_a_card")),
                                const SizedBox(height: 28),
                                TextFormField(
                                  controller: _cardNumberController,
                                  focusNode: _cardNumberFocusNode,
                                  style: TextStyle(
                                    fontSize: cardNumberSize,
                                    color: cardNumberColor,
                                  ),
                                  inputFormatters: [_CardNumberFormatter()],
                                  decoration: _fieldDecoration(
                                    config: config,
                                    focused: _cardNumberFocusNode.hasFocus,
                                    style: cardNumber,
                                    hintText: cardNumberHintText,
                                    titleText: cardNumberTitleText,
                                    hasError: _cardNumberError.value.isNotEmpty,
                                    errorText: _cardNumberError.value.isNotEmpty
                                        ? errorCardNumberText
                                        : null,
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        findCardBrand(_cardNumberController
                                                            .text)
                                                        .name !=
                                                    '' &&
                                                _cardNumberController
                                                        .text.length >=
                                                    17
                                            ? SvgPicture.asset(
                                                'assets/svg/${findCardBrand(_cardNumberController.text).name}.svg',
                                              )
                                            : const Text(''),
                                        IconButton(
                                          icon: SvgPicture.asset(
                                            'assets/svg/scanner.svg',
                                          ),
                                          onPressed: () {
                                            requestCameraPermission();
                                          },
                                        ),
                                        if (Platform.isAndroid) const Nfc()
                                      ],
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    isNumber = false;
                                    // Ошибка снимается при вводе; уведомление
                                    // уйдёт, только если значение изменилось.
                                    _cardNumberError.value = '';
                                  },
                                  autofocus: true,
                                ),

                                const SizedBox(height: 16.0),
                                Row(
                                  children: [
                                    Expanded(
                                      // срок действия
                                      child: TextFormField(
                                        controller: _expiryDateController,
                                        focusNode: _expiryDateFocusNode,
                                        style: TextStyle(
                                          fontSize: expireDateSize,
                                          color: expireDateColor,
                                        ),
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(5),
                                          _ExpiryDateFormatter(),
                                        ],
                                        decoration: _fieldDecoration(
                                          config: config,
                                          focused:
                                              _expiryDateFocusNode.hasFocus,
                                          style: expireDate,
                                          hintText: expireDateHintText,
                                          titleText: expireDateTitleText,
                                          hasError:
                                              _expiryDateError.value.isNotEmpty,
                                          errorText:
                                              _expiryDateError.value.isNotEmpty
                                                  ? errorExpireDateText
                                                  : null,
                                          errorMaxLines: 2,
                                        ),
                                        keyboardType: TextInputType.number,
                                        //obscureText: true,
                                        onTap: () {
                                          _cardNumberError.value =
                                              formValidation('cardNumber',
                                                  _cardNumberController, lang);
                                        },

                                        onChanged: (value) {
                                          isExpiry = false;
                                          _expiryDateError.value = '';
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      /// код безопасности CVC/CVV
                                      child: TextFormField(
                                        controller: _cvvController,
                                        focusNode: _cvvFocusNode,
                                        obscureText: cvcHideText,
                                        style: TextStyle(
                                          fontSize: cvvSize,
                                          color: cvvColor,
                                        ),
                                        decoration: _fieldDecoration(
                                          config: config,
                                          focused: _cvvFocusNode.hasFocus,
                                          style: cvcCvv,
                                          hintText: cvvHintText,
                                          titleText: cvvTitleText,
                                          hasError: _cvvError.value.isNotEmpty,
                                          errorText: _cvvError.value.isNotEmpty
                                              ? errorCvcCvvText
                                              : null,
                                          errorMaxLines: 2,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onTap: () {
                                          _cardNumberError.value =
                                              formValidation('cardNumber',
                                                  _cardNumberController, lang);
                                          _expiryDateError.value =
                                              formValidation('expiration',
                                                  _expiryDateController, lang);
                                        },
                                        onChanged: (value) {
                                          isCvv = false;
                                          _cvvError.value = '';
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16.0),

                                /// имя держателя
                                TextFormField(
                                  controller: _holderNameController,
                                  focusNode: _holderNameFocusNode,
                                  style: TextStyle(
                                    fontSize: cardholderSize,
                                    color: cardholderColor,
                                  ),
                                  inputFormatters: [_HolderNameFormatter()],
                                  decoration: _fieldDecoration(
                                    config: config,
                                    focused: _holderNameFocusNode.hasFocus,
                                    style: cardholder,
                                    hintText: cardholderHintText,
                                    titleText: cardholderTitleText,
                                    hasError: _holderNameError.value.isNotEmpty,
                                    errorText: _holderNameError.value.isNotEmpty
                                        ? errorCardholderText
                                        : null,
                                  ),
                                  keyboardType: TextInputType.name,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  onTap: () {
                                    _cardNumberError.value = formValidation(
                                        'cardNumber',
                                        _cardNumberController,
                                        lang);
                                    _expiryDateError.value = formValidation(
                                        'expiration',
                                        _expiryDateController,
                                        lang);
                                    _cvvError.value = formValidation(
                                        'cvv', _cvvController, lang);
                                  },
                                  onChanged: (value) {
                                    _holderNameError.value = '';
                                  },
                                ),
                                const SizedBox(height: 32.0),
                                config.customerContract == true
                                    ? const SaveCardSwitchRow()
                                    : const SizedBox(height: 0),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isValid.value
                                        ? () {
                                            // Оплата новой картой: сбрасываем
                                            // токен сохранённой карты, иначе
                                            // checkout уйдёт с платёжной
                                            // страницей по старому токену.
                                            appState.setSaveCardToken('');
                                            fetchPayWithToken(
                                                appState,
                                                _cardNumberController.text,
                                                _expiryDateController.text,
                                                _cvvController.text,
                                                _holderNameController.text);
                                          }
                                        : null,
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty
                                          .resolveWith<Color>(
                                        (Set<WidgetState> states) {
                                          if (states
                                              .contains(WidgetState.pressed)) {
                                            return Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.5);
                                          } else if (states
                                              .contains(WidgetState.disabled)) {
                                            return const Color(0xFF929DA9);
                                          }
                                          return const Color(0xFF0065FF);
                                        },
                                      ),
                                    ),
                                    child: Text(
                                      config.buttonText,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFFFFFFF)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Align(
                                    alignment: Alignment.center,
                                    child: SecureInfoWidget(
                                      language: lang,
                                    ))
                              ],
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ),
        ));
  }
}

/// Общий декор для всех четырёх полей формы: рамки, лейбл и текст ошибки
/// задаются в одном месте вместо четырёх почти одинаковых копий.
InputDecoration _fieldDecoration({
  required PaymentConfig config,
  required bool focused,
  required CardFieldStyle style,
  required String? hintText,
  required String? titleText,
  required bool hasError,
  required String? errorText,
  Widget? suffixIcon,
  int? errorMaxLines,
}) {
  final border = config.border;
  final error = config.error;
  return InputDecoration(
    labelText: focused ? titleText : hintText,
    labelStyle: !focused
        ? TextStyle(color: style.hintColor, fontSize: style.hintSize)
        : TextStyle(
            color: hasError ? error.textColor : style.titleColor,
            fontSize: style.titleSize,
          ),
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    suffixIcon: suffixIcon,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: border.color, width: border.width),
    ),
    errorBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: error.borderColor, width: error.borderWidth),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide:
          BorderSide(width: border.focusWidth, color: border.focusColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(width: error.focusWidth, color: error.focusColor),
    ),
    errorMaxLines: errorMaxLines,
    errorText: errorText,
    errorStyle: TextStyle(
      color: error.textColor,
      fontSize: !error.hideText ? error.textSize : 0,
    ),
  );
}

/// Номер карты: пробелы каждые 4 цифры (см. [formatCardNumber]).
///
/// Раньше форматирование шло в `onChanged` через присваивание
/// `controller.text` — это лишняя пересборка поля на каждый ввод символа.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatCardNumber(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Срок действия: вставляет `/` после месяца (`12` → `12/`).
///
/// Логика перенесена сюда из `CardPaymentFormState.changeExpiryDate`.
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = _format(newValue.text);
    if (formatted == newValue.text) return newValue;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _format(String input) {
    if (input.startsWith(RegExp(r'[2-9]'))) {
      return '0${input[0]}/${input.substring(1)}';
    }
    if (input.startsWith(RegExp(r'0[1-9]'))) {
      if (input.length == 2) return '$input/';
      if (input.endsWith('/')) return input.substring(0, input.length - 1);
      return input;
    }
    if (input.startsWith('1')) {
      if (input.length == 1) return input;
      if (input.length == 2) {
        final secondDigit = input[1];
        if (secondDigit == '0' || secondDigit == '1' || secondDigit == '2') {
          return '$input/';
        }
        return input.substring(0, 1);
      }
      if (input.endsWith('/')) return input.substring(0, input.length - 1);
      return input;
    }
    return input;
  }
}

/// Имя держателя: верхний регистр без присваивания `controller.text`.
class _HolderNameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();
    if (upper == newValue.text) return newValue;
    // Длина может измениться (ß → SS) — позиции выравниваем по концу.
    return TextEditingValue(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
      composing: TextRange.empty,
    );
  }
}
