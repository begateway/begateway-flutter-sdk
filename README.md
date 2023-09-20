Use the Flutter gateway library to add payments to your Flutter app.

## Platform Support
| Android | iOS |
|:---:|:---:|
| Google Pay | Apple Pay

## Getting started
Before you start, create an account with the payment providers you are planning to support and follow the setup instructions:

#### beGateway:
1. Take a look at the [integration requirements](https://begateway.com/).

#### Apple Pay:
1. Take a look at the [integration requirements](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay_requirements).
2. Create a [merchant identifier](https://help.apple.com/developer-account/#/devb2e62b839?sub=dev103e030bb) for your business.
3. Create a [payment processing certificate](https://help.apple.com/developer-account/#/devb2e62b839?sub=devf31990e3f) to encrypt payment information.

#### Google Pay:
1. Take a look at the [integration requirements](https://developers.google.com/pay/api/android/overview).
2. Sign up to the [business console](https://pay.google.com/business/console) and create an account.

## Usage

To start using this library, add `begateway_flutter_sdk` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/):

```yaml
dependencies:
  begateway_flutter_sdk: ^0.0.1
```
### Example:
Config for ApplePay:
```dart
const String defaultApplePay = '''{
  "provider": "apple_pay",
  "data": {
    "merchantIdentifier": "merchant.your.number",
    "displayName": "Your company'",
    "merchantCapabilities": ["3DS", "debit", "credit"],
    "supportedNetworks": ["amex", "visa", "discover", "masterCard"],
    "countryCode": "GB",
    "currencyCode": "GBP",
    "requiredBillingContactFields": ["jake@example.com", "Rick Astley", "+14845219741", "123456"],
    "requiredShippingContactFields": [],
    "shippingMethods": [
      {
        "amount": "0.00",
        "detail": "Available within an hour",
        "identifier": "in_store_pickup",
        "label": "In-Store Pickup"
      },
      {
        "amount": "0.00",
        "detail": "5-8 Business Days",
        "identifier": "flat_rate_shipping_id_2",
        "label": "UPS Ground"
      },
      {
        "amount": "42.99",
        "detail": "1-3 Business Days",
        "identifier": "flat_rate_shipping_id_1",
        "label": "FedEx Priority Mail"
      }
    ]
  }
}''';
```
Config for GooglePay:
```dart

const String  defaultGooglePay = '''{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "example",
            "gatewayMerchantId": "gatewayMerchantId"
          }
        },
        "parameters": {
          "allowedCardNetworks": ["VISA", "MASTERCARD"],
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "billingAddressRequired": true,
          "billingAddressParameters": {
            "format": "FULL",
            "phoneNumberRequired": true
          }
        }
      }
    ],
    "merchantInfo": {
      "merchantId": "01234567890123456789",
      "merchantName": "Example Merchant Name"
    },
    "transactionInfo": {
      "countryCode": "US",
      "currencyCode": "USD"
    }
  }
}''';
```
Config for products:
```dart
const products = [
{
'label': 'Total',
'amount': '42.99',
'status': 'PaymentItemStatus.final_price',

      },
    ];
```
Code:
```dart
import 'package:flutter/material.dart';
import 'package:begateway_flutter_sdk.dart';

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
                  'your beGateway public key or token',
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

              cardNumberColor: 0xFF0044FF,
              cardNumberSize: 40,
               cardNumberHintColor: 0xFF0044FF,
               cardNumberHintSize: 24,
               cardNumberHintText: 'Text',
               cardNumberTitleColor: 0xFF0044FF,
               cardNumberTitleSize: 24,
               cardNumberTitleText: 'Title',

               expireDateColor: 0xFF0044FF,
               expireDateSize: 24,
               expireDateHintColor: 0xFF0044FF,
               expireDateHintSize: 24,
               expireDateHintText: 'Text',
               expireDateTitleColor: 0xFF0044FF,
               expireDateTitleSize: 24,
               expireDateTitleText: 'Title',

               cvcCvvColor: 0xFF0044FF,
               cvcCvvSize: 24,
               cvcCvvHintColor: 0xFF0044FF,
               cvcCvvHintSize: 24,
               cvcCvvHintText: 'Text',
               cvcCvvTitleColor: 0xFF0044FF,
               cvcCvvTitleSize: 24,
              cvcCvvTitleText: 'Title',

               cardholderColor: 0xFF0044FF,
               cardholderSize: 24,
               cardholderHintColor: 0xFF0044FF,
               cardholderHintSize: 24,
               cardholderHintText: 'Text',
               cardholderTitleColor: 0xFF0044FF,
               cardholderTitleSize: 24,
               cardholderTitleText: 'Title',
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

```

### Additional information
Take a look at the following resources to manage your payment accounts and learn more about the APIs for the supported providers:

|  | Google Pay | Apple Pay |
|:---|:---|:---|
| Platforms | Android | iOS |
| Documentation | [Overview](https://developers.google.com/pay/api/android/overview) | [Overview](https://developer.apple.com/apple-pay/implementation/)
| Console | [Google Pay Business Console](https://pay.google.com/business/console/) |  [Developer portal](https://developer.apple.com/account/)  |
| Reference | [API reference](https://developers.google.com/pay/api/android/reference/client) | [Apple Pay API](https://developer.apple.com/documentation/passkit/apple_pay/)
| Style guidelines | [Brand guidelines](https://developers.google.com/pay/api/android/guides/brand-guidelines) | [Buttons and Marks](https://developer.apple.com/design/human-interface-guidelines/apple-pay/overview/buttons-and-marks/)
