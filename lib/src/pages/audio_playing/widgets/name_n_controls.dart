import 'package:audio_service/audio_service.dart';
import 'package:biplus_audio/biplus_radio.dart';
import 'package:biplus_media/src/pages/album_search/view/album_search_page.dart';
import 'package:biplus_media/src/pages/audio_listing/view/audio_listing_page.dart';
import 'package:biplus_media/src/pages/audio_playing/widgets/list_comments.dart';
import 'package:biplus_media/src/widgets/animated_text.dart';
import 'package:biplus_media/src/widgets/control_button.dart';
import 'package:biplus_media/src/widgets/download_button.dart';
import 'package:biplus_media/src/widgets/like_button.dart';
import 'package:biplus_media/src/widgets/seek_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:rxdart/rxdart.dart';

import '../../../api/biplus_media_api.dart';
import '../../../widgets/snackbar.dart';
import 'now_playing_stream.dart';

class NameNControls extends StatelessWidget {
  final MediaItem mediaItem;
  final bool offline;
  final double width;
  final double height;
  final PanelController panelController;
  final AudioPlayerHandler audioHandler;

  const NameNControls({
    Key? key,
    required this.width,
    required this.height,
    required this.mediaItem,
    required this.audioHandler,
    required this.panelController,
    this.offline = false,
  }) : super(key: key);

