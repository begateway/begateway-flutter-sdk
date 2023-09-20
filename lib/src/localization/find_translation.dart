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

String findTranslation(String locale, String phrase) {
  String result = '';
  switch (locale) {
    case 'az':
      result = az[phrase] ?? phrase;
      break;
    case 'be':
      result = be[phrase] ?? phrase;
      break;
    case 'da':
      result = da[phrase] ?? phrase;
      break;
    case 'de':
      result = de[phrase] ?? phrase;
      break;
    case 'en':
      result = en[phrase] ?? phrase;
      break;
    case 'es':
      result = es[phrase] ?? phrase;
      break;
    case 'fi':
      result = fi[phrase] ?? phrase;
      break;
    case 'fr':
      result = fr[phrase] ?? phrase;
      break;
    case 'it':
      result = it[phrase] ?? phrase;
      break;
    case 'ja':
      result = ja[phrase] ?? phrase;
      break;
    case 'ka':
      result = ka[phrase] ?? phrase;
      break;
    case 'lv':
      result = lv[phrase] ?? phrase;
      break;
    case 'nb':
      result = nb[phrase] ?? phrase;
      break;
    case 'pl':
      result = pl[phrase] ?? phrase;
      break;
    case 'ro':
      result = ro[phrase] ?? phrase;
      break;
    case 'ru':
      result = ru[phrase] ?? phrase;
      break;
    case 'sv':
      result = sv[phrase] ?? phrase;
      break;
    case 'tr':
      result = tr[phrase] ?? phrase;
      break;
    case 'uk':
      result = uk[phrase] ?? phrase;
      break;
       case 'zh':
      result = zh[phrase] ?? phrase;
      break;
  }
  return result;
}
