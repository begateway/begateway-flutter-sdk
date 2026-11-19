import 'az/az.dart';
import 'be/be.dart';
import 'da/da.dart';
import 'de/de.dart';
import 'en/en.dart';
import 'es/es.dart';
import 'fi/fi.dart';
import 'fr/fr.dart';
import 'it/it.dart';
import 'ja/ja.dart';
import 'ka/ka.dart';
import 'lv/lv.dart';
import 'nb/nb.dart';
import 'pl/pl.dart';
import 'ro/ro.dart';
import 'ru/ru.dart';
import 'sv/sv.dart';
import 'tr/tr.dart';
import 'uk/uk.dart';
import 'zh/zh.dart';

/// Все переводы по коду локали. Поиск по ключу — O(1), без switch на 20 веток.
const Map<String, Map<String, String>> _translations = {
  'az': az,
  'be': be,
  'da': da,
  'de': de,
  'en': en,
  'es': es,
  'fi': fi,
  'fr': fr,
  'it': it,
  'ja': ja,
  'ka': ka,
  'lv': lv,
  'nb': nb,
  'pl': pl,
  'ro': ro,
  'ru': ru,
  'sv': sv,
  'tr': tr,
  'uk': uk,
  'zh': zh,
};

/// Перевод [phrase] для [locale]: локаль → fallback на en → сам ключ.
String findTranslation(String locale, String phrase) {
  final dictionary = _translations[locale];
  return dictionary?[phrase] ?? en[phrase] ?? phrase;
}
