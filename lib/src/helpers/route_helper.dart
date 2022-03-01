import 'package:biplus_media/src/helpers/offline_play_helper.dart';
import 'package:biplus_media/src/helpers/song_url_helper.dart';
import 'package:flutter/material.dart';

class RouteHelper {
  Route? handleRoute(String? url) {
    final List<String> paths = url?.replaceAll('?', '/').split('/') ?? [];
    if (paths.isNotEmpty &&
        paths.length > 3 &&
        (paths[1] == 'song' || paths[1] == 'album' || paths[1] == 'featured') &&
        paths[3].trim() != '') {
      return PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => SongUrlHelper(
          token: paths[3],
          type: paths[1] == 'featured' ? 'playlist' : paths[1],
        ),
      );
    } else {
      if (int.tryParse(paths.last) != null) {
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => OfflinePlayHelper(
            id: paths.last,
          ),
        );
      }
    }
    return null;
  }
}
