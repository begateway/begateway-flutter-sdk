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
    //expiry date
    this.expireDateColor,
    this.expireDateSize,

    this.expireDateHintColor,
    this.expireDateHintSize,
    this.expireDateHintText,

    this.expireDateTitleColor,
    this.expireDateTitleSize,
    this.expireDateTitleText,
    //CVC/CVV
    this.cvcCvvColor,
    this.cvcCvvSize,
   
    this.cvcCvvHintColor,
    this.cvcCvvHintSize,
    this.cvcCvvHintText,

    this.cvcCvvTitleColor,
    this.cvcCvvTitleSize,
    this.cvcCvvTitleText,
    //cardholder name
    this.cardholderColor,
    this.cardholderSize,
   
    this.cardholderHintColor,
    this.cardholderHintSize,
    this.cardholderHintText,

    this.cardholderTitleColor,
    this.cardholderTitleSize,
    this.cardholderTitleText,
  });
  final void Function(bool) showIsBegateway;
  final void Function(Map<String, dynamic>) getAnswearFromBegateway;
  final String publicKey;
  final bool test;
  final String transactionType;
  final String amount;
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
  //expiry date
  final int? expireDateColor;
  final double? expireDateSize;
  
  final int? expireDateHintColor;
  final double? expireDateHintSize;
  final String? expireDateHintText;

  final int? expireDateTitleColor;
  final double? expireDateTitleSize;
  final String? expireDateTitleText;
  //CVC/CVV
  final int? cvcCvvColor;
  final double? cvcCvvSize;

  final int? cvcCvvHintColor;
  final double? cvcCvvHintSize;
  final String? cvcCvvHintText;

  final int? cvcCvvTitleColor;
  final double? cvcCvvTitleSize;
  final String? cvcCvvTitleText;
  //cardholder name
  final int? cardholderColor;
  final double? cardholderSize;
  
  final int? cardholderHintColor;
  final double? cardholderHintSize;
  final String? cardholderHintText;


  final int? cardholderTitleColor;
  final double? cardholderTitleSize;
  final String? cardholderTitleText;

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
    return ChangeNotifierProvider(
        create: (context) => AppState(
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
              //expiry date
              widget.expireDateColor,
              widget.expireDateSize,
             
              widget.expireDateHintColor,
              widget.expireDateHintSize,
              widget.expireDateHintText,

              widget.expireDateTitleColor,
              widget.expireDateTitleSize,
              widget.expireDateTitleText,
              //CVC/CVV
              widget.cvcCvvColor,
              widget.cvcCvvSize,
             
              widget.cvcCvvHintColor,
              widget.cvcCvvHintSize,
              widget.cvcCvvHintText,

              widget.cvcCvvTitleColor,
              widget.cvcCvvTitleSize,
              widget.cvcCvvTitleText,
              //cardholder name
               widget.cardholderColor,
              widget.cardholderSize,
             
              widget.cardholderHintColor,
              widget.cardholderHintSize,
              widget.cardholderHintText,

              widget.cardholderTitleColor,
              widget.cardholderTitleSize,
              widget.cardholderTitleText,
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
