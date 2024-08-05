import 'dart:io';

import 'package:begateway_flutter_sdk/src/models/save_card_model.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:begateway_flutter_sdk/src/screens/card_payment_form.dart';

import 'package:begateway_flutter_sdk/src/utils/storage_servise.dart';

import 'package:begateway_flutter_sdk/src/widgets/styled_back_button.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/color_constants.dart';
import '../localization/find_translation.dart';

import '../widgets/apple_pay_button.dart';
import '../widgets/card_payment_button.dart';
import '../widgets/google_pay_button.dart';
import '../widgets/outlined_button_column.dart';
//import '../widgets/samsung_pay_button.dart';
import '../widgets/secure_info_widget.dart';

class ChoosePay extends StatefulWidget {
  final List<SaveCardModel> savedCards;
  final String lang;
 
  
  const ChoosePay({Key? key, required this.savedCards, required this.lang})
      : super(key: key);

  @override
  ChoosePayState createState() => ChoosePayState();
}

class ChoosePayState extends State<ChoosePay> {
  final List<SaveCardModel> myArray = [];

  @override
  void initState() {
    super.initState();
    myArray.addAll(widget.savedCards);
  }

  void removeCard(token) {
    setState(() {
      myArray.removeWhere((element) => element.saveToken == token);
    });
    removeCardFromStorage(token);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: ColorConstants.whiteColor,
        body: SafeArea(
          child: appState.isLoading
              ? const Center(
                  child: CircularProgressIndicator(), // Show loading indicator
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(children: [
                        StyledBackButton(
                          onPressed: () {
                            appState.updateIsBegateway(false);
                            Navigator.of(context).pop();
                          },
                          text: findTranslation(
                              appState.language.toString(), "back"),
                        ),
                      ]),
                      const SizedBox(
                        height: 12,
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            OutlinedButtonColumn(
                              savedCards: myArray,
                              removeCard: removeCard,
                              context: context,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            CardPaymentButton(
                              buttonText: findTranslation(
                                  appState.language.toString(), "another_card"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CardPaymentForm(
                                      lang: appState.language.toString(),
                                    ),
                                  ),
                                );
                              },
                              backgroundColor: Colors.blue[700],
                            ),
                            const SizedBox(height: 12),
                            if (Platform.isIOS) 
                            const ApplePay(),
                            if (Platform.isAndroid) 
                            const GooglePay(),
                            // if (Platform.isAndroid) 
                            // const SizedBox(height: 12),
                            // if (Platform.isAndroid)
                            //   SamsungPayButton(
                            //     onPressed: () {
                            //       print('Samsung Pay button pressed');
                            //       // Add your Samsung Pay-related action here
                            //     },
                            //   ),
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
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
