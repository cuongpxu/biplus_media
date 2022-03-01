import 'package:biplus_media/src/pages/audio_listing/view/audio_listing_page.dart';
import 'package:biplus_media/src/pages/audio_playing/view/audio_playing_page.dart';
import 'package:flutter/material.dart';
import 'package:biplus_audio/biplus_radio.dart';


class SongUrlHelper extends StatelessWidget {
  final String token;
  final String type;
  const SongUrlHelper({Key? key, required this.token, required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SaavnAPI().getSongFromToken(token, type).then((value) {
      if (type == 'song') {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => AudioPlayingPage(
              songsList: value['songs'] as List,
              index: 0,
              offline: false,
              fromDownloads: false,
              recommend: true,
              fromMiniPlayer: false,
            ),
          ),
        );
      }
      if (type == 'album' || type == 'playlist') {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => AudioListingPage(
              listItem: value,
            ),
          ),
        );
      }
    });
    return Container();
  }
}