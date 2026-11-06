class SaveCardModel {
  final String? brand;
  final String? lastFourNumbers;
  final String? saveToken;

  SaveCardModel({
    required this.brand,
    required this.lastFourNumbers,
    required this.saveToken,
  });

  /// Создаёт [SaveCardModel] из JSON карты.
  ///
  /// Карты пишет сам SDK, поэтому отсутствующие ключи допускаются (→ null),
  /// но значение читается через паттерн: не-строка не уронит чтение
  /// хранилища с TypeError, а станет null.
  SaveCardModel.fromJson(Map<String, Object?> json)
      : brand = switch (json) {
          {'brand': final String? value} => value,
          _ => null,
        },
        lastFourNumbers = switch (json) {
          {'lastFourNumbers': final String? value} => value,
          _ => null,
        },
        saveToken = switch (json) {
          {'saveToken': final String? value} => value,
          _ => null,
        };

  Map<String, Object?> toJson() => {
        'brand': brand,
        'lastFourNumbers': lastFourNumbers,
        'saveToken': saveToken,
      };
}
