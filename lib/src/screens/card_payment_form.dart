import 'dart:io';

import 'package:begateway_flutter_sdk/src/api/fetch_pay_with_token.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:begateway_flutter_sdk/src/screens/webview.dart';
import 'package:begateway_flutter_sdk/src/utils/brands.dart';
import 'package:begateway_flutter_sdk/src/utils/whitespace.dart';
import 'package:begateway_flutter_sdk/src/widgets/save_card_switch.dart';
import 'package:begateway_flutter_sdk/src/widgets/styled_back_button.dart';

import 'package:credit_card_scanner/credit_card_scanner.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/svg.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../constants/color_constants.dart';
import '../localization/find_translation.dart';

import '../utils/form_validation.dart';
import '../widgets/apple_pay_button.dart';
import '../widgets/google_pay_button.dart';
import '../widgets/nfc.dart';
import '../widgets/secure_info_widget.dart';
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

  late String _cardNumberError = '';
  late String _expiryDateError = '';
  late String _cvvError = '';
  late String _holderNameError = '';
  late bool _isValid = false;

  late bool isNumber = false;
  late bool isExpiry = false;
  late bool isCvv = false;
  late bool isHolderName = false;

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

  void changeExpiryDate(String input) {
    if (input.startsWith(RegExp(r'[2-9]'))) {
      final text = input.split('')[0];
      _expiryDateController.text = '0$text/${input.substring(1)}';
    } else if (input.startsWith(RegExp(r'0[1-9]'))) {
      if (input.length == 2) {
        _expiryDateController.text = '$input/';
      } else if (input.endsWith('/')) {
        _expiryDateController.text = input.substring(0, input.length - 1);
      } else {
        _expiryDateController.text = input;
      }
    } else if (input.startsWith('1')) {
      if (input.length == 1) {
        _expiryDateController.text = input;
      } else if (input.length == 2) {
        final secondDigit = input[1];
        if (secondDigit == '0' || secondDigit == '1' || secondDigit == '2') {
          _expiryDateController.text = '$input/';
        } else {
          _expiryDateController.text = input.substring(0, 1);
        }
      } else if (input.endsWith('/')) {
        _expiryDateController.text = input.substring(0, input.length - 1);
      } else {
        _expiryDateController.text = input;
      }
    }
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
      setState(() {
        _cardNumberController.text = formatCardNumber(cardDetails.cardNumber);
        _expiryDateController.text = cardDetails.expiryDate;
      });
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
      setState(() {
        _holderNameError =
            formValidation('holderName', _holderNameController, widget.lang);
      });
    }
  }

  void _checkDate() {
    if (!_expiryDateFocusNode.hasFocus) {
      setState(() {
        _expiryDateError =
            formValidation('expiration', _expiryDateController, widget.lang);
      });
    }
  }

  void _checkInputLength() {
    if (_cardNumberController.text.length >= 19 &&
        _cardNumberError == '' &&
        !isNumber) {
      setState(() {
        isNumber = true;
      });
      FocusScope.of(context).requestFocus(_expiryDateFocusNode);
      if (_cardNumberController.text.length < 19 ||
          findCardBrand(_cardNumberController.text).name == '') {
        _cardNumberError =
            findTranslation(widget.lang, "begateway_card_number_invalid");
      }
    }

    if (_expiryDateController.text.length == 5 && !isExpiry) {
      setState(() {
        isExpiry = true;
      });
      FocusScope.of(context).requestFocus(_cvvFocusNode);
      _expiryDateError =
          formValidation('expiration', _expiryDateController, widget.lang);

      if (_expiryDateController.text.length != 5) {
        _expiryDateError =
            findTranslation(widget.lang, "begateway_expiration_invalid");
      }
    }
    if (_cvvController.text.length == 3 && !isCvv) {
      setState(() {
        isCvv = true;
      });
      FocusScope.of(context).requestFocus(_holderNameFocusNode);
    }

    if (_holderNameController.text.length >= 2 &&
        _cvvController.text.length == 3 &&
        _expiryDateController.text.length == 5 &&
        _cardNumberController.text.length >= 19 &&
        _cardNumberError == '' &&
        _expiryDateError == '' &&
        _cvvError == '' &&
        _holderNameError == '') {
      setState(() {
        _isValid = true;
      });
    } else {
      setState(() {
        _isValid = false;
      });
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final lang = appState.language.toString();

    //cardNumber
    final cardNumberColor = appState.cardNumberColor != null
        ? Color(appState.cardNumberColor!)
        : null;
    final cardNumberHintHide = appState.cardNumberHintHide ?? false;
    final cardNumberTitleHide = appState.cardNumberTitleHide ?? false;
    final cardNumberSize = appState.cardNumberSize;
    final cardNumberHintColor = appState.cardNumberHintColor != null
        ? Color(appState.cardNumberHintColor!)
        : null;
    final cardNumberHintSize = appState.cardNumberHintSize;
    final cardNumberHintText = cardNumberHintHide
        ? null
        : (appState.cardNumberHintText ??
            findTranslation(lang, "begateway_form_hint_card_number"));
    final cardNumberTitleColor = appState.cardNumberTitleColor;
    final numberTitleColor = cardNumberTitleColor != null
        ? Color(cardNumberTitleColor)
        : ColorConstants.blueColor;
    final cardNumberTitleSize = appState.cardNumberTitleSize;
    final cardNumberTitleText = cardNumberTitleHide
        ? null
        : (appState.cardNumberTitleText ??
            findTranslation(lang, "begateway_form_hint_card_number"));

    //cardExpire
    final expireDateHintHide = appState.expireDateHintHide ?? false;
    final expireDateTitleHide = appState.expireDateTitleHide ?? false;
    final expireDateColor = appState.expireDateColor != null
        ? Color(appState.expireDateColor!)
        : null;
    final expireDateSize = appState.expireDateSize;
    final expireDateHintColor = appState.expireDateHintColor != null
        ? Color(appState.expireDateHintColor!)
        : null;
    final expireDateHintSize = appState.expireDateHintSize;
    final expireDateHintText = expireDateHintHide
        ? null
        : (appState.expireDateHintText ??
            findTranslation(lang, "begateway_form_hint_expiration"));
    final expireTitleColor = appState.expireDateTitleColor != null
        ? Color(appState.expireDateTitleColor!)
        : ColorConstants.blueColor;
    final expireDateTitleSize = appState.expireDateTitleSize;
    final expireDateTitleText = expireDateTitleHide
        ? null
        : (appState.expireDateTitleText ??
            findTranslation(lang, "begateway_form_hint_expiration"));

    //CVV
    final cvcCvvHintHide = appState.cvcCvvHintHide ?? false;
    final cvcCvvTitleHide = appState.cvcCvvTitleHide ?? false;
    final cvvColor =
        appState.cvcCvvColor != null ? Color(appState.cvcCvvColor!) : null;
    final cvvSize = appState.cvcCvvSize;
    final cvvHintColor = appState.cvcCvvHintColor != null
        ? Color(appState.cvcCvvHintColor!)
        : null;
    final cvvHintSize = appState.cvcCvvHintSize;
    final cvvHintText = cvcCvvHintHide
        ? null
        : (appState.cvcCvvHintText ?? findTranslation(lang, "begateway_cvv"));
    final cvvTitleColor = appState.cvcCvvTitleColor != null
        ? Color(appState.cvcCvvTitleColor!)
        : ColorConstants.blueColor;
    final cvvTitleSize = appState.cvcCvvTitleSize;
    final cvvTitleText = cvcCvvTitleHide
        ? null
        : (appState.cvcCvvTitleText ?? findTranslation(lang, "begateway_cvv"));
    final cvcHideText = appState.cvcHideText ?? false;

    //cardholder
    final cardholderHintHide = appState.cardholderHintHide ?? false;
    final cardholderTitleHide = appState.cardholderTitleHide ?? false;
    final cardholderColor = appState.cardholderColor != null
        ? Color(appState.cardholderColor!)
        : null;
    final cardholderSize = appState.cardholderSize;
    final cardholderHintColor = appState.cardholderHintColor != null
        ? Color(appState.cardholderHintColor!)
        : null;
    final cardholderHintSize = appState.cardholderHintSize;
    final cardholderHintText = cardholderHintHide
        ? null
        : (appState.cardholderHintText ??
            findTranslation(lang, "begateway_form_hint_cardholder_name"));
    final cardholderTitleColor = appState.cardholderTitleColor != null
        ? Color(appState.cardholderTitleColor!)
        : ColorConstants.blueColor;
    final cardholderTitleSize = appState.cardholderTitleSize;
    final cardholderTitleText = cardholderTitleHide
        ? null
        : (appState.cardholderTitleText ??
            findTranslation(lang, "begateway_form_hint_cardholder_name"));

    //border
    final borderColor = appState.borderColor != null
        ? Color(appState.borderColor!)
        : Colors.grey;
    final borderFocusColor = appState.borderFocusColor != null
        ? Color(appState.borderFocusColor!)
        : ColorConstants.blueColor;
    final borderWidth =
        appState.borderWidth != null ? appState.borderWidth! : 1.0;
    final borderFocusWidth =
        appState.borderFocusWidth != null ? appState.borderFocusWidth! : 2.0;

    final errorBorderColor = appState.errorBorderColor != null
        ? Color(appState.errorBorderColor!)
        : ColorConstants.redColor;
    final errorBorderWidth =
        appState.errorBorderWidth != null ? appState.errorBorderWidth! : 1.0;
    final errorBorderFocusColor = appState.errorBorderFocusColor != null
        ? Color(appState.errorBorderFocusColor!)
        : ColorConstants.redColor;
    final errorBorderFocusWidth = appState.borderFocusWidth != null
        ? appState.errorBorderFocusWidth!
        : 2.0;
    final errorTextColor = appState.errorTextColor != null
        ? Color(appState.errorTextColor!)
        : ColorConstants.redColor;
    final errorTextHide = appState.errorTextHide ?? false;

    final errorTextSize = appState.errorTextSize;

    final errorCardNumberText =
        appState.errorCardNumberText ?? _cardNumberError;

    final errorExpireDateText =
        appState.errorExpireDateText ?? _expiryDateError;

    final errorCvcCvvText = appState.errorCvcCvvText ?? _cvvError;

    final errorCardholderText =
        appState.errorCardholderText ?? _holderNameError;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Remove focus from any active TextField
        },
        child: Scaffold(
          backgroundColor: ColorConstants.whiteColor,
          body: SafeArea(
            child: appState.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(), // Show loading indicator
                  )
                : appState.isShowWebview
                    ? const WebViewApp()
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
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
                                cursorColor: Colors.black54,
                                controller: _cardNumberController,
                                focusNode: _cardNumberFocusNode,
                                style: TextStyle(
                                  fontSize: cardNumberSize,
                                  color: cardNumberColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: _cardNumberFocusNode.hasFocus
                                        ? cardNumberTitleText
                                        : cardNumberHintText,
                                    labelStyle: !_cardNumberFocusNode.hasFocus
                                        ? TextStyle(
                                            color: cardNumberHintColor,
                                            fontSize: cardNumberHintSize,
                                          )
                                        : TextStyle(
                                            color: _cardNumberError.isEmpty
                                                ? numberTitleColor
                                                : errorTextColor,
                                            fontSize: cardNumberTitleSize,
                                          ),
                                    border: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
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
                                                'packages/begateway_flutter_sdk/assets/svg/${findCardBrand(_cardNumberController.text).name}.svg',
                                              )
                                            : const Text(''),
                                        IconButton(
                                          icon: SvgPicture.asset(
                                            'packages/begateway_flutter_sdk/assets/svg/scanner.svg',
                                          ),
                                          onPressed: () {
                                            requestCameraPermission();
                                          },
                                        ),
                                        if (Platform.isAndroid) const Nfc()
                                      ],
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      // Customize unfocused border
                                      borderSide: BorderSide(
                                          color: borderColor,
                                          width: borderWidth),
                                      // Set unfocused border color
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            errorBorderColor, // Change the border color for errors
                                        width:
                                            errorBorderWidth, // Change the border width for errors
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      // Customize focused border
                                      borderSide: BorderSide(
                                          width: borderFocusWidth,
                                          color:
                                              borderFocusColor), // Set focused border color
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      // Customize focused border
                                      borderSide: BorderSide(
                                        width: errorBorderFocusWidth,
                                        color: errorBorderFocusColor,
                                      ), // Set focused border color
                                    ),
                                    errorText: _cardNumberError.isNotEmpty
                                        ? errorCardNumberText
                                        : null,
                                    errorStyle: TextStyle(
                                        color: errorTextColor,
                                        fontSize: !errorTextHide
                                            ? errorTextSize
                                            : 0)),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    isNumber = false;
                                    _cardNumberError =
                                        ''; // Clear the error when data is entered
                                  });
                                  String formattedValue =
                                      formatCardNumber(value);
                                  _cardNumberController.text = formattedValue;
                                  _cardNumberController.selection =
                                      TextSelection.fromPosition(TextPosition(
                                          offset: _cardNumberController
                                              .text.length));
                                },
                                autofocus: true,
                              ),

                              const SizedBox(height: 16.0),
                              Row(
                                children: [
                                  Expanded(
                                    //expire
                                    child: TextFormField(
                                      cursorColor: Colors.black54,
                                      controller: _expiryDateController,
                                      focusNode: _expiryDateFocusNode,
                                      style: TextStyle(
                                        fontSize: expireDateSize,
                                        color: expireDateColor,
                                      ),
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(5)
                                      ],
                                      decoration: InputDecoration(
                                          labelText:
                                              _expiryDateFocusNode.hasFocus
                                                  ? expireDateTitleText
                                                  : expireDateHintText,
                                          labelStyle: !_expiryDateFocusNode
                                                  .hasFocus
                                              ? TextStyle(
                                                  color: expireDateHintColor,
                                                  fontSize: expireDateHintSize,
                                                )
                                              : TextStyle(
                                                  color:
                                                      _expiryDateError.isEmpty
                                                          ? expireTitleColor
                                                          : errorTextColor,
                                                  fontSize: expireDateTitleSize,
                                                ),
                                          border: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey), // Set border color// Set border radius
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            // Customize unfocused border
                                            borderSide: BorderSide(
                                                color: borderColor,
                                                width: borderWidth),
                                            // Set unfocused border color
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  errorBorderColor, // Change the border color for errors
                                              width:
                                                  errorBorderWidth, // Change the border width for errors
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            // Customize focused border
                                            borderSide: BorderSide(
                                                width: borderFocusWidth,
                                                color:
                                                    borderFocusColor), // Set focused border color
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            // Customize focused border
                                            borderSide: BorderSide(
                                              width: errorBorderFocusWidth,
                                              color: errorBorderFocusColor,
                                            ), // Set focused border color
                                          ),
                                          errorMaxLines: 2,
                                          errorText: _expiryDateError.isNotEmpty
                                              ? errorExpireDateText
                                              : null,
                                          errorStyle: TextStyle(
                                              color: errorTextColor,
                                              fontSize: !errorTextHide
                                                  ? errorTextSize
                                                  : 0)),
                                      keyboardType: TextInputType.number,
                                      //obscureText: true,
                                      onTap: () => {
                                        setState(() {
                                          _cardNumberError = formValidation(
                                              'cardNumber',
                                              _cardNumberController,
                                              lang);
                                        })
                                      },

                                      onChanged: (value) {
                                        setState(() {
                                          isExpiry = false;
                                          _expiryDateError = '';
                                          changeExpiryDate(value);
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    ///cvv
                                    child: TextFormField(
                                      cursorColor: Colors.black54,
                                      controller: _cvvController,
                                      focusNode: _cvvFocusNode,
                                      obscureText: cvcHideText,
                                      style: TextStyle(
                                        fontSize: cvvSize,
                                        color: cvvColor,
                                      ),
                                      decoration: InputDecoration(
                                          labelText: _cvvFocusNode.hasFocus
                                              ? cvvTitleText
                                              : cvvHintText,
                                          labelStyle: !_cvvFocusNode.hasFocus
                                              ? TextStyle(
                                                  color: cvvHintColor,
                                                  fontSize: cvvHintSize,
                                                )
                                              : TextStyle(
                                                  color: _cvvError.isEmpty
                                                      ? cvvTitleColor
                                                      : errorTextColor,
                                                  fontSize: cvvTitleSize,
                                                ),
                                          border: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey), // Set border color// Set border radius
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            // Customize unfocused border
                                            borderSide: BorderSide(
                                                color: borderColor,
                                                width: borderWidth),
                                            // Set unfocused border color
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  errorBorderColor, // Change the border color for errors
                                              width:
                                                  errorBorderWidth, // Change the border width for errors
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            // Customize focused border
                                            borderSide: BorderSide(
                                                width: borderFocusWidth,
                                                color:
                                                    borderFocusColor), // Set focused border color
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            // Customize focused border
                                            borderSide: BorderSide(
                                              width: errorBorderFocusWidth,
                                              color: errorBorderFocusColor,
                                            ), // Set focused border color
                                          ),
                                          errorMaxLines: 2,
                                          errorText: _cvvError.isNotEmpty
                                              ? errorCvcCvvText
                                              : null,
                                          errorStyle: TextStyle(
                                              color: errorTextColor,
                                              fontSize: !errorTextHide
                                                  ? errorTextSize
                                                  : 0)),
                                      keyboardType: TextInputType.number,
                                      onTap: () => {
                                        setState(() {
                                          _cardNumberError = formValidation(
                                              'cardNumber',
                                              _cardNumberController,
                                              lang);
                                          _expiryDateError = formValidation(
                                              'expiration',
                                              _expiryDateController,
                                              lang);
                                        })
                                      },
                                      onChanged: (value) {
                                        setState(() {
                                          isCvv = false;
                                          _cvvError =
                                              ''; // Clear the error when data is entered
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),

                              ///holder
                              TextFormField(
                                cursorColor: Colors.black54,
                                controller: _holderNameController,
                                focusNode: _holderNameFocusNode,
                                style: TextStyle(
                                  fontSize: cardholderSize,
                                  color: cardholderColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: _holderNameFocusNode.hasFocus
                                        ? cardholderTitleText
                                        : cardholderHintText,
                                    labelStyle: !_holderNameFocusNode.hasFocus
                                        ? TextStyle(
                                            color: cardholderHintColor,
                                            fontSize: cardholderHintSize,
                                          )
                                        : TextStyle(
                                            color: _holderNameError.isEmpty
                                                ? cardholderTitleColor
                                                : errorTextColor,
                                            fontSize: cardholderTitleSize,
                                          ),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey), // Set border color// Set border radius
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      // Customize unfocused border
                                      borderSide: BorderSide(
                                          color: borderColor,
                                          width: borderWidth),
                                      // Set unfocused border color
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      // Customize focused border
                                      borderSide: BorderSide(
                                          width: borderFocusWidth,
                                          color:
                                              borderFocusColor), // Set focused border color
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      // Customize focused border
                                      borderSide: BorderSide(
                                        width: errorBorderFocusWidth,
                                        color: errorBorderFocusColor,
                                      ), // Set focused border color
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            errorBorderColor, // Change the border color for errors
                                        width:
                                            errorBorderWidth, // Change the border width for errors
                                      ),
                                    ),
                                    errorText: _holderNameError.isNotEmpty
                                        ? errorCardholderText
                                        : null,
                                    errorStyle: TextStyle(
                                        color: errorTextColor,
                                        fontSize: !errorTextHide
                                            ? errorTextSize
                                            : 0)),
                                keyboardType: TextInputType.name,
                                textCapitalization:
                                    TextCapitalization.characters,
                                onTap: () => {
                                  setState(() {
                                    _cardNumberError = formValidation(
                                        'cardNumber',
                                        _cardNumberController,
                                        lang);
                                    _expiryDateError = formValidation(
                                        'expiration',
                                        _expiryDateController,
                                        lang);
                                    _cvvError = formValidation(
                                        'cvv', _cvvController, lang);
                                  })
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _holderNameController.text =
                                        value.toUpperCase();
                                    _holderNameError =
                                        ''; // Clear the error when data is entered
                                  });
                                },
                              ),
                              const SizedBox(height: 32.0),
                              appState.customerContract == true
                                  ? const SaveCardSwitchRow()
                                  : const SizedBox(height: 0),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isValid
                                      ? () {
                                          fetchPayWithToken(
                                              appState,
                                              _cardNumberController.text,
                                              _expiryDateController.text,
                                              _cvvController.text,
                                              _holderNameController.text);
                                        }
                                      : null,
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                      (Set<WidgetState> states) {
                                        if (states
                                            .contains(WidgetState.pressed)) {
                                          return Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.5);
                                        } else if (states
                                            .contains(WidgetState.disabled)) {
                                          return ColorConstants.grey50Color;
                                        }
                                        return ColorConstants.blue50Color;
                                      },
                                    ),
                                  ),
                                  child: Text(
                                    appState.buttonText.toString(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: ColorConstants.whiteColor),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Align(
                                  alignment: Alignment.center,
                                  child: SecureInfoWidget(
                                    language: appState.language.toString(),
                                    onTap: () {},
                                  ))
                            ],
                          ),
                        ),
                      ),
          ),
        ));
  }
}
