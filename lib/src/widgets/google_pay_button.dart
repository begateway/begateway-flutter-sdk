import 'package:flutter/material.dart';
import 'package:pay/pay.dart';

import 'package:provider/provider.dart';

import '../api/fetch_apple_pay.dart';
import '../providers/app_state.dart';

class GooglePay extends StatelessWidget {
  const GooglePay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final paymentItems = appState.paymentItems
        .map((product) => PaymentItem(
            label: product['label'],
            amount: product['amount'],
            status: PaymentItemStatus.final_price))
        .toList();

    return SizedBox(
        height: 56,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: GooglePayButton(
              paymentConfiguration:
                  PaymentConfiguration.fromJsonString(appState.googlePayConfig),
              paymentItems: paymentItems,
              onPaymentResult: (result) {
                fetchApplePay(result, appState);
              },
              onError: (error) {
                debugPrint(error.toString());
              },
            )));
  }
}
