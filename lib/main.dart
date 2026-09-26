import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'app_data.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Created once here, not in build() — build() can re-run (e.g. when
  // DevicePreview switches device), and a field initializer only runs
  // once per State object, so the task list survives that.
  final AppData _appData = AppData();

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

      home: HomeScreen(appData: _appData),
    );
  }
}
