import 'dart:convert';

import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Реализация хранилища на `shared_preferences` для примера.
///
/// Сохранённые карты лежат под ключом `cardList` (список JSON-строк),
/// название компании для блока «безопасно» — под `nameCompany`.
class SharedPrefsStorage implements StorageService {
  const SharedPrefsStorage();

  static const _cardListKey = 'cardList';
  static const _companyNameKey = 'nameCompany';

  @override
  Future<void> addCard(SaveCardModel card) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_cardListKey) ?? [];

    jsonList.add(jsonEncode(card.toJson()));

    await prefs.setStringList(_cardListKey, jsonList);
  }

  @override
  Future<List<SaveCardModel>> getCards() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_cardListKey) ?? [];

    return jsonList
        .map((json) => SaveCardModel.fromJson(jsonDecode(json)))
        .toList();
  }

  @override
  Future<void> removeCard(String saveToken) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_cardListKey) ?? [];

    jsonList.removeWhere((json) {
      final card = SaveCardModel.fromJson(jsonDecode(json));
      return card.saveToken == saveToken;
    });

    await prefs.setStringList(_cardListKey, jsonList);
  }

  @override
  Future<void> setCompanyName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companyNameKey, name);
  }

  @override
  Future<String?> getCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyNameKey);
  }
}
