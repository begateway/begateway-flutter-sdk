import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/pages/choose_pay.dart';

void main() {
  testWidgets('ChoosePay не создаёт вложенный MaterialApp', (tester) async {
    await tester.pumpWidget(
      AppStateScope(
        notifier: AppState.empty(),
        child: const MaterialApp(
          home: ChoosePay(
            savedCards: [],
            lang: 'en',
            removeCard: _ignoreRemove,
          ),
        ),
      ),
    );
    await tester.pump();

    // Раньше ChoosePay оборачивался во второй MaterialApp.
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('удаление карты подтверждение уходит в колбэк ядра',
      (tester) async {
    String? removed;
    await tester.pumpWidget(
      AppStateScope(
        notifier: AppState.empty(),
        child: MaterialApp(
          home: ChoosePay(
            savedCards: [
              SaveCardModel(
                  brand: 'VISA', lastFourNumbers: '1111', saveToken: 't1'),
            ],
            lang: 'en',
            removeCard: (token) => removed = token,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('****1111'), findsOneWidget);

    // Иконка удаления → подтверждение в bottom sheet → колбэк ядра.
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // Кнопка подтверждения в шторке (на странице тоже есть кнопка).
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(removed, 't1');
  });
}

void _ignoreRemove(String token) {}
