import 'save_card_model.dart';

/// Ответ платёжного API bePaid на списание (POST .../payment).
class PaymentResponse {
  /// Статус операции: `incomplete`, `successful`, `failed`, `error`.
  final String status;

  /// Ссылка на 3D Secure: заполняется при статусе `incomplete`.
  final String? url;

  /// Ссылка возврата с 3D Secure: заполняется при статусе `incomplete`.
  final String? resultUrl;

  /// Данные карты ответа: бренд, последние 4 цифры (`last_4`) и токен
  /// сохранения — ключи сервера уже приведены к полям [SaveCardModel].
  final SaveCardModel? creditCard;

  const PaymentResponse({
    required this.status,
    this.url,
    this.resultUrl,
    this.creditCard,
  });

  /// Создаёт [PaymentResponse] из JSON карты.
  ///
  /// Бросает [ArgumentError], если в ответе нет `response.status`.
  factory PaymentResponse.fromJson(Map<String, Object?> json) {
    if (json
        case <String, Object?>{
          'response': final Map<String, Object?> response,
        }) {
      if (response case {'status': final String status}) {
        return PaymentResponse(
          status: status,
          url: switch (response) {
            {'url': final String url} => url,
            _ => null,
          },
          resultUrl: switch (response) {
            {'result_url': final String url} => url,
            _ => null,
          },
          creditCard: switch (response) {
            {'credit_card': final Map<String, Object?> card} => SaveCardModel(
                brand: switch (card) {
                  {'brand': final String? value} => value,
                  _ => null,
                },
                lastFourNumbers: switch (card) {
                  {'last_4': final String? value} => value,
                  _ => null,
                },
                saveToken: switch (card) {
                  {'token': final String? value} => value,
                  _ => null,
                },
              ),
            _ => null,
          },
        );
      }
    }
    throw ArgumentError('Invalid JSON format for PaymentResponse: $json');
  }
}
