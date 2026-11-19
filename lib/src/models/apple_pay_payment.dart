import 'dart:convert';

/// Результат оплаты Apple Pay (`onPaymentResult` из пакета `pay`).
class ApplePayPayment {
  final String data;
  final String signature;
  final String version;
  final String publicKeyHash;
  final String ephemeralPublicKey;
  final String transactionId;
  final String? displayName;
  final String? network;
  final String? type;
  final String transactionIdentifier;

  const ApplePayPayment({
    required this.data,
    required this.signature,
    required this.version,
    required this.publicKeyHash,
    required this.ephemeralPublicKey,
    required this.transactionId,
    required this.displayName,
    required this.network,
    required this.type,
    required this.transactionIdentifier,
  });

  /// Создаёт [ApplePayPayment] из результата Apple Pay.
  ///
  /// `token` — строковый JSON платёжного токена Apple, декодируется здесь
  /// же (раньше по нему было шесть `json.decode`).
  ///
  /// Бросает [ArgumentError] при неполной структуре и [FormatException]
  /// при битом `token`.
  factory ApplePayPayment.fromJson(Map<String, Object?> json) {
    if (json
        case <String, Object?>{
          'token': final String token,
          'paymentMethod': final Map<String, Object?> paymentMethod,
          'transactionIdentifier': final String transactionIdentifier,
        }) {
      if (jsonDecode(token)
          case <String, Object?>{
            'data': final String data,
            'signature': final String signature,
            'version': final String version,
            'header': <String, Object?>{
              'publicKeyHash': final String publicKeyHash,
              'ephemeralPublicKey': final String ephemeralPublicKey,
              'transactionId': final String transactionId,
            },
          }) {
        return ApplePayPayment(
          data: data,
          signature: signature,
          version: version,
          publicKeyHash: publicKeyHash,
          ephemeralPublicKey: ephemeralPublicKey,
          transactionId: transactionId,
          displayName: switch (paymentMethod) {
            {'displayName': final String? value} => value,
            _ => null,
          },
          network: switch (paymentMethod) {
            {'network': final String? value} => value,
            _ => null,
          },
          type: switch (paymentMethod) {
            {'type': final String? value} => value,
            _ => null,
          },
          transactionIdentifier: transactionIdentifier,
        );
      }
    }
    throw ArgumentError('Invalid JSON format for ApplePayPayment: $json');
  }

  /// Узел `token` запроса в платёжный API — структура, пришедшая от Apple,
  /// собранная обратно из полей.
  Map<String, Object?> toJson() => {
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
      };
}
