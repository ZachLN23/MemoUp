import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'app_data.dart';
import 'home_screen.dart';
import 'notification_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved tasks/settings before the first frame, so Home never
  // flashes empty and the alarm check sees real data.
  final appData = await AppData.load();
  NotificationService.liveData = appData;
  await NotificationService.init();
  // Make sure the phone's scheduled alarms match what was saved.
  unawaited(NotificationService.syncAll(appData));

  runApp(
    // DevicePreview draws a phone frame around the app. It's only needed
    // on the web, where the live link is opened on a desktop browser and
    // a phone layout at full width looks broken. On a real phone it is
    // switched off so the app fills the screen.
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => MyApp(appData: appData),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appData});

  /// Created once in main() and shared by every screen.
  final AppData appData;

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

      home: HomeScreen(appData: appData),
    );
  }
}
