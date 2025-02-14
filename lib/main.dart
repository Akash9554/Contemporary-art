
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

import 'HomeScreen.dart';
import 'language.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Languages(),
      // locale: Languages.locale.values.toList()[0],
      fallbackLocale: Languages.locale.values.toList()[0],

      locale: window.locale,
      title: 'Business Finder'.tr,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
