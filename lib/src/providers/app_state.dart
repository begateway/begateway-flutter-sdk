import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  final void Function(bool) updateIsBegateway;
  final void Function(Map<String, dynamic>) answearBegateway;
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
  //optional parameters for customizing styles
  //card number
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
  //expiry date
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
  //CVC/CVV
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
  //cardholder name
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
  //border
  final int? borderColor;
  final int? borderFocusColor;
  final double? borderWidth;
  final double? borderFocusWidth;
  //error
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

  AppState(
    this.updateIsBegateway,
    this.answearBegateway,
    this.publicKey,
    this.test,
    this.transactionType,
    this.amount,
    this.currency,
    this.description,
    this.language,
    this.holder,
    this.customerCountry,
    this.customerEmail,
    this.customerContract,
    this.buttonText,
    this.applePayConfig,
    this.googlePayConfig,
    this.paymentItems,
    //optional parameters for customizing styles
    //card number
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
    //expiry date
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
    //CVC/CVV
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

    //cardholder name
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
    //border
    this.borderColor,
    this.borderFocusColor,
    this.borderWidth,
    this.borderFocusWidth,
    //error
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
  );
  bool isLoading = false;
  bool isShowWebview = false;
  bool isSaveCard = false;
  String urlLink = '';
  String resultUrl = '';
  String token = '';
  String saveCardToken = '';
  //List<SaveCardModel> saveCards = [];
  void setIsLoading(value) {
    isLoading = value;
    notifyListeners();
  }

  void setIsShowWebview(value) {
    isShowWebview = value;
    notifyListeners();
  }

  void setIsSaveCard(value) {
    isSaveCard = value;
    notifyListeners();
  }

  void setUrlLink(value) {
    urlLink = value;
    notifyListeners();
  }

  void setResultUrl(value) {
    resultUrl = value;
    notifyListeners();
  }

  void setToken(value) {
    token = value;
    notifyListeners();
  }

  void setSaveCardToken(value) {
    saveCardToken = value;
    notifyListeners();
  }
}
