import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:begateway_flutter_sdk/src/api/fetch_pay_token.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import '../constants/constants.dart';
import 'fetch_pay_check.dart';

Future<void> fetchApplePay(
  Map<String, dynamic> result,
  AppState appState,
) async {
  var token = '';
  if (appState.publicKey.length > 64) {
    token = await fetchPayToken(appState);
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

  final url = Uri.parse(ApiConstants.applePayUrl);
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-Version': '2.1',
    'Authorization': token,
  };

  final requestData = {
    'request': {
      'token': {
        'paymentData': {
          'data': data,
          'signature': signature,
          'header': {
            'publicKeyHash': publicKeyHash,
            'ephemeralPublicKey': ephemeralPublicKey,
            'transactionId': transactionId,
          },
          'version': version,
        },
        'paymentMethod': {
          'displayName': displayName,
          'network': network,
          'type': type,
        },
        'transactionIdentifier': transactionIdentifier,
      },
    },
    'token': token,
    'customer': {
      'first_name': appState.holder.split(' ')[0],
      'last_name': appState.holder.split(' ')[1],
      'address': '',
      'country': appState.customerCountry,
      'city': 'London',
      'zip': '',
      'state': '',
      'phone': '',
      'email': appState.customerEmail,
    },
    'contract': appState.customerContract,
    'additional_data': {
      'contract': ["card_on_file"],
      'request_id': '',
    },
    // Add other data fields as needed
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


