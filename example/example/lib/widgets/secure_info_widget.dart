import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SecureInfoWidget extends StatefulWidget {
  final String language;

  const SecureInfoWidget({
    Key? key,
    required this.language,
  }) : super(key: key);

  @override
  State<SecureInfoWidget> createState() => _SecureInfoWidgetState();
}

class _SecureInfoWidgetState extends State<SecureInfoWidget> {
  /// Название компании читается из хранилища один раз при появлении
  /// виджета: раньше future создавался в каждой сборке, и FutureBuilder
  /// перезапрашивал значение при каждом ребилде.
  Future<String?>? _nameCompany;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Хранилище приходит из ядра через AppStateScope; listen: false —
    // перечитывать его при каждой смене наследника не нужно.
    _nameCompany ??=
        AppStateScope.of(context, listen: false).storage.getCompanyName();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _nameCompany,
      builder: (context, snapshot) {
        final nameCompany = snapshot.data ?? 'bePaid';

        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/lock.svg',
            ),
            const SizedBox(
              width: 8,
            ),
            RichText(
              text: TextSpan(
                text:
                    '${findTranslation(widget.language, "begateway_secure_info")} ',
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
