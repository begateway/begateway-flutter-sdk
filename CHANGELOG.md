## Unreleased

### Added

* Абстракция UI для приложения: `BegatewayPages` — SDK больше не содержит
  готовых экранов, приложение передаёт свои страницы оплаты, выбора карт
  и WebView.
* Абстракция хранилища `StorageService`: SDK не зависит от
  `shared_preferences`, реализация хранилища выбирается приложением.
* `AppStateScope`, `AppState` и `PaymentConfig` для управления состоянием
  платежа без привязки к UI.
* Слой API: `ApiClient`, `CheckoutRequest`, `CheckoutToken`,
  `CheckoutStatus`, `PaymentResponse`, модели Apple Pay и Google Pay.
* Типизированные модели ответов и сохранённых карт.
* Тесты SDK и примера: API-клиент, парсинг JSON, хранилище, переводы,
  виджеты и сценарии оплаты.

### Changed

* Пример приложения декомпозирован на виджеты: `MyApp`, `CheckoutFlow`,
  `ProductPage`, `BegatewayCheckout` и `ExampleBegatewayPages`.
* В приложении остался один `MaterialApp`; WebView больше не создаёт
  второй `Scaffold` поверх платёжной страницы.
* Android-конфигурация примера переведена на актуальный стек Flutter:
  Gradle 9.8.2, AGP 9.3.2, Kotlin 2.4.0, Kotlin DSL, `compileSdk 37`,
  Java/Kotlin target 17.
* Обновлены зависимости: `pay` 4.x, `permission_handler` 13.x,
  `shared_preferences` 2.5.x, `webview_flutter` 4.14.x,
  `flutter_svg` 2.3.x, `http` 1.x, `flutter_lints` 6.x.
* SDK переведён на `flutter_lints` 6 и обновлённые правила анализа.
* Обновлены README и примеры конфигурации Apple Pay / Google Pay.

### Fixed

* Сборка Android под JDK 21: устранена несовместимость Gradle 8.0
  с Java 21.
* Совместимость сканера карт с AGP 8+: `credit_card_scanner` заменён
  на поддерживаемый `card_scanner`.
* Устранён конфликт `win32` с Dart 3.13 при сборке.
* Безопасное извлечение статуса checkout — пустой или неожиданный ответ
  больше не приводит к падению.
* Добавлено разрешение `INTERNET` в основной AndroidManifest.

### Removed

* Готовый UI и реализация хранилища из ядра SDK — перенесены в пример.
* Устаревшие экраны и виджеты SDK, дублировавшие UI приложения.
* Старые Gradle-файлы Groovy DSL и неиспользуемые настройки сборки.
* Пакет `credit_card_scanner` и устаревшие транзитивные зависимости.
