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
      debugPrint('Answear from: ${answerFromServer.toString()}');
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
              amount: '4299',
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

              //cardNumberColor: 0xFF0044FF,
              //cardNumberSize: 40,
              // cardNumberHintColor: 0xFF0044FF,
              // cardNumberHintSize: 24,
              // cardNumberHintText: 'Text',
              // cardNumberTitleColor: 0xFF0044FF,
              // cardNumberTitleSize: 24,
              // cardNumberTitleText: 'Title',

              // expireDateColor: 0xFF0044FF,
              // expireDateSize: 24,
              // expireDateHintColor: 0xFF0044FF,
              // expireDateHintSize: 24,
              // expireDateHintText: 'Text',
              // expireDateTitleColor: 0xFF0044FF,
              // expireDateTitleSize: 24,
              // expireDateTitleText: 'Title',

              // cvcCvvColor: 0xFF0044FF,
              // cvcCvvSize: 24,
              // cvcCvvHintColor: 0xFF0044FF,
              // cvcCvvHintSize: 24,
              // cvcCvvHintText: 'Text',
              // cvcCvvTitleColor: 0xFF0044FF,
              // cvcCvvTitleSize: 24,
              //cvcCvvTitleText: 'Title',

              // cardholderColor: 0xFF0044FF,
              // cardholderSize: 24,
              // cardholderHintColor: 0xFF0044FF,
              // cardholderHintSize: 24,
              // cardholderHintText: 'Text',
              // cardholderTitleColor: 0xFF0044FF,
              // cardholderTitleSize: 24,
              // cardholderTitleText: 'Title',
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
                            MaterialStateProperty.all<Color>(Colors.orange),
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
