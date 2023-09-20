import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:begateway_flutter_sdk/src/api/fetch_pay_token.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import '../constants/constants.dart';
import 'fetch_pay_check.dart';

Future<void> fetchGooglePay(
  Map<String, dynamic> result,
  AppState appState,
) async {
  var token = '';
  if (appState.publicKey!.length > 64) {
    token = await fetchPayToken(appState);
    print('token: $token');
    appState.setToken(token);
  } else {
    token = appState.token;
    appState.setToken(token);
  }
  final data = await json.decode(result["token"])["data"];
  final signature = await json.decode(result["token"])["signature"];
  final publicKeyHash =
      await json.decode(result["token"])["header"]["publicKeyHash"];
  final ephemeralPublicKey =
      await json.decode(result["token"])["header"]["ephemeralPublicKey"];
  final transactionId =
      await json.decode(result["token"])["header"]["transactionId"];
  final version = await json.decode(result["token"])["version"];
  final displayName = await result["paymentMethod"]["displayName"];
  final network = await result["paymentMethod"]["network"];
  final type = await result["paymentMethod"]["type"];
  final transactionIdentifier = await result["transactionIdentifier"];

  final url = Uri.parse(ApiConstants.googlePayUrl);
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-Version': '2.1',
    'Authorization': token,
  };

  final requestData = {
    "request": {
      "apiVersionMinor": 0,
      "apiVersion": 2,
      "paymentMethodData": {
        "description": "Visa ••••1713",
        "tokenizationData": {
          "type": "PAYMENT_GATEWAY",
          "token": {
            "signature":
                "MEUCIDxOFdUndPc4jKY6WmsIQykY3o3dKGL38yPrVMd8BnFuAiEA66KCTYFgy42H2iNFZEvUGZnwnBtqFdBvPXJUzoHJ1gu003d",
            "intermediateSigningKey": {
              "signedKey": {
                "keyValue":
                    "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEhHi/UhqsqMlQElJ6qWcTmM6TTCEKVJspl7gAde6YQWHu0+no4zIh+xCMZpOvNOUcLZOY5E9+BBYOg9FG+vOCbQu003du003d",
                "keyExpiration": "1646820121000"
              },
              "signatures": [
                "MEUCIATnglGPA946hFIiuPeuiL9eq12yoQtEuzHdwhYxQ8AiEApBMemJxKzWQNiJFrDMpCr5MMtMup2aVg6FM0HJCqvJQu003d"
              ]
            },
            "protocolVersion": "ECv2",
            "signedMessage": {
              "encryptedMessage":
                  "vqZta6Te4/ojWDoHmToDFx65TpjaPxYU8ToE7f0i4JQJWKENnIdunDNYzwZWY0BdYprzau33qr9x5Wk2V9FWRCdnkHMZfwY6Oaw7TMKJrrcrI1mKG7OdMiFh+p1VtZUAOPOhQ3FMNjjpTT8mbZ1Z7WP3vmpKpLoI1hGqLc8Cj5nBmKewzxGjZcfWWk4c648Er1egYu1srRpAGvTUn+zJvCDa4J65eiU7KfO21dGKkfkk3zNHe0V4YkHrkskgV4P2h2Cvqe+fd2aUA82va8MTZ7Z9m8g+n1dV422cMl7Q4T6elpjwBuYTJx5BCi3DaCBaWgCtUnsbSOf6jjx8yHOiaFPxMmjB6tqq/WUEIh3DdErHpdKOHv9iFowiMGsKU3lJpFxBSpzPG1uruSfRLyJYp4AHvf+/HU0H44nIDHr23QiX0P6QxHCtW2k6M7gsHl9yddDHVuJOH78AckecYsNuKFtZIQu003du003d",
              "ephemeralPublicKey":
                  "BLndl9rboC4qqQgfMyqjnGCZFvsaV+HBhHW4Rq2Mt8OwvCuQkDKvucg5w9j1IN4AREaxIihza6tAioJv61c4CEMu003d",
              "tag": "sog2rP+qZ0Ti+U0xFG1MjVrg6vD8IhmF3JpBWpMiEu003d"
            }
          }
        },
        "type": "CARD",
        "info": {"cardNetwork": "VISA", "cardDetails": "1713"}
      }
    },
    "token": token,
    "customer": {
      "first_name": appState.holder?.split(' ')[0],
      "last_name": appState.holder?.split(' ')[1],
      "address": "",
      "country": appState.customerCountry,
      "city": "",
      "zip": "",
      "state": "",
      "phone": "",
      "email": ""
    },
    "contract": appState.customerContract,
  };
  try {
    //final response =
    await http.post(url, headers: headers, body: jsonEncode(requestData));
    //Map<String, dynamic> answear = await json.decode(response.body);

    fetchPayCheck(appState);
  } catch (e) {
    // Error Handling

    appState.setIsLoading(false);
    debugPrint('Error: $e');
  }
}

const token = {
  "signature":"MEUCI+slJGaKBHZmphgIgJ8GKHlrPKnQcObF/lGfYjDmt1pu3kzPOYoBmdjdUFvw\\u003d",
  "intermediateSigningKey": {
    "signedKey": {
      "keyValue":
          "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQca0NVUE0gp/9xbueVNmy1o+NTcInbX/9ZN0QbXr8mngu003du003d",
      "keyExpiration": "1614913712991"
    },
    "signatures": [
      "MEUCIQDb6d5nYqcL57Q09DPDrDKWxMgIgKaiLAEfdwNwG7S6nMvX1gRvQu003d"
    ]
  },
  "protocolVersion": "ECv2",
  "signedMessage": {
    "encryptedMessage":
        "9gmVUfk1Jua03felBqSUY4yXwzDzlhSHE2jm4VHDgsQ3xnzjQrlTAiyM87dP+8Cx9cks6SbrrK6vyWR7WmrPFhOaNFlulCvn9fI213ofHjRz7ebP71IFRCpgjeqG+nMQJXY8zjkhwXkUJTtOJ4SpXV7ByLyIXb/UJU7pg3O1m3Tl1zpe8C+hLQpKvAIZSAwEl4EBRafbcE33JyuV7RNLMlAerlELsGPUm0c04mM11vF3vdBVfgiyvVw5pJD2Gk/DX7fHdrUpPnzRt5ZoFU0jWZq/8rsj57cEzR+MK2MJVZE014D7iB8+7qcFjJ5H6Tdc/DCsyO5XDVp3Lu5aWZrIqJ6b9BkNPGiCDrV1OKRngc4OYPIGj7OrP7nQgIeU97EYT2xLzqWnfZ/PNCtj89mvT9mKp8y7V6eCJmK8BJsH9MLH08olwGo9pcU7Av2OXo837qUkcCxrkDrYh+wSbqS4p1SyoqgW+2BR+2zRoXU",
    "ephemeralPublicKey":
        "BAAqw+C7aP+Z6KL2HLiP5J7Y/gEWpLQedowh7+r/7taxfNbNuC4u003d",
    "tag": "jkqoAh5l16mzlpmqVzpFx/k64u003d"
  }
};
