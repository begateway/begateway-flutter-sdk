import 'package:begateway_flutter_sdk/begateway_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    final appState = AppStateScope.of(context, listen: false);
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // обновить полосу загрузки.
          },
          onPageStarted: (String url) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith((appState.resultUrl))) {
              appState.setIsShowWebview(false);
              fetchPayCheck(appState);
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse(appState.urlLink),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Это оверлей поверх активной страницы оплаты (см. Begateway).
    // Material вместо Scaffold: второй Scaffold в дереве не нужен —
    // WebView занимает весь экран, а нижняя страница уже имеет свой.
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(
              controller: controller,
            ),
            // Кнопка закрытия: покупатель может выйти с платёжной страницы
            // или 3-D Secure, не завершая оплату. Статус в этом случае не
            // запрашивается — транзакция могла не завершиться.
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    AppStateScope.of(context, listen: false)
                        .setIsShowWebview(false);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
