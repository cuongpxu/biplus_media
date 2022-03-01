import 'dart:io';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:biplus_media/src/app/app_bloc_observer.dart';
import 'package:biplus_media/src/app/view/app.dart';
import 'package:biplus_media/src/helpers/audio_service_helper.dart';
import 'package:biplus_media/src/helpers/display_mode_helper.dart';
import 'package:biplus_media/src/models/user_info.dart';
import 'package:biplus_media/src/configs/url_strategy.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';


Future<void> main() async {

  // check if is running on Web
  if (kIsWeb) {
    // initialiaze the facebook javascript SDK
    FacebookAuth.i.webInitialize(
      appId: "642084610575266", //<-- YOUR APP_ID
      cookie: true,
      xfbml: true,
      version: "v12.0",
    );
    usePathUrlStrategy();
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: const FirebaseOptions(
        apiKey: "AIzaSyA-onmG2bSo9NNF3SYMbSM0o8zYAzv6VPA",
        authDomain: "biplus-media.firebaseapp.com",
        projectId: "biplus-media",
        storageBucket: "biplus-media.appspot.com",
        messagingSenderId: "985851315257",
        appId: "1:985851315257:web:fe5ca3f52c70e9a532b9e8",
        measurementId: "G-C5EXZBSGQ5"),
  );
  await initialize();
  initializeNotification();
  final UserInfo? userInfo = await Hive.box('settings').get('user', defaultValue: null);
  final user = userInfo == null ? User.empty : userInfo.user;
  final authenticationRepository = AuthenticationRepository(currentUser: user);
  await authenticationRepository.user.first;

  BlocOverrides.runZoned(
    () => runApp(App(authenticationRepository: authenticationRepository)),
    blocObserver: AppBlocObserver(),
  );
}

initializeNotification() {
  AwesomeNotifications().initialize(
    'resource://drawable/res_notification_app_icon',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        defaultColor: Colors.teal,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        channelDescription: '',
      ),
      NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Scheduled Notifications',
        defaultColor: Colors.teal,
        locked: true,
        importance: NotificationImportance.High,
        soundSource: 'resource://raw/res_custom_notification',
        channelDescription: '',
      ),
    ],
  );
}

initialize() async {
  Paint.enableDithering = true;

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await Hive.initFlutter('BiplusMedia');
  } else {
    await Hive.initFlutter();
  }
  Hive.registerAdapter(UserInfoAdapter());
  Hive.registerAdapter(UserAdapter());
  await openHiveBox('settings');
  await openHiveBox('downloads');
  await openHiveBox('Favorite Songs');
  await openHiveBox('cache', limit: true);
  if (!kIsWeb && Platform.isAndroid) {
    DisplayModeHelper.setOptimalDisplayMode();
  }
  await AudioServiceHelper.startService();
}

Future<void> openHiveBox(String boxName, {bool limit = false}) async {
  final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dirPath = dir.path;
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      dbFile = File('$dirPath/BiplusMedia/$boxName.hive');
      lockFile = File('$dirPath/BiplusMedia/$boxName.lock');
    }
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox(boxName);
    throw 'Failed to open $boxName Box\nError: $error';
  });
  // clear box if it grows large
  if (limit && box.length > 500) {
    box.clear();
  }
}
