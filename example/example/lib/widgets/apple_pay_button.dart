import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';

import '../utils/payment_configuration.dart';

class ApplePay extends StatelessWidget {
  const ApplePay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    final paymentItems = appState.config.paymentItems
        .map((product) => PaymentItem(
              label: product['label'],
              amount: product['amount'],
              status: PaymentItemStatus.final_price,
            ))
        .toList();

    return SizedBox(
        height: 56,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
            ),
            child: ApplePayButton(
              paymentConfiguration:
                  parsePaymentConfiguration(appState.config.applePayConfig),
              paymentItems: paymentItems,
              onPaymentResult: (result) {
                fetchApplePay(result, appState);
              },
              style: ApplePayButtonStyle.black,
              onError: (error) {
                debugPrint(error.toString());
              },
            )));
  }
}
