
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveHelper {
  static Future<void> openHiveBox(String boxName, {bool limit = false}) async {
    final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String dirPath = dir.path;
      File dbFile = File('$dirPath/$boxName.hive');
      File lockFile = File('$dirPath/$boxName.lock');
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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
}