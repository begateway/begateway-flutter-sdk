import 'package:begateway_flutter_sdk/src/models/save_card_model.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:begateway_flutter_sdk/src/screens/card_payment_form.dart';
import 'package:begateway_flutter_sdk/src/screens/choose_pay.dart';
import 'package:begateway_flutter_sdk/src/utils/storage_servise.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Begateway extends StatefulWidget {
  const Begateway({
    super.key,
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
  });
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

  @override
  BegatewayContainerState createState() => BegatewayContainerState();
}

class BegatewayContainerState extends State<Begateway> {
  bool shouldShowPay = false;
  bool isLouder = true;
  List<SaveCardModel> cards = [];

  @override
  void initState() {
    super.initState();
    initSaveCards();
  }

  Future<void> initSaveCards() async {
    List<SaveCardModel> savedCards = await getSavedCardsFromStorage();
    setState(() {
      isLouder = false; // Hide the CircularProgressIndicator first
      if (savedCards.isNotEmpty) {
        cards = savedCards;
        shouldShowPay = true;
      } else {
        shouldShowPay = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: AppState(
              widget.showIsBegateway,
              widget.getAnswearFromBegateway,
              widget.publicKey,
              widget.test,
              widget.transactionType,
              widget.amount,
              widget.currency,
              widget.description,
              widget.language,
              widget.holder,
              widget.customerCountry,
              widget.customerEmail,
              widget.customerContract,
              widget.buttonText,
              widget.applePayConfig,
              widget.googlePayConfig,
              widget.paymentItems,
              //optional parameters for customizing styles
              //card number
              widget.cardNumberColor,
              widget.cardNumberSize,

              widget.cardNumberHintColor,
              widget.cardNumberHintSize,
              widget.cardNumberHintText,

              widget.cardNumberTitleColor,
              widget.cardNumberTitleSize,
              widget.cardNumberTitleText,
              widget.cardNumberHintHide,
              widget.cardNumberTitleHide,
              //expiry date
              widget.expireDateColor,
              widget.expireDateSize,

              widget.expireDateHintColor,
              widget.expireDateHintSize,
              widget.expireDateHintText,

              widget.expireDateTitleColor,
              widget.expireDateTitleSize,
              widget.expireDateTitleText,

              widget.expireDateHintHide,
              widget.expireDateTitleHide,
              //CVC/CVV
              widget.cvcCvvColor,
              widget.cvcCvvSize,

              widget.cvcCvvHintColor,
              widget.cvcCvvHintSize,
              widget.cvcCvvHintText,

              widget.cvcCvvTitleColor,
              widget.cvcCvvTitleSize,
              widget.cvcCvvTitleText,
              widget.cvcHideText,

              widget.cvcCvvHintHide,
              widget.cvcCvvTitleHide,
              //cardholder name
              widget.cardholderColor,
              widget.cardholderSize,

              widget.cardholderHintColor,
              widget.cardholderHintSize,
              widget.cardholderHintText,

              widget.cardholderTitleColor,
              widget.cardholderTitleSize,
              widget.cardholderTitleText,

              widget.cardholderHintHide,
              widget.cardholderTitleHide,
              //border
              widget.borderColor,
              widget.borderFocusColor,
              widget.borderWidth,
              widget.borderFocusWidth,
              //error
              widget.errorBorderColor,
              widget.errorBorderWidth,
              widget.errorBorderFocusColor,
              widget.errorBorderFocusWidth,
              widget.errorTextColor,
              widget.errorTextSize,
              widget.errorCardNumberText,
              widget.errorExpireDateText,
              widget.errorCvcCvvText,
              widget.errorCardholderText,
              widget.errorTextHide,
            ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: isLouder
              ? const Scaffold(
                  backgroundColor: Color(0xFFFFFFFF),
                  body: Center(
                    child: Text(
                      'beGateway',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ))
              : shouldShowPay
                  ? ChoosePay(savedCards: cards, lang: widget.language)
                  : CardPaymentForm(lang: widget.language),
        ));
  }
}
