import 'package:begateway_flutter_sdk/src/api/fetch_pay_with_token.dart';
import 'package:begateway_flutter_sdk/src/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class PayModalBottomSheet extends StatelessWidget {
  const PayModalBottomSheet(
      {super.key, required this.link, required this.text, required this.token});
  final String link;
  final String text;
  final String token;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'packages/begateway_flutter_sdk/assets/svg/${link.toUpperCase()}.svg',
                ),
                const SizedBox(
                  width: 16,
                ),
                Text(
                  '****$text',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.blue[700], // Background color
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  appState.setSaveCardToken(token);
                  appState.setIsSaveCard(false);
                  fetchPayWithToken(appState, '', '', '', appState.holder);
                  debugPrint(appState.customerCountry);
                },
                child: Text(
                  appState.buttonText.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
