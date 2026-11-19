import 'package:flutter/material.dart';

import '../widgets/begateway_checkout.dart';
import 'product_page.dart';

/// Состояние демо-сценария: экран товара ↔ платёжный флоу beGateway.
///
/// Отдельный StatefulWidget, чтобы `MaterialApp` оставался статичным,
/// а перерисовывались только экраны, зависящие от состояния оплаты.
class CheckoutFlow extends StatefulWidget {
  const CheckoutFlow({super.key});

  @override
  State<CheckoutFlow> createState() => _CheckoutFlowState();
}

class _CheckoutFlowState extends State<CheckoutFlow> {
  // ValueNotifier вместо setState: перестраивается только подписавшийся виджет.
  final ValueNotifier<bool> _isBegateway = ValueNotifier<bool>(false);
  final ValueNotifier<Map<String, dynamic>> _answer =
      ValueNotifier<Map<String, dynamic>>(const {});

  void _showBegateway(bool newValue) {
    _isBegateway.value = newValue;
  }

  void _handleAnswer(Map<String, dynamic> answerFromServer) {
    _answer.value = answerFromServer;
    debugPrint('Answer from beGateway: $answerFromServer');
  }

  /// Безопасно достаёт статус из ответа checkout, не падая на пустых данных.
  String? _paymentStatus(Map<String, dynamic> answer) {
    final checkout = answer['checkout'];
    if (checkout is! Map) {
      return null;
    }
    return checkout['status']?.toString();
  }

  @override
  void dispose() {
    _isBegateway.dispose();
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isBegateway,
      builder: (context, isBegateway, _) {
        if (isBegateway) {
          return BegatewayCheckout(
            onShowBegateway: _showBegateway,
            onAnswer: _handleAnswer,
          );
        }

        return ValueListenableBuilder<Map<String, dynamic>>(
          valueListenable: _answer,
          builder: (context, answer, _) => ProductPage(
            paymentStatus: _paymentStatus(answer),
            onBuy: () => _showBegateway(true),
          ),
        );
      },
    );
  }
}
