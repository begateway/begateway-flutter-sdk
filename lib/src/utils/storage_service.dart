import '../models/save_card_model.dart';

/// Абстракция хранилища платежа: сохранённые карты и название
/// компании для блока «безопасно».
///
/// Ядро не знает, где данные лежат: приложение реализует
/// [StorageService] (например, на `shared_preferences` — см.
/// `example/lib/utils/shared_prefs_storage.dart`) и передаёт
/// экземпляр в `Begateway(storage: ...)`.
abstract class StorageService {
  /// Добавить сохранённую карту.
  Future<void> addCard(SaveCardModel card);

  /// Список сохранённых карт.
  Future<List<SaveCardModel>> getCards();

  /// Удалить карту по токену; несуществующий токен — no-op.
  Future<void> removeCard(String saveToken);

  /// Записать название компании (для блока «безопасно»).
  Future<void> setCompanyName(String name);

  /// Название компании или null, если платёж ещё не завершался.
  Future<String?> getCompanyName();
}

/// Хранилище в памяти: не переживает перезапуск приложения.
///
/// Нужно для [AppState.empty] и тестов; в приложении передавайте
/// собственную реализацию с персистентностью.
class InMemoryStorage implements StorageService {
  final _cards = <SaveCardModel>[];
  String? _companyName;

  @override
  Future<void> addCard(SaveCardModel card) async {
    _cards.add(card);
  }

  @override
  Future<List<SaveCardModel>> getCards() async => List.unmodifiable(_cards);

  @override
  Future<void> removeCard(String saveToken) async {
    _cards.removeWhere((card) => card.saveToken == saveToken);
  }

  @override
  Future<void> setCompanyName(String name) async {
    _companyName = name;
  }

  @override
  Future<String?> getCompanyName() async => _companyName;
}
