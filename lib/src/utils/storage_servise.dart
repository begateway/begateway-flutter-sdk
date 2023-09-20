import 'dart:convert';

import 'package:begateway_flutter_sdk/src/models/save_card_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Функция для добавления карты в массив
Future<void> addCardToStorage(SaveCardModel card) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? jsonList = prefs.getStringList('cardList') ?? [];
  
  jsonList.add(jsonEncode(card.toJson()));

  await prefs.setStringList('cardList', jsonList);
}

// Функция для получения массива сохраненных карт
Future<List<SaveCardModel>> getSavedCardsFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? jsonList = prefs.getStringList('cardList');

  if (jsonList != null) {
    List<SaveCardModel> savedCardList = jsonList
        .map((json) => SaveCardModel.fromJson(jsonDecode(json)))
        .toList();
    return savedCardList;
  }

  return [];
}
// Функция для удаления сохраненной карты
Future<void> removeCardFromStorage(String saveToken) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? jsonList = prefs.getStringList('cardList') ?? [];

  jsonList.removeWhere((json) {
    final card = SaveCardModel.fromJson(jsonDecode(json));
    return card.saveToken == saveToken;
  });

  await prefs.setStringList('cardList', jsonList);
}

