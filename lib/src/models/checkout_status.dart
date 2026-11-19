/// Статус транзакции из ответа на GET checkout/{token}.
class CheckoutStatus {
  /// Статус платежа: `pending`, `successful`, `failed`, `error` и т.д.
  final String status;

  /// Название компании-получателя: доступно, когда статус финальный.
  final String? companyName;

  const CheckoutStatus({required this.status, this.companyName});

  /// Создаёт [CheckoutStatus] из JSON карты.
  ///
  /// Бросает [ArgumentError], если в ответе нет `checkout.status`.
  factory CheckoutStatus.fromJson(Map<String, Object?> json) {
    if (json
        case <String, Object?>{
          'checkout': final Map<String, Object?> checkout,
        }) {
      if (checkout case {'status': final String status}) {
        return CheckoutStatus(
          status: status,
          companyName: switch (checkout) {
            {'company': <String, Object?>{'name': final String name}} => name,
            _ => null,
          },
        );
      }
    }
    throw ArgumentError('Invalid JSON format for CheckoutStatus: $json');
  }
}
