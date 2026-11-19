import 'package:flutter/material.dart';

import 'pages/checkout_flow.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Единственный MaterialApp приложения. Страницы оплаты получают
    // Scaffold внутри себя, поэтому оборачивать их ещё одним Scaffold
    // или MaterialApp не нужно.
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CheckoutFlow(),
    );
  }
}
