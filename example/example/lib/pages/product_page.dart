import 'package:flutter/material.dart';

/// Экран товара — точка входа в демо.
///
/// Сам по себе возвращает Scaffold: выше по дереву уже есть MaterialApp,
/// поэтому второй MaterialApp/Scaffold не создаётся.
class ProductPage extends StatelessWidget {
  const ProductPage({
    super.key,
    required this.onBuy,
    this.paymentStatus,
  });

  /// Статус последнего checkout. `null` — оплата ещё не завершалась.
  final String? paymentStatus;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your app'),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: _ProductStatus(status: paymentStatus),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: _BuyNowBar(onBuy: onBuy),
      ),
    );
  }
}

class _ProductStatus extends StatelessWidget {
  const _ProductStatus({this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final text = status == null ? 'YOUR PRODUCT 42.99\$' : 'Status: $status';

    return Text(
      text,
      style: const TextStyle(fontSize: 24),
      textAlign: TextAlign.center,
    );
  }
}

class _BuyNowBar extends StatelessWidget {
  const _BuyNowBar({required this.onBuy});

  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onBuy,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.orange),
          ),
          child: const Text('Buy Now'),
        ),
      ),
    );
  }
}
