import 'package:flutter/material.dart';

class Nfc extends StatelessWidget {
  const Nfc({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.nfc),
        color: const Color(0xFF929DA9),
        onPressed: () {
        });
  }
}