  Stream<Duration> get _bufferedPositionStream => audioHandler.playbackState
      .map((state) => state.bufferedPosition)
      .distinct();
  Stream<Duration?> get _durationStream =>
      audioHandler.mediaItem.map((item) => item?.duration).distinct();
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        AudioService.position,
        _bufferedPositionStream,
        _durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  @override
  Widget build(BuildContext context) {
    final double titleBoxHeight = height * 0.25;
    final double seekBoxHeight = height > 500 ? height * 0.15 : height * 0.2;
    final double controlBoxHeight = offline
        ? height > 500
            ? height * 0.2
            : height * 0.25
        : (height < 350
            ? height * 0.4
            : height > 500
                ? height * 0.2
                : height * 0.3);
    final double nowplayingBoxHeight =
        height > 500 ? height * 0.35 : height * 0.15;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /// Title and subtitle
              SizedBox(
                height: titleBoxHeight,
                child: PopupMenuButton<int>(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  offset: const Offset(1.0, 0.0),
                  onSelected: (int value) {
                    if (value == 0) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (_, __, ___) => AudioListingPage(
                            listItem: {
                              'type': 'album',
                              'id': mediaItem.extras?['album_id'],
                              'title': mediaItem.album,
                              'image': mediaItem.artUri,
                            },
                          ),
                        ),
                      );
                    }
                    if (value == 5) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (_, __, ___) => AlbumSearchPage(
                            query:
                                mediaItem.artist.toString().split(', ').first,
                            type: 'Artists',
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                    if (mediaItem.extras?['album_id'] != null)
                      PopupMenuItem<int>(
                        value: 0,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.album_rounded,
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              AppLocalizations.of(context)!.viewAlbum,
                            ),
                          ],
                        ),
                      ),
                    if (mediaItem.artist != null)
                      PopupMenuItem<int>(
                        value: 5,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_rounded,
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              AppLocalizations.of(context)!.viewArtist,
                            ),
                          ],
                        ),
                      ),
                  ],
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: titleBoxHeight / 10,
                          ),

                          /// Title container
                          AnimatedText(
                            text: mediaItem.title
                                .split(' (')[0]
                                .split('|')[0]
                                .trim(),
                            pauseAfterRound: const Duration(seconds: 3),
                            showFadingOnlyWhenScrolling: false,
                            fadingEdgeEndFraction: 0.1,
                            fadingEdgeStartFraction: 0.1,
                            startAfter: const Duration(seconds: 2),
                            style: TextStyle(
                              fontSize: titleBoxHeight / 2.75,
                              fontWeight: FontWeight.bold,
                              // color: Theme.of(context).accentColor,
                            ),
                          ),

                          SizedBox(
                            height: titleBoxHeight / 40,
                          ),

                          /// Subtitle container
                          AnimatedText(
                            text: mediaItem.artist ?? "Unknown",
                            pauseAfterRound: const Duration(seconds: 3),
                            showFadingOnlyWhenScrolling: false,
                            fadingEdgeEndFraction: 0.1,
                            fadingEdgeStartFraction: 0.1,
                            startAfter: const Duration(seconds: 2),
                            style: TextStyle(
                              fontSize: titleBoxHeight / 6.75,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// Seekbar starts from here
              SizedBox(
                height: seekBoxHeight,
                width: width * 0.95,
                child: StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data ??
                        PositionData(
                          Duration.zero,
                          Duration.zero,
                          mediaItem.duration ?? Duration.zero,
                        );
                    return SeekBar(
                      width: width,
                      height: height,
                      duration: positionData.duration,
                      position: positionData.position,
                      bufferedPosition: positionData.bufferedPosition,
                      offline: offline,
                      onChangeEnd: (newPosition) {
                        audioHandler.seek(newPosition);
                      },
                      audioHandler: audioHandler,
                    );
                  },
                ),
              ),

              /// Final row starts from here
              SizedBox(
                height: controlBoxHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Center(
                    child: SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 3.0),
                              StreamBuilder<bool>(
                                stream: audioHandler.playbackState
                                    .map(
                                      (state) =>
                                          state.shuffleMode ==
                                          AudioServiceShuffleMode.all,
                                    )
                                    .distinct(),
                                builder: (context, snapshot) {
                                  final shuffleModeEnabled =
                                      snapshot.data ?? false;
                                  return IconButton(
                                    icon: shuffleModeEnabled
                                        ? const Icon(
                                            Icons.shuffle_rounded,
                                          )
                                        : Icon(
                                            Icons.shuffle_rounded,
                                            color:
                                                Theme.of(context).disabledColor,
                                          ),
                                    tooltip:
                                        AppLocalizations.of(context)!.shuffle,
                                    onPressed: () async {
                                      final enable = !shuffleModeEnabled;
                                      await audioHandler.setShuffleMode(
                                        enable
                                            ? AudioServiceShuffleMode.all
                                            : AudioServiceShuffleMode.none,
                                      );
                                    },
                                  );
                                },
                              ),
                              if (!offline)
                                LikeButton(
                                  mediaItem: mediaItem,
                                  size: 25.0,
                                  onLikeChange: () async {
                                    bool liked = await BiplusMediaAPI()
                                        .likeRadio(
                                            mediaId: int.parse(mediaItem.id),
                                            isLike:
                                                !mediaItem.extras?['is_like']);
                                  },
                                )
                            ],
                          ),
                          ControlButtons(audioHandler),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 3.0),
                              StreamBuilder<AudioServiceRepeatMode>(
                                stream: audioHandler.playbackState
                                    .map((state) => state.repeatMode)
                                    .distinct(),
                                builder: (context, snapshot) {
                                  final repeatMode = snapshot.data ??
                                      AudioServiceRepeatMode.none;
                                  const texts = ['None', 'All', 'One'];
                                  final icons = [
                                    Icon(
                                      Icons.repeat_rounded,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    const Icon(
                                      Icons.repeat_rounded,
                                    ),
                                    const Icon(
                                      Icons.repeat_one_rounded,
                                    ),
                                  ];
                                  const cycleModes = [
                                    AudioServiceRepeatMode.none,
                                    AudioServiceRepeatMode.all,
                                    AudioServiceRepeatMode.one,
                                  ];
                                  final index = cycleModes.indexOf(repeatMode);
                                  return IconButton(
                                    icon: icons[index],
                                    tooltip:
                                        'Repeat ${texts[(index + 1) % texts.length]}',
                                    onPressed: () {
                                      Hive.box('settings').put(
                                        'repeatMode',
                                        texts[(index + 1) % texts.length],
                                      );
                                      audioHandler.setRepeatMode(
                                        cycleModes[
                                            (cycleModes.indexOf(repeatMode) +
                                                    1) %
                                                cycleModes.length],
                                      );
                                    },
                                  );
                                },
                              ),
                              if (!offline)
                                DownloadButton(
                                  size: 20.0,
                                  data: {
                                    'id': mediaItem.id,
                                    'artist': mediaItem.artist.toString(),
                                    'album': mediaItem.album.toString(),
                                    'image': mediaItem.artUri.toString(),
                                    'duration': mediaItem.duration?.inSeconds
                                        .toString(),
                                    'title': mediaItem.title,
                                    'url': mediaItem.extras!['url'].toString(),
                                    'year':
                                        mediaItem.extras!['year'].toString(),
                                    'language': mediaItem.extras!['language']
                                        .toString(),
                                    'genre': mediaItem.genre?.toString(),
                                    '320kbps': mediaItem.extras?['320kbps'],
                                    'has_lyrics':
                                        mediaItem.extras?['has_lyrics'],
                                    'release_date':
                                        mediaItem.extras!['release_date'],
                                    'album_id': mediaItem.extras!['album_id'],
                                    'subtitle': mediaItem.extras!['subtitle'],
                                    'perma_url': mediaItem.extras!['perma_url'],
                                  },
                                )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: nowplayingBoxHeight,
              ),
            ],
          ),
          // Now playing
          DefaultTabController(
              length: 2,
              child: SlidingUpPanel(
                minHeight: nowplayingBoxHeight,
                maxHeight: height,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                margin: const EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.zero,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                controller: panelController,
                panelBuilder: (ScrollController scrollController) {
                  return TabBarView(children: [
                    ListComment(mediaId: int.parse(mediaItem.id)),
                    ShaderMask(
                      shaderCallback: (rect) {
                        return const LinearGradient(
                          end: Alignment.topCenter,
                          begin: Alignment.center,
                          colors: [
                            Colors.black,
                            Colors.black,
                            Colors.black,
                            Colors.transparent,
                            Colors.transparent,
                          ],
                        ).createShader(
                          Rect.fromLTRB(0, 0, rect.width, rect.height),
                        );
                      },
                      blendMode: BlendMode.dstIn,
                      child: NowPlayingStream(
                        head: true,
                        audioHandler: audioHandler,
                        scrollController: scrollController,
                      ),
                    )
                  ]);
                },
                header: GestureDetector(
                  onTap: () {
                    if (panelController.isPanelOpen) {
                      panelController.close();
                    } else {
                      if (panelController.panelPosition > 0.9) {
                        panelController.close();
                      } else {
                        panelController.open();
                      }
                    }
                  },
                  onVerticalDragUpdate: (DragUpdateDetails details) {
                    if (details.delta.dy > 0.0) {
                      panelController.animatePanelToPosition(0.0);
                    }
                  },
                  child: Container(
                      height: 50,
                      width: width - 40.0,
                      color: Colors.transparent,
                      child: TabBar(
                        tabs: [
                          Center(
                            child: Text(
                              AppLocalizations.of(context)!.comment,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              AppLocalizations.of(context)!.nowPlaying,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ))
        ],
      ),
    );
  }
}
