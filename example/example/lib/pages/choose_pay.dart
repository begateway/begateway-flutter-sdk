import 'dart:io';

import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter/material.dart';

import 'card_payment_form.dart';
import '../widgets/apple_pay_button.dart';
import '../widgets/card_payment_button.dart';
import '../widgets/google_pay_button.dart';
import '../widgets/outlined_button_column.dart';
//import '../widgets/samsung_pay_button.dart';
import '../widgets/secure_info_widget.dart';
import '../widgets/styled_back_button.dart';

class ChoosePay extends StatelessWidget {
  final List<SaveCardModel> savedCards;
  final String lang;

  /// Удаление карты по токену: владеет ядро (хранилище + список),
  /// страница только дёргает колбэк.
  final ValueChanged<String> removeCard;

  const ChoosePay({
    super.key,
    required this.savedCards,
    required this.lang,
    required this.removeCard,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: appState.isLoading,
          builder: (context, isLoading, _) => isLoading
              ? const Center(
                  child: CircularProgressIndicator(), // индикатор загрузки
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
                              appState.config.language.toString(), "back"),
                        ),
                      ]),
                      const SizedBox(
                        height: 12,
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            OutlinedButtonColumn(
                              savedCards: savedCards,
                              removeCard: removeCard,
                              context: context,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            CardPaymentButton(
                              buttonText: findTranslation(
                                  appState.config.language.toString(),
                                  "another_card"),
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CardPaymentForm(
                                      lang: appState.config.language.toString(),
                                    ),
                                  ),
                                ),
                              backgroundColor: Colors.blue[700],
                            ),
                            const SizedBox(height: 12),
                            if (Platform.isIOS) const ApplePay(),
                            if (Platform.isAndroid) const GooglePay(),
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
                                  language: appState.config.language.toString(),
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
