import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InAppWebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const InAppWebViewPage({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  WebViewController? _controller;
  int _progress = 0;
  late final bool _supportsEmbeddedWebView;

  @override
  void initState() {
    super.initState();
    _supportsEmbeddedWebView = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    if (_supportsEmbeddedWebView) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              setState(() {
                _progress = progress;
              });
            },
            onNavigationRequest: (NavigationRequest request) {
              final Uri uri = Uri.parse(request.url);
              final bool isHttpOrHttps =
                  uri.scheme == "http" || uri.scheme == "https";

              // Keep all web links inside this in-app WebView.
              return isHttpOrHttps
                  ? NavigationDecision.navigate
                  : NavigationDecision.prevent;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsEmbeddedWebView) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 44),
                const SizedBox(height: 12),
                const Text(
                  "In-app web view is supported on Android/iOS for this project.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await launchUrl(
                      Uri.parse(widget.url),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: const Text("Open in Browser"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          if (_progress < 100) LinearProgressIndicator(value: _progress / 100),
          Expanded(child: WebViewWidget(controller: _controller!)),
        ],
      ),
    );
  }
}
