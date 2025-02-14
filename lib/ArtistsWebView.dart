/*
import 'dart:io';
import 'package:contemporaryart/openurl.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class ArtistsWebView extends StatefulWidget {
  const ArtistsWebView({required this.data, Key? key}) : super(key: key);
  final String data;

  @override
  State<ArtistsWebView> createState() => _ArtistsWebViewState();
}

class _ArtistsWebViewState extends State<ArtistsWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data),
      ),
      body: OpenUrl("https://www.mpefm.com/mpefm/jumi_files/artisti1_5.php?comuni=${Uri.encodeComponent(widget.data)}"),
    );
  }
}
*/
