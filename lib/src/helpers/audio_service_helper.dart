
import 'package:biplus_audio/biplus_radio.dart';
import 'package:biplus_media/src/configs/biplus_media_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:audio_service/audio_service.dart';

class AudioServiceHelper {
  static Future<void> startService() async {
    final AudioPlayerHandler audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandlerImpl(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.biplus.media',
        androidNotificationChannelName: 'BiplusMedia',
        androidNotificationOngoing: true,
        androidNotificationIcon: 'drawable/ic_stat_music_note',
        androidShowNotificationBadge: true,
        // androidStopForegroundOnPause: Hive.box('settings')
        // .get('stopServiceOnPause', defaultValue: true) as bool,
        notificationColor: Colors.grey[900],
      ),
    );
    GetIt.I.registerSingleton<AudioPlayerHandler>(audioHandler);
    GetIt.I.registerSingleton<BiplusMediaTheme>(BiplusMediaTheme());
  }
}