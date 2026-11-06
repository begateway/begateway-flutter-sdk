import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DeleteModalBottomSheet extends StatelessWidget {
  final String svgAsset;
  final String text;
  final String token;
  final Function(String) removeCard;

  const DeleteModalBottomSheet(
      {super.key,
      required this.svgAsset,
      required this.text,
      required this.token,
      required this.removeCard});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    return Container(
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
          Text(
            findTranslation(
                appState.config.language.toString(), "want_delete_card"),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF000000),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(svgAsset),
              const SizedBox(
                width: 16,
              ),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.blue[700], // цвет фона
              ),
              onPressed: () {
                removeCard(token);
                Navigator.of(context).pop();
              },
              child: Text(
                findTranslation(appState.config.language.toString(), "ok"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
