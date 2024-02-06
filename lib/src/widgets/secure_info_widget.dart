import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../localization/find_translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureInfoWidget extends StatelessWidget {
  final String language;
  final VoidCallback onTap;

  const SecureInfoWidget({
    Key? key,
    required this.language,
    required this.onTap,
  }) : super(key: key);

  Future<String?> getNameCompanyFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nameCompany');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getNameCompanyFromLocalStorage(), 
      builder: (context, snapshot) {
        String nameCompany = snapshot.data ?? 'bePaid';

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
                    text: nameCompany,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
