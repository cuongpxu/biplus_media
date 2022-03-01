import 'package:biplus_media/src/pages/audio_playing/view/audio_playing_page.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'audio_query.dart';
class OfflinePlayHelper extends StatelessWidget {
  final String id;
  const OfflinePlayHelper({Key? key, required this.id}) : super(key: key);

  Future<List> playOfflineSong(String id) async {
    final OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
    await offlineAudioQuery.requestPermission();

    final List<SongModel> songs = await offlineAudioQuery.getSongs();
    final int index = songs.indexWhere((i) => i.id.toString() == id);

    return [index, songs];
  }

  @override
  Widget build(BuildContext context) {
    playOfflineSong(id).then((value) {
      Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => AudioPlayingPage(
            songsList: value[1] as List<SongModel>,
            index: value[0] as int,
            offline: true,
            fromDownloads: false,
            recommend: false,
            fromMiniPlayer: false,
          ),
        ),
      );
    });
    return Container();
  }
}