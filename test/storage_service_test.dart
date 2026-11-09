import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SaveCardModel card(String token, {String brand = 'VISA'}) => SaveCardModel(
        brand: brand,
        lastFourNumbers: '1111',
        saveToken: token,
      );

  test('пустое хранилище отдаёт пустой список', () async {
    expect(await InMemoryStorage().getCards(), isEmpty);
  });

  test('добавленные карты читаются обратно', () async {
    final storage = InMemoryStorage();
    await storage.addCard(card('tok1'));
    await storage.addCard(card('tok2', brand: 'MASTERCARD'));

    final cards = await storage.getCards();
    expect(cards, hasLength(2));
    expect(cards.first.saveToken, 'tok1');
    expect(cards.first.brand, 'VISA');
    expect(cards.last.saveToken, 'tok2');
    expect(cards.last.brand, 'MASTERCARD');
  });

  test('удаление карты по токену', () async {
    final storage = InMemoryStorage();
    await storage.addCard(card('tok1'));
    await storage.addCard(card('tok2'));

    await storage.removeCard('tok1');

    final cards = await storage.getCards();
    expect(cards, hasLength(1));
    expect(cards.single.saveToken, 'tok2');
  });

  test('удаление несуществующего токена не ломает хранилище', () async {
    final storage = InMemoryStorage();
    await storage.addCard(card('tok1'));

    await storage.removeCard('no-such-token');

    expect(await storage.getCards(), hasLength(1));
  });

  test('название компании пишется и читается', () async {
    final storage = InMemoryStorage();

    expect(await storage.getCompanyName(), isNull);

    await storage.setCompanyName('ООО Ромашка');
    expect(await storage.getCompanyName(), 'ООО Ромашка');
  });
}
