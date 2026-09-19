import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'theme.dart';

void main() {
  runApp(
    // DevicePreview draws a phone frame around the app, so it's judged at the
    // size it was designed for instead of stretched across a laptop window.
    //
    // Left ON in the deployed build on purpose: a live link is opened on a
    // desktop browser, and a phone layout at full desktop width looks broken
    // when it's not. The toolbar also lets a visitor switch device and
    // orientation.
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoUp',
      debugShowCheckedModeBanner: false,

      // These two lines are what make the DevicePreview toolbar actually
      // change the app. Keep them.
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      // Design system lives in theme.dart: a dark-only ColorScheme and
      // TextTheme built from the worksheet palette, not a seed color.
      theme: appTheme,

      home: const HomeScreen(),
    );
  }
}
