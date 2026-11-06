import 'package:pay/pay.dart';

/// Разбор строки конфигурации платёжной кнопки (Apple/Google Pay)
/// с кэшем: строки конфигураций неизменяемы, поэтому JSON парсится
/// один раз, а не на каждой сборке кнопки.
///
/// Раньше кэш жил в `PaymentConfig` ядра — сейчас ядро не зависит
/// от пакета `pay`, разбор отдан приложению.
PaymentConfiguration parsePaymentConfiguration(String rawConfiguration) =>
    _cache.putIfAbsent(rawConfiguration,
        () => PaymentConfiguration.fromJsonString(rawConfiguration));

final _cache = <String, PaymentConfiguration>{};
