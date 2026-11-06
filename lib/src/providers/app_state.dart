import 'dart:async';

import 'package:flutter/foundation.dart';

import '../utils/storage_service.dart';
import 'payment_config.dart';

/// Мутабельное состояние платежа: флаги, ссылки, токены.
///
/// Неизменяемые параметры (реквизиты, стили) живут в [PaymentConfig] и через
/// него доступны как `appState.config`.
///
/// Флаги, которые читает UI, — [ValueNotifier]: перестраивается только
/// подписавшийся виджет, а не всё дерево. Поля, которые UI не читает
/// (`token`, `urlLink`, ...), просто присваиваются без уведомлений.
class AppState extends ChangeNotifier {
  AppState({
    required this.config,
    required this.storage,
    required this.updateIsBegateway,
    required this.answearBegateway,
  });

  final PaymentConfig config;

  /// Хранилище карт и названия компании: реализация приложения
  /// (см. [StorageService]).
  final StorageService storage;

  /// Колбэк наружу: показать/скрыть виджет SDK.
  final void Function(bool) updateIsBegateway;

  /// Колбэк наружу: ответ сервера (успех/ошибка платежа).
  final void Function(Map<String, dynamic>) answearBegateway;

  /// Значения по умолчанию, когда AppStateScope выше по дереву не найден.
  factory AppState.empty() => AppState(
        config: PaymentConfig.empty(),
        storage: InMemoryStorage(),
        updateIsBegateway: _ignoreBool,
        answearBegateway: _ignoreMap,
      );

  /// Идёт запрос — показывать индикатор.
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  /// Открыт 3D Secure WebView вместо формы.
  final ValueNotifier<bool> isShowWebview = ValueNotifier(false);

  /// Флаг «сохранить карту» в переключателе.
  final ValueNotifier<bool> isSaveCard = ValueNotifier(false);

  String urlLink = '';
  String resultUrl = '';
  String token = '';
  String saveCardToken = '';

  void setIsLoading(bool value) => isLoading.value = value;

  void setIsShowWebview(bool value) => isShowWebview.value = value;

  void setIsSaveCard(bool value) => isSaveCard.value = value;

  void setToken(String value) => token = value;

  void setSaveCardToken(String value) => saveCardToken = value;

  /// Переход на экран 3D Secure: ссылки и оба флага меняются всегда вместе.
  void openWebView({required String url, required String resultUrl}) {
    urlLink = url;
    this.resultUrl = resultUrl;
    isShowWebview.value = true;
    isLoading.value = false;
  }

  /// Одиночный таймер опроса статуса транзакции.
  Timer? _statusTimer;

  /// Запланировать повторную проверку статуса через [delay].
  ///
  /// Прошлый таймер отменяется: раньше каждый нефинальный статус порождал
  /// новый `Timer.periodic` без отмены — таймеры накапливались
  /// с экспоненциальной скоростью и дублировали ответ торговцу.
  void scheduleStatusCheck(
    void Function() check, {
    Duration delay = const Duration(seconds: 3),
  }) {
    _statusTimer?.cancel();
    _statusTimer = Timer(delay, () {
      _statusTimer = null;
      check();
    });
  }

  /// Остановить опрос: транзакция финализирована или виджет закрыт.
  void cancelStatusCheck() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  @override
  void dispose() {
    cancelStatusCheck();
    isLoading.dispose();
    isShowWebview.dispose();
    isSaveCard.dispose();
    super.dispose();
  }
}

void _ignoreBool(bool _) {}
void _ignoreMap(Map<String, dynamic> _) {}
