/// Ответ bePaid на создание checkout (POST checkout).
class CheckoutToken {
  /// Токен созданного checkout — идентификатор платежа.
  final String token;

  /// Ссылка на платёжную страницу: заполняется, когда платёж идёт
  /// по сохранённой карте и покупатель подтверждает его на странице bePaid.
  final String? redirectUrl;

  const CheckoutToken({required this.token, this.redirectUrl});

  /// Создаёт [CheckoutToken] из JSON карты.
  ///
  /// Бросает [ArgumentError], если в ответе нет `checkout.token` —
  /// структура ответа не соответствует контракту API.
  factory CheckoutToken.fromJson(Map<String, Object?> json) {
    if (json
        case <String, Object?>{
          'checkout': final Map<String, Object?> checkout,
        }) {
      if (checkout case {'token': final String token}) {
        return CheckoutToken(
          token: token,
          redirectUrl: switch (checkout) {
            {'redirect_url': final String url} => url,
            _ => null,
          },
        );
      }
    }
    throw ArgumentError('Invalid JSON format for CheckoutToken: $json');
  }
}
