import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../localization/find_translation.dart';

class SecureInfoWidget extends StatelessWidget {
  final String language;
  final VoidCallback onTap;

  const SecureInfoWidget({super.key, 
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SvgPicture.asset(
          'packages/begateway_flutter_sdk/assets/svg/lock.svg',
        ),
        const SizedBox(
          width: 8,
        ),
        RichText(
          text: TextSpan(
            text: '${findTranslation(language, "begateway_secure_info")} ',
            style: const TextStyle(color: Color(0xFF929DA9)),
            children: <TextSpan>[
              TextSpan(
                text: 'bePaid',
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()..onTap = onTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
