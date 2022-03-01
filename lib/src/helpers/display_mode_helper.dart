

import 'package:flutter_displaymode/flutter_displaymode.dart';

class DisplayModeHelper {
  static Future<void> setOptimalDisplayMode() async {
    final List<DisplayMode> supported = await FlutterDisplayMode.supported;
    final DisplayMode active = await FlutterDisplayMode.active;

    final List<DisplayMode> sameResolution = supported
        .where(
          (DisplayMode m) => m.width == active.width && m.height == active.height,
    )
        .toList()
      ..sort(
            (DisplayMode a, DisplayMode b) => b.refreshRate.compareTo(a.refreshRate),
      );

    final DisplayMode mostOptimalMode =
    sameResolution.isNotEmpty ? sameResolution.first : active;

    await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
  }
}