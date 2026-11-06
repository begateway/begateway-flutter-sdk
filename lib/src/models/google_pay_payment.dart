/// PaymentData из Google Pay (`PaymentData.toJson()` из пакета `pay`).
class GooglePayPayment {
  final int apiVersion;
  final int apiVersionMinor;
  final GooglePayMethodData paymentMethodData;

  const GooglePayPayment({
    required this.apiVersion,
    required this.apiVersionMinor,
    required this.paymentMethodData,
  });

  /// Создаёт [GooglePayPayment] из результата Google Pay.
  ///
  /// Бросает [ArgumentError], если нет `paymentMethodData.tokenizationData.token`.
  factory GooglePayPayment.fromJson(Map<String, Object?> json) {
    if (json
        case <String, Object?>{
          'paymentMethodData': final Map<String, Object?> methodData,
        }) {
      return GooglePayPayment(
        apiVersion: switch (json) {
          {'apiVersion': final int version} => version,
          _ => 2,
        },
        apiVersionMinor: switch (json) {
          {'apiVersionMinor': final int version} => version,
          _ => 0,
        },
        paymentMethodData: GooglePayMethodData.fromJson(methodData),
      );
    }
    throw ArgumentError('Invalid JSON format for GooglePayPayment: $json');
  }

  /// Узел `request` запроса в платёжный API.
  Map<String, Object?> toJson() => {
        'apiVersionMinor': apiVersionMinor,
        'apiVersion': apiVersion,
        'paymentMethodData': paymentMethodData.toJson(),
      };
}

/// `paymentMethodData` из результата Google Pay.
class GooglePayMethodData {
  final String? description;
  final String? type;
  final GooglePayCardInfo info;

  /// Тип токенизации, например `PAYMENT_GATEWAY`.
  final String tokenizationType;

  /// Строковый JSON-токен от Google: в запросе остаётся строкой,
  /// как у официальной JS-библиотеки bePaid
  /// (js.bepaid.by/widget/google_pay.js → POST ctp/api/{type}/payment).
  final String token;

  const GooglePayMethodData({
    this.description,
    this.type,
    required this.info,
    required this.tokenizationType,
    required this.token,
  });

  /// Создаёт [GooglePayMethodData] из JSON карты `paymentMethodData`.
  ///
  /// Бросает [ArgumentError], если нет `tokenizationData.token`.
  factory GooglePayMethodData.fromJson(Map<String, Object?> json) {
    if (json
        case <String, Object?>{
          'tokenizationData': final Map<String, Object?> tokenization,
        }) {
      if (tokenization case {'token': final String token}) {
        return GooglePayMethodData(
          description: switch (json) {
            {'description': final String value} => value,
            _ => null,
          },
          type: switch (json) {
            {'type': final String value} => value,
            _ => null,
          },
          info: switch (json) {
            {'info': final Map<String, Object?> info} =>
              GooglePayCardInfo.fromJson(info),
            _ => const GooglePayCardInfo(),
          },
          tokenizationType: switch (tokenization) {
            {'type': final String value} => value,
            _ => 'PAYMENT_GATEWAY',
          },
          token: token,
        );
      }
    }
    throw ArgumentError('Invalid JSON format for GooglePayMethodData: $json');
  }

  Map<String, Object?> toJson() => {
        if (description != null) 'description': description,
        'tokenizationData': {'type': tokenizationType, 'token': token},
        if (type != null) 'type': type,
        'info': info.toJson(),
      };
}

/// `info` из Google Pay: сеть и маскированный номер карты.
class GooglePayCardInfo {
  final String? cardNetwork;
  final String? cardDetails;

  const GooglePayCardInfo({this.cardNetwork, this.cardDetails});

  factory GooglePayCardInfo.fromJson(Map<String, Object?> json) =>
      GooglePayCardInfo(
        cardNetwork: switch (json) {
          {'cardNetwork': final String value} => value,
          _ => null,
        },
        cardDetails: switch (json) {
          {'cardDetails': final String value} => value,
          _ => null,
        },
      );

  Map<String, Object?> toJson() => {
        if (cardNetwork != null) 'cardNetwork': cardNetwork,
        if (cardDetails != null) 'cardDetails': cardDetails,
      };
}
