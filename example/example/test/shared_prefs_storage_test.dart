import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:example/utils/shared_prefs_storage.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  SaveCardModel card(String token, {String brand = 'VISA'}) => SaveCardModel(
        brand: brand,
        lastFourNumbers: '1111',
        saveToken: token,
      );

  test('пустое хранилище отдаёт пустой список', () async {
    expect(await const SharedPrefsStorage().getCards(), isEmpty);
  });

  test('добавленные карты переживают пересоздание реализации', () async {
    await const SharedPrefsStorage().addCard(card('tok1'));
    await const SharedPrefsStorage().addCard(card('tok2', brand: 'MASTERCARD'));

    // Новый экземпляр = новый запуск приложения: данные в prefs.
    final cards = await const SharedPrefsStorage().getCards();
    expect(cards, hasLength(2));
    expect(cards.first.saveToken, 'tok1');
    expect(cards.first.brand, 'VISA');
    expect(cards.last.saveToken, 'tok2');
    expect(cards.last.brand, 'MASTERCARD');
  });

  test('удаление карты по токену', () async {
    const storage = SharedPrefsStorage();
    await storage.addCard(card('tok1'));
    await storage.addCard(card('tok2'));

    await storage.removeCard('tok1');

    final cards = await storage.getCards();
    expect(cards, hasLength(1));
    expect(cards.single.saveToken, 'tok2');
  });

  test('название компании пишется и читается', () async {
    const storage = SharedPrefsStorage();

    expect(await storage.getCompanyName(), isNull);

    await storage.setCompanyName('ООО Ромашка');
    expect(await storage.getCompanyName(), 'ООО Ромашка');
  });
}
