import 'package:biplus_media/src/widgets/collage.dart';
import 'package:biplus_media/src/widgets/empty_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'favorite_audio_listing_page.dart';

class AlbumsTab extends StatefulWidget {
  final Map<String, List> albums;
  final List sortedAlbumKeysList;
  // final String? tempPath;
  final String type;
  final bool offline;
  const AlbumsTab({
    Key? key,
    required this.albums,
    required this.offline,
    required this.sortedAlbumKeysList,
    required this.type,
    // this.tempPath,
  }) : super(key: key);

  @override
  State<AlbumsTab> createState() => _AlbumsTabState();
}

class _AlbumsTabState extends State<AlbumsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.sortedAlbumKeysList.isEmpty
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
        : ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 10.0),
      shrinkWrap: true,
      itemExtent: 70.0,
      itemCount: widget.sortedAlbumKeysList.length,
      itemBuilder: (context, index) {
        final List imageList = widget
            .albums[widget.sortedAlbumKeysList[index]]!.length >= 4
            ? widget.albums[widget.sortedAlbumKeysList[index]]!.sublist(0, 4)
            : widget.albums[widget.sortedAlbumKeysList[index]]!.sublist(0,
          widget.albums[widget.sortedAlbumKeysList[index]]!.length
        );
        return ListTile(
          leading: (widget.offline)
              ? OfflineCollage(
            imageList: imageList,
            showGrid: widget.type == 'genre',
            placeholderImage: widget.type == 'artist'
                ? 'assets/artist.png'
                : 'assets/album.png',
          )
              : Collage(
            imageList: imageList,
            showGrid: widget.type == 'genre',
            placeholderImage: widget.type == 'artist'
                ? 'assets/artist.png'
                : 'assets/album.png',
          ),
          title: Text(
            '${widget.sortedAlbumKeysList[index]}',
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            widget.albums[widget.sortedAlbumKeysList[index]]!.length == 1
                ? '${widget.albums[widget.sortedAlbumKeysList[index]]!.length} ${AppLocalizations.of(context)!.song}'
                : '${widget.albums[widget.sortedAlbumKeysList[index]]!.length} ${AppLocalizations.of(context)!.songs}',
            style: TextStyle(
              color: Theme.of(context).textTheme.caption!.color,
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) => FavoriteAudioListingPage(
                  data: widget.albums[widget.sortedAlbumKeysList[index]]!,
                  offline: widget.offline,
                ),
              ),
            );
          },
        );
      },
    );
  }
}