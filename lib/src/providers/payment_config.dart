import 'package:flutter/material.dart';

/// Стиль одного текстового поля формы (номер карты, срок, CVC, имя держателя).
///
/// Цвета приходят из публичного API как `int?` (например `0xFF1d1d21`) и
/// конвертируются в [Color] один раз здесь — в билде поля уже не нужно
/// повторять `value != null ? Color(value) : null`.
class CardFieldStyle {
  CardFieldStyle({
    int? color,
    this.size,
    int? hintColor,
    this.hintSize,
    this.hintText,
    int? titleColor,
    this.titleSize,
    this.titleText,
    this.hideHint = false,
    this.hideTitle = false,
  })  : color = color == null ? null : Color(color),
        hintColor = hintColor == null ? null : Color(hintColor),
        titleColor = titleColor == null ? null : Color(titleColor);

  final Color? color;
  final double? size;

  final Color? hintColor;
  final double? hintSize;
  final String? hintText;

  final Color? titleColor;
  final double? titleSize;
  final String? titleText;

  final bool hideHint;
  final bool hideTitle;
}

/// Рамки полей формы: обычная и в фокусе.
class FieldBorderStyle {
  FieldBorderStyle({
    int? color,
    int? focusColor,
    double? width,
    double? focusWidth,
  })  : color = color == null ? Colors.grey : Color(color),
        focusColor =
            focusColor == null ? const Color(0xFF3090ed) : Color(focusColor),
        width = width ?? 1.0,
        focusWidth = focusWidth ?? 2.0;

  final Color color;
  final Color focusColor;
  final double width;
  final double focusWidth;
}

/// Стиль отображения ошибок валидации.
class ErrorStyle {
  ErrorStyle({
    int? borderColor,
    double? borderWidth,
    int? focusColor,
    double? focusWidth,
    int? textColor,
    this.textSize,
    this.cardNumberText,
    this.expireDateText,
    this.cvcCvvText,
    this.cardholderText,
    this.hideText = false,
  })  : borderColor =
            borderColor == null ? const Color(0xFFcd3637) : Color(borderColor),
        borderWidth = borderWidth ?? 1.0,
        focusColor =
            focusColor == null ? const Color(0xFFcd3637) : Color(focusColor),
        focusWidth = focusWidth ?? 2.0,
        textColor =
            textColor == null ? const Color(0xFFcd3637) : Color(textColor);

  final Color borderColor;
  final double borderWidth;
  final Color focusColor;
  final double focusWidth;

  final Color textColor;
  final double? textSize;
  final bool hideText;

  /// Свои тексты ошибок для каждого поля; `null` = брать текст из валидации.
  final String? cardNumberText;
  final String? expireDateText;
  final String? cvcCvvText;
  final String? cardholderText;
}

/// Неизменяемые параметры платежа и стиля формы.
///
/// Собирается один раз в `Begateway.initState` и дальше только читается —
/// мутабельное состояние живёт отдельно в `AppState`.
class PaymentConfig {
  PaymentConfig({
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
    required this.googlePayConfig,
    required this.paymentItems,
    this.customerAddress = '',
    this.customerCity = '',
    this.deviceId = '',
    this.cvcHideText = false,
    CardFieldStyle? cardNumber,
    CardFieldStyle? expireDate,
    CardFieldStyle? cvcCvv,
    CardFieldStyle? cardholder,
    FieldBorderStyle? border,
    ErrorStyle? error,
  })  : cardNumber = cardNumber ?? CardFieldStyle(),
        expireDate = expireDate ?? CardFieldStyle(),
        cvcCvv = cvcCvv ?? CardFieldStyle(),
        cardholder = cardholder ?? CardFieldStyle(),
        border = border ?? FieldBorderStyle(),
        error = error ?? ErrorStyle();

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

  /// Данные клиента для запросов к API: адрес, город и device id.
  ///
  /// Пустые по умолчанию — bePaid трактует пустые значения как
  /// отсутствующие поля. Раньше здесь были захардкожены заглушки
  /// ('Baker street 221b', 'London', '363').
  final String customerAddress;
  final String customerCity;
  final String deviceId;

  final String buttonText;
  final String applePayConfig;
  final String googlePayConfig;
  final List<Map<String, dynamic>> paymentItems;

  /// Скрывать ли CVC/CVV при вводе.
  final bool cvcHideText;

  final CardFieldStyle cardNumber;
  final CardFieldStyle expireDate;
  final CardFieldStyle cvcCvv;
  final CardFieldStyle cardholder;
  final FieldBorderStyle border;
  final ErrorStyle error;

  /// Значения по умолчанию, когда AppStateScope выше по дереву не найден.
  factory PaymentConfig.empty() => PaymentConfig(
        publicKey: '',
        test: false,
        transactionType: '',
        amount: 0,
        currency: '',
        description: '',
        language: 'en',
        holder: '',
        customerCountry: '',
        customerEmail: '',
        customerContract: false,
        buttonText: '',
        applePayConfig: '',
        googlePayConfig: '',
        paymentItems: const [],
      );
}
