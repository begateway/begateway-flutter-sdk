import 'package:begateway_flutter_sdk/src/localization/en/en.dart';
import 'package:begateway_flutter_sdk/src/localization/find_translation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('известная локаль отдаёт свой перевод', () {
    expect(findTranslation('ru', 'begateway_card_number_required'),
        'Необходимо указать номер карты');
    expect(findTranslation('en', 'begateway_card_number_required'),
        'Card number is required');
  });

  test('неизвестная локаль падает на en', () {
    expect(findTranslation('xx', 'begateway_card_number_required'),
        'Card number is required');
    expect(findTranslation('', 'begateway_card_number_required'),
        'Card number is required');
  });

  test('ключ, которого нет в локали, берётся из en', () {
    // scan_by_camera есть в en, но отсутствует в большинстве локалей.
    expect(findTranslation('ru', 'scan_by_camera'), en['scan_by_camera']);
  });

  test('неизвестный ключ возвращает сам ключ', () {
    expect(findTranslation('en', 'no_such_phrase'), 'no_such_phrase');
    expect(findTranslation('xx', 'no_such_phrase'), 'no_such_phrase');
  });

  test('для всех основных локалей есть перевод ключа', () {
    const locales = [
      'az',
      'be',
      'da',
      'de',
      'en',
      'es',
      'fi',
      'fr',
      'it',
      'ja',
      'ka',
      'lv',
      'nb',
      'pl',
      'ro',
      'ru',
      'sv',
      'tr',
      'uk',
      'zh',
    ];
    for (final locale in locales) {
      final value = findTranslation(locale, 'begateway_savecard');
      expect(value, isNotEmpty, reason: 'нет перевода для локали $locale');
      expect(value, isNot('begateway_savecard'),
          reason: 'ключ не переведён в локали $locale');
    }
  });
}
