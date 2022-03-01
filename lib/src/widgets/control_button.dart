import 'package:audio_service/audio_service.dart';
import 'package:biplus_audio/biplus_radio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'download_button.dart';
import 'favorite_button.dart';

class ControlButtons extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final bool shuffle;
  final bool miniplayer;
  final List buttons;
  final Color? dominantColor;

  const ControlButtons(

      this.audioHandler, {
        Key? key,
        this.shuffle = false,
        this.miniplayer = false,
        this.dominantColor,
        this.buttons = const ['Previous', 'Play/Pause', 'Next'],
      }) : super (key: key);

  @override
  Widget build(BuildContext context) {
    final MediaItem mediaItem = audioHandler.mediaItem.value!;
    final bool online = mediaItem.extras!['url'].toString().startsWith('http');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: getListWidgetFromButtonText(mediaItem, online),
    );
  }

  List<Widget> getListWidgetFromButtonText(MediaItem mediaItem, bool online) {
    return buttons.map((e) {
      switch (e) {
        case 'Like':
          return !online
              ? const SizedBox()
              : FavoriteButton(
            mediaItem: mediaItem,
            size: 22.0,
          );
        case 'Previous':
          return StreamBuilder<QueueState>(
            stream: audioHandler.queueState,
            builder: (context, snapshot) {
              final queueState = snapshot.data;
              return IconButton(
                icon: const Icon(Icons.skip_previous_rounded),
                iconSize: miniplayer ? 24.0 : 45.0,
                tooltip: AppLocalizations.of(context)!.skipPrevious,
                color: Theme.of(context).iconTheme.color,
                onPressed: queueState?.hasPrevious ?? true
                    ? audioHandler.skipToPrevious
                    : null,
              );
            },
          );
        case 'Play/Pause':
          return SizedBox(
            height: miniplayer ? 40.0 : 65.0,
            width: miniplayer ? 40.0 : 65.0,
            child: StreamBuilder<PlaybackState>(
              stream: audioHandler.playbackState,
              builder: (context, snapshot) {
                final playbackState = snapshot.data;
                final processingState = playbackState?.processingState;
                final playing = playbackState?.playing ?? true;
                return Stack(
                  children: [
                    if (processingState == AudioProcessingState.loading ||
                        processingState == AudioProcessingState.buffering)
                      Center(
                        child: SizedBox(
                          height: miniplayer ? 40.0 : 65.0,
                          width: miniplayer ? 40.0 : 65.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).iconTheme.color!,
                            ),
                          ),
                        ),
                      ),
                    if (miniplayer)
                      Center(
                        child: playing
                            ? IconButton(
                          tooltip: AppLocalizations.of(context)!.pause,
                          onPressed: audioHandler.pause,
                          icon: const Icon(
                            Icons.pause_rounded,
                          ),
                          color: Theme.of(context).iconTheme.color,
                        )
                            : IconButton(
                          tooltip: AppLocalizations.of(context)!.play,
                          onPressed: audioHandler.play,
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                          ),
                          color: Theme.of(context).iconTheme.color,
                        ),
                      )
                    else
                      Center(
                        child: SizedBox(
                          height: 59,
                          width: 59,
                          child: Center(
                            child: playing
                                ? FloatingActionButton(
                              elevation: 10,
                              tooltip:
                              AppLocalizations.of(context)!.pause,
                              backgroundColor: Colors.white,
                              onPressed: audioHandler.pause,
                              child: const Icon(
                                Icons.pause_rounded,
                                size: 40.0,
                                color: Colors.black,
                              ),
                            )
                                : FloatingActionButton(
                              elevation: 10,
                              tooltip:
                              AppLocalizations.of(context)!.play,
                              backgroundColor: Colors.white,
                              onPressed: audioHandler.play,
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 40.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        case 'Next':
          return StreamBuilder<QueueState>(
            stream: audioHandler.queueState,
            builder: (context, snapshot) {
              final queueState = snapshot.data;
              return IconButton(
                icon: const Icon(Icons.skip_next_rounded),
                iconSize: miniplayer ? 24.0 : 45.0,
                tooltip: AppLocalizations.of(context)!.skipNext,
                color: Theme.of(context).iconTheme.color,
                onPressed: queueState?.hasNext ?? true
                    ? audioHandler.skipToNext
                    : null,
              );
            },
          );
        case 'Download':
          return !online
              ? const SizedBox()
              : DownloadButton(
            size: 20.0,
            icon: 'download',
            data: {
              'id': mediaItem.id,
              'artist': mediaItem.artist.toString(),
              'album': mediaItem.album.toString(),
              'image': mediaItem.artUri.toString(),
              'duration': mediaItem.duration?.inSeconds.toString(),
              'title': mediaItem.title,
              'url': mediaItem.extras!['url'].toString(),
              'year': mediaItem.extras!['year'].toString(),
              'language': mediaItem.extras!['language'].toString(),
              'genre': mediaItem.genre?.toString(),
              '320kbps': mediaItem.extras?['320kbps'],
              'has_lyrics': mediaItem.extras?['has_lyrics'],
              'release_date': mediaItem.extras!['release_date'],
              'album_id': mediaItem.extras!['album_id'],
              'subtitle': mediaItem.extras!['subtitle'],
              'perma_url': mediaItem.extras!['perma_url'],
            },
          );
        default:
          // break;
          return const SizedBox();
      }
      // return const SizedBox();
    }).toList();
  }
}