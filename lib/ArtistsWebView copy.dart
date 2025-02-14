import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PressReleaseWebview extends StatefulWidget {
  const PressReleaseWebview({required this.data, Key? key}) : super(key: key);
  final String data;

  @override
  State<PressReleaseWebview> createState() => _PressReleaseWebviewState();
}

class _PressReleaseWebviewState extends State<PressReleaseWebview> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Press release'.tr,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
