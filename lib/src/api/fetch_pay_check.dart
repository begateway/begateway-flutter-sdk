import 'dart:async';
import 'dart:convert';

import 'package:begateway_flutter_sdk/src/constants/constants.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> fetchPayCheck(
  AppState appState,
) async {
  final url = Uri.parse(ApiConstants.checkoutUrl + appState.token);
  // Data for the headers request
  final headersData = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-Version': '2.1',
  };
  try {
    // Make request
    appState.setIsLoading(true);
    final response = await http.get(url, headers: headersData);
    String status = await json.decode(response.body)["checkout"]["status"];
    if (status == 'successful' || status == 'failed' || status == 'error') {
      // Successful request
      Map<String, dynamic> answear = await json.decode(response.body);
      String nameCompany = answear["checkout"]["company"]["name"];
      appState.updateIsBegateway(false);
      appState.answearBegateway(answear);
      appState.setIsLoading(false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('nameCompany', nameCompany);
    } else {
      Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        fetchPayCheck(appState);
      });
    }
  } catch (e) {
    // If Error
    appState.setIsLoading(false);
    debugPrint('Error: $e');
  }
}
