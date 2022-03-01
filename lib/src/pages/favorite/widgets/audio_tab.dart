import 'package:biplus_media/src/pages/audio_playing/view/audio_playing_page.dart';
import 'package:biplus_media/src/widgets/download_button.dart';
import 'package:biplus_media/src/widgets/empty_screen.dart';
import 'package:biplus_media/src/widgets/playlist_head.dart';
import 'package:biplus_media/src/widgets/song_tile_trailing_menu.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SongsTab extends StatefulWidget {
  final List songs;
  final String playlistName;
  final Function(Map item) onDelete;
  const SongsTab({
    Key? key,
    required this.songs,
    required this.onDelete,
    required this.playlistName,
  }) : super(key: key);

  @override
  State<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends State<SongsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return (widget.songs.isEmpty)
        ? emptyScreen(
      context,
      3,
      AppLocalizations.of(context)!.nothingTo,
      15.0,
      AppLocalizations.of(context)!.showHere,
      50,
      AppLocalizations.of(context)!.addSomething,
      23.0,
    )
        : Column(
      children: [
        PlaylistHead(
          songsList: widget.songs,
          offline: false,
          fromDownloads: false,
          recommend: false,
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 10),
            shrinkWrap: true,
            itemCount: widget.songs.length,
            itemExtent: 70.0,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      errorWidget: (context, _, __) => const Image(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          'assets/cover.jpg',
                        ),
                      ),
                      imageUrl: widget.songs[index]['image']
                          .toString()
                          .replaceAll('http:', 'https:'),
                      placeholder: (context, url) => const Image(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          'assets/cover.jpg',
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (_, __, ___) => AudioPlayingPage(
                        songsList: widget.songs,
                        index: index,
                        offline: false,
                        fromMiniPlayer: false,
                        fromDownloads: false,
                        recommend: false,
                      ),
                    ),
                  );
                },
                title: Text(
                  '${widget.songs[index]['title']}',
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${widget.songs[index]['artist'] ?? 'Unknown'} - ${widget.songs[index]['album'] ?? 'Unknown'}',
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DownloadButton(
                      data: widget.songs[index] as Map,
                      icon: 'download',
                    ),
                    SongTileTrailingMenu(
                      data: widget.songs[index] as Map,
                      isPlaylist: true,
                      deleteLiked: widget.onDelete,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}