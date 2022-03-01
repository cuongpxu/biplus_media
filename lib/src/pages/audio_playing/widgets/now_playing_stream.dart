import 'dart:io';

import 'package:biplus_audio/biplus_radio.dart';
import 'package:biplus_media/src/widgets/download_button.dart';
import 'package:biplus_media/src/widgets/favorite_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../api/biplus_media_api.dart';
import '../../../app/bloc/app_bloc.dart';
import '../../../widgets/snackbar.dart';

class NowPlayingStream extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final ScrollController? scrollController;
  final bool head;

  const NowPlayingStream({
    Key? key,
    required this.audioHandler,
    this.scrollController,
    this.head = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QueueState>(
      stream: audioHandler.queueState,
      builder: (context, snapshot) {
        final queueState = snapshot.data ?? QueueState.empty;
        final queue = queueState.queue;
        return ReorderableListView.builder(
          header: SizedBox(
            height: head ? 50 : 0,
          ),
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) {
              newIndex--;
            }
            audioHandler.moveQueueItem(oldIndex, newIndex);
          },
          scrollController: scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 10),
          shrinkWrap: true,
          itemCount: queue.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: ValueKey(queue[index].id),
              direction: index == queueState.queueIndex
                  ? DismissDirection.none
                  : DismissDirection.horizontal,
              background: Container(
                color: Colors.red,
                child: const Icon(Icons.cancel),
              ),
              onDismissed: (dir) {
                audioHandler.removeQueueItemAt(index);
              },
              child: ListTileTheme(
                selectedColor: Theme.of(context).colorScheme.secondary,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.only(left: 16.0, right: 10.0),
                  selected: index == queueState.queueIndex,
                  trailing: index == queueState.queueIndex
                      ? IconButton(
                          icon: const Icon(
                            Icons.bar_chart_rounded,
                          ),
                          tooltip: AppLocalizations.of(context)!.playing,
                          onPressed: () {},
                        )
                      : queue[index]
                              .extras!['url']
                              .toString()
                              .startsWith('http')
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (context.read<AppBloc>().state.status ==
                                    AppStatus.authenticated)
                                  FavoriteButton(
                                    mediaItem: queue[index],
                                    onLikeChange: () async {
                                      bool addFavorite = await BiplusMediaAPI()
                                          .addFavorite(
                                              mediaId:
                                                  int.parse(queue[index].id),
                                              isFavourite: !queue[index]
                                                  .extras?['is_favourite']);
                                      if (addFavorite) {
                                        ShowSnackBar().showSnackBar(
                                          context,
                                          queue[index].extras?['is_favourite']
                                              ? AppLocalizations.of(context)!
                                                  .addedToFav
                                              : AppLocalizations.of(context)!
                                                  .removedFromFav,
                                        );
                                      }
                                    },
                                  ),
                                DownloadButton(
                                  icon: 'download',
                                  size: 25.0,
                                  data: {
                                    'id': queue[index].id,
                                    'artist': queue[index].artist.toString(),
                                    'album': queue[index].album.toString(),
                                    'image': queue[index].artUri.toString(),
                                    'duration': queue[index]
                                        .duration!
                                        .inSeconds
                                        .toString(),
                                    'title': queue[index].title,
                                    'url':
                                        queue[index].extras?['url'].toString(),
                                    'year':
                                        queue[index].extras?['year'].toString(),
                                    'language': queue[index]
                                        .extras?['language']
                                        .toString(),
                                    'genre': queue[index].genre?.toString(),
                                    '320kbps': queue[index].extras?['320kbps'],
                                    'has_lyrics':
                                        queue[index].extras?['has_lyrics'],
                                    'release_date':
                                        queue[index].extras?['release_date'],
                                    'album_id':
                                        queue[index].extras?['album_id'],
                                    'subtitle':
                                        queue[index].extras?['subtitle'],
                                    'perma_url':
                                        queue[index].extras?['perma_url'],
                                  },
                                )
                              ],
                            )
                          : const SizedBox(),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (queue[index].extras?['addedByAutoplay'] as bool? ??
                          false)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    AppLocalizations.of(context)!.addedBy,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 5.0,
                                    ),
                                  ),
                                ),
                                RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    AppLocalizations.of(context)!.autoplay,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 8.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                          ],
                        ),
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: (queue[index].artUri == null)
                            ? const SizedBox(
                                height: 50.0,
                                width: 50.0,
                                child: Image(
                                  image: AssetImage('assets/cover.jpg'),
                                ),
                              )
                            : SizedBox(
                                height: 50.0,
                                width: 50.0,
                                child: queue[index]
                                        .artUri
                                        .toString()
                                        .startsWith('file:')
                                    ? Image(
                                        fit: BoxFit.cover,
                                        image: FileImage(
                                          File(
                                            queue[index].artUri!.toFilePath(),
                                          ),
                                        ),
                                      )
                                    : CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        errorWidget:
                                            (BuildContext context, _, __) =>
                                                const Image(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                            'assets/cover.jpg',
                                          ),
                                        ),
                                        placeholder:
                                            (BuildContext context, _) =>
                                                const Image(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                            'assets/cover.jpg',
                                          ),
                                        ),
                                        imageUrl:
                                            queue[index].artUri.toString(),
                                      ),
                              ),
                      ),
                    ],
                  ),
                  title: Text(
                    queue[index].title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: index == queueState.queueIndex
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    queue[index].artist!,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    audioHandler.skipToQueueItem(index);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
