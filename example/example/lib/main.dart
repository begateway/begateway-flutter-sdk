import 'package:flutter/material.dart';
import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';

import 'configuration_apple_pay.dart';
import 'configuration_google_pay.dart';
import 'products.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isBegateway = false;
  Map<String, dynamic> answear = {};

  void showIsBegateway(bool newValue) {
    setState(() {
      isBegateway = newValue;
    });
  }

  void getAnswearFromBegateway(Map<String, dynamic> answerFromServer) {
    setState(() {
      answear = answerFromServer;
      debugPrint(
          'Answear from: ${answerFromServer.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isBegateway
          ? Begateway(
              //required parameters
              showIsBegateway: showIsBegateway,
              getAnswearFromBegateway: getAnswearFromBegateway,
              publicKey:
                  'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1s8MCrSYRgxX768baEW5tpkGEi8BwAWHAaJy1amnbv+nyGF6ponAic4up+FtiRw+LHLYZXx19RVKX8dCoK7vrYFMjb7INhNILzv7XJvPqcPdyYhSoZ88AteRrbHhtxm7V/3MQyzJNPa6Sgam7+y1n0ZVIvoQBlIo9oTxRWGoFWBJ8pK/RDnvzWSQYf5Ru0jU6hMO5GizkWoleDgujUQy/q0RQi27MGcEOcq0TugCuV3jxS3cLIvLRWth24lNAr1ZSGM8W54DwcLYR3ioqtpngi+c8SryUd2eDxRq8+q+p0XuXbG+jr/HKq4d+g1JOQYpvGNUBbN+Mc3djVgyNb6n5wIDAQAB',
              test: true,
              transactionType: 'payment',
              amount: 4299,
              currency: 'GBP',
              description: 'Some description about product',
              language: 'ru',
              holder: 'Rick Astley',
              customerCountry: 'GB',
              customerEmail: 'jake@example.com',
              customerContract: true,
              buttonText: 'Купить часы 42.99\$',
              applePayConfig: defaultApplePay,
              googlePayConfig: defaultGooglePay,
              paymentItems: products,

              //optional parameters for customizing styles
              // cardNumberColor: 0xFF1d1d21,
              // cardNumberSize: 14,
              // cardNumberHintColor: 0xFF787982,
              // cardNumberHintSize: 14,
              // cardNumberHintText: 'Custom text',
              // cardNumberTitleColor: 0xFF0526fc,
              // cardNumberTitleSize: 14,
              // cardNumberTitleText: 'Custom title',
              // cardNumberHintHide: false,
              // cardNumberTitleHide: false,

              // expireDateColor: 0xFF1d1d21,
              // expireDateSize: 14,
              // expireDateHintColor: 0xFF787982,
              // expireDateHintSize: 14,
              // expireDateHintText: 'Text',
              // expireDateTitleColor: 0xFF0526fc,
              // expireDateTitleSize: 14,
              // expireDateTitleText: 'Custom title',
              // expireDateHintHide: false,
              // expireDateTitleHide: false,

              // cvcCvvColor: 0xFF1d1d21,
              // cvcCvvSize: 14,
              // cvcCvvHintColor: 0xFF787982,
              // cvcCvvHintSize: 14,
              // cvcCvvHintText: 'Custom text',
              // cvcCvvTitleColor: 0xFF0044FF,
              // cvcCvvTitleSize: 14,
              // cvcCvvTitleText: 'Custom title',
              // cvcHideText: false,
              // cvcCvvHintHide: false,
              // cvcCvvTitleHide: false,

              // cardholderColor: 0xFF1d1d21,
              // cardholderSize: 14,
              // cardholderHintColor: 0xFF787982,
              // cardholderHintSize: 14,
              // cardholderHintText: 'Custom text',
              // cardholderTitleColor: 0xFF0526fc,
              // cardholderTitleSize: 14,
              // cardholderTitleText: 'Custom title',
              // cardholderHintHide: false,
              // cardholderTitleHide: false,

              // borderColor: 0xFF787982,
              // borderFocusColor: 0xFF0526fc,
              // borderWidth: 1,
              // borderFocusWidth: 2,

              // errorBorderColor: 0xFFfc0505,
              // errorBorderWidth: 1,
              // errorBorderFocusColor: 0xFFfc0505,
              // errorBorderFocusWidth: 2,
              // errorTextColor: 0xFFfc0505,
              // errorTextSize: 10,

              // errorCardNumberText: 'Custom text error',
              // errorExpireDateText: 'Custom text error',
              // errorCvcCvvText: 'Custom text error',
              // errorCardholderText: 'Custom text error',
              //errorTextHide: true,
            )
          : Scaffold(
              appBar: AppBar(
                title: const Text('Your app'),
                backgroundColor: Colors.orange,
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: answear.isEmpty
                      ? const Center(
                          child: Text(
                            'YOUR PRODUCT 42.99\$',
                            style: TextStyle(fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Center(
                          child: Text(
                            'Status: ${answear["checkout"]["status"].toString()}',
                            style: const TextStyle(fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
              ),
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        showIsBegateway(true);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Colors.orange),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
