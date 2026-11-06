import 'package:flutter/widgets.dart';

import 'app_state.dart';

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context, {bool listen = true}) {
    final AppStateScope? scope = listen
        ? context.dependOnInheritedWidgetOfExactType<AppStateScope>()
        : context.getInheritedWidgetOfExactType<AppStateScope>();

    return scope?.notifier ?? AppState.empty();
  }
}
