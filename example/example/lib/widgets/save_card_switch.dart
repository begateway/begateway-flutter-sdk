import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter/cupertino.dart';

class SaveCardSwitchRow extends StatelessWidget {
  const SaveCardSwitchRow({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    return Column(
      children: [
        Row(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: appState.isSaveCard,
              builder: (context, isSaveCard, _) => CupertinoSwitch(
                value: isSaveCard,
                inactiveTrackColor: const Color(0xFF929DA9),
                activeTrackColor: const Color(0xFF0065FF),
                onChanged: appState.setIsSaveCard,
              ),
            ),
            const SizedBox(width: 10),
            Text(findTranslation(
                appState.config.language.toString(), "begateway_savecard")),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
