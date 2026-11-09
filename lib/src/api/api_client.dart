import 'dart:convert';

import 'package:http/http.dart' as http;

/// Единая точка HTTP-вызовов SDK.
///
/// Здесь централизованы кодирование тела ([jsonEncode]) и таймаут: висящий
/// запрос не должен держать индикатор загрузки вечно. Декодирование ответа
/// остаётся за вызывающим кодом — у разных эндпоинтов своя логика разбора.
class ApiClient {
  ApiClient._();

  /// Таймаут одного запроса.
  static const Duration timeout = Duration(seconds: 30);

  static Future<http.Response> post(
    Uri url, {
    required Map<String, String> headers,
    required Object body,
  }) {
    return http
        .post(url, headers: headers, body: jsonEncode(body))
        .timeout(timeout);
  }

  static Future<http.Response> get(
    Uri url, {
    required Map<String, String> headers,
  }) {
    return http.get(url, headers: headers).timeout(timeout);
  }
}
