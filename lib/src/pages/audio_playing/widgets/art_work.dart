import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:biplus_audio/biplus_radio.dart';
import 'package:biplus_media/src/helpers/lyric_helper.dart';
import 'package:biplus_media/src/widgets/add_playlist.dart';
import 'package:biplus_media/src/widgets/copy_clipboard.dart';
import 'package:biplus_media/src/widgets/empty_screen.dart';
import 'package:biplus_media/src/widgets/seek_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class ArtWork extends StatefulWidget {
  final GlobalKey<FlipCardState> cardKey;
  final MediaItem mediaItem;
  final bool offline;
  final bool getLyricsOnline;
  final double width;
  final AudioPlayerHandler audioHandler;

  const ArtWork({Key? key, required this.cardKey,
    required this.mediaItem,
    required this.width,
    this.offline = false,
    required this.getLyricsOnline,
    required this.audioHandler}) : super(key: key);

  @override
  _ArtWorkState createState() => _ArtWorkState();
}

class _ArtWorkState extends State<ArtWork> {
  final ValueNotifier<bool> dragging = ValueNotifier<bool>(false);
  final ValueNotifier<bool> done = ValueNotifier<bool>(false);
  Map lyrics = {'id': '', 'lyrics': ''};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.width * 0.85,
      width: widget.width * 0.85,
      child: Hero(
        tag: 'currentArtwork',
        child: FlipCard(
          key: widget.cardKey,
          flipOnTouch: false,
          onFlipDone: (value) {
            if (lyrics['id'] != widget.mediaItem.id ||
                (!value && lyrics['lyrics'] == '' && !done.value)) {
              done.value = false;
              if (widget.mediaItem.extras!.containsKey('description')
                  && widget.mediaItem.extras!['description'] != null){
                lyrics['lyrics'] = widget.mediaItem.extras!['description'];
                lyrics['id'] = widget.mediaItem.id;
                done.value = true;
              } else {
                if (widget.offline) {
                  LyricsHelper.getOffLyrics(
                    widget.mediaItem.extras!['url'].toString(),
                  ).then((value) {
                    if (value == '' && widget.getLyricsOnline) {
                      LyricsHelper.getLyrics(
                        id: widget.mediaItem.id,
                        saavnHas:
                        widget.mediaItem.extras?['has_lyrics'] == 'true',
                        title: widget.mediaItem.title,
                        artist: widget.mediaItem.artist.toString(),
                      ).then((value) {
                        lyrics['lyrics'] = value;
                        lyrics['id'] = widget.mediaItem.id;
                        done.value = true;
                      });
                    } else {
                      lyrics['lyrics'] = value;
                      lyrics['id'] = widget.mediaItem.id;
                      done.value = true;
                    }
                  });
                } else {
                  LyricsHelper.getLyrics(
                    id: widget.mediaItem.id,
                    saavnHas: widget.mediaItem.extras?['has_lyrics'] == 'true',
                    title: widget.mediaItem.title,
                    artist: widget.mediaItem.artist.toString(),
                  ).then((value) {
                    lyrics['lyrics'] = value;
                    lyrics['id'] = widget.mediaItem.id;
                    done.value = true;
                  });
                }
              }
            }
          },
          back: GestureDetector(
            onTap: () => widget.cardKey.currentState!.toggleCard(),
            onDoubleTap: () => widget.cardKey.currentState!.toggleCard(),
            child: Stack(
              children: [
                ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                        Colors.black,
                        Colors.black,
                        Colors.transparent
                      ],
                    ).createShader(
                      Rect.fromLTRB(0, 0, rect.width, rect.height),
                    );
                  },
                  blendMode: BlendMode.dstIn,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: 55,
                        horizontal: 10,
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: done,
                        child: const CircularProgressIndicator(),
                        builder: (BuildContext context, bool value, Widget? child) {
                          return value
                              ? lyrics['lyrics'] == ''
                              ? emptyScreen(context, 0, ':( ', 100.0,
                            AppLocalizations.of(context)!.lyrics, 60.0,
                            AppLocalizations.of(context)!.notAvailable, 20.0,
                            useWhite: true,
                          ) : SelectableText(
                            lyrics['lyrics'].toString(),
                            textAlign: TextAlign.center,
                          ) : child!;
                        },
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Card(
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Theme.of(context).cardColor.withOpacity(0.6),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      tooltip: AppLocalizations.of(context)!.copy,
                      onPressed: () {
                        Feedback.forLongPress(context);
                        copyToClipboard(
                          context: context,
                          text: lyrics['lyrics'].toString(),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                      color:
                      Theme.of(context).iconTheme.color!.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          front: StreamBuilder<QueueState>(
            stream: widget.audioHandler.queueState,
            builder: (context, snapshot) {
              final queueState = snapshot.data ?? QueueState.empty;

              final bool enabled = Hive.box('settings')
                  .get('enableGesture', defaultValue: true) as bool;
              return GestureDetector(
                onTap: !enabled
                    ? null
                    : () {
                  widget.audioHandler.playbackState.value.playing
                      ? widget.audioHandler.pause()
                      : widget.audioHandler.play();
                },
                onDoubleTap: !enabled
                    ? null
                    : () {
                  Feedback.forLongPress(context);
                  widget.cardKey.currentState!.toggleCard();
                },
                onHorizontalDragEnd: !enabled
                    ? null
                    : (DragEndDetails details) {
                  if ((details.primaryVelocity ?? 0) > 100) {
                    if (queueState.hasPrevious) {
                      widget.audioHandler.skipToPrevious();
                    }
                  }

                  if ((details.primaryVelocity ?? 0) < -100) {
                    if (queueState.hasNext) {
                      widget.audioHandler.skipToNext();
                    }
                  }
                },
                onLongPress: !enabled
                    ? null
                    : () {
                  if (!widget.offline) {
                    Feedback.forLongPress(context);
                    AddToPlaylist()
                        .addToPlaylist(context, widget.mediaItem);
                  }
                },
                onVerticalDragStart: !enabled
                    ? null
                    : (_) {
                  dragging.value = true;
                },
                onVerticalDragEnd: !enabled
                    ? null
                    : (_) {
                  dragging.value = false;
                },
                onVerticalDragUpdate: !enabled
                    ? null
                    : (DragUpdateDetails details) {
                  if (details.delta.dy != 0.0) {
                    double volume = widget.audioHandler.volume.value;
                    volume -= details.delta.dy / 150;
                    if (volume < 0) {
                      volume = 0;
                    }
                    if (volume > 1.0) {
                      volume = 1.0;
                    }
                    widget.audioHandler.setVolume(volume);
                  }
                },
                child: Stack(
                  children: [
                    Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                      widget.mediaItem.artUri.toString().startsWith('file')
                          ? Image(
                        fit: BoxFit.cover,
                        height: widget.width * 0.85,
                        width: widget.width * 0.85,
                        gaplessPlayback: true,
                        image: FileImage(
                          File(
                            widget.mediaItem.artUri!.toFilePath(),
                          ),
                        ),
                      )
                          : CachedNetworkImage(
                        fit: BoxFit.cover,
                        errorWidget: (BuildContext context, _, __) =>
                        const Image(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/cover.jpg'),
                        ),
                        placeholder: (BuildContext context, _) =>
                        const Image(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/cover.jpg'),
                        ),
                        imageUrl: Uri.decodeFull(widget.mediaItem.artUri.toString()),
                        height: widget.width * 0.85,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: dragging,
                      child: StreamBuilder<double>(
                        stream: widget.audioHandler.volume,
                        builder: (context, snapshot) {
                          final double volumeValue = snapshot.data ?? 1.0;
                          return Center(
                            child: SizedBox(
                              width: 60.0,
                              height: widget.width * 0.7,
                              child: Card(
                                color: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.fitHeight,
                                        child: RotatedBox(
                                          quarterTurns: -1,
                                          child: SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                              thumbShape:
                                              HiddenThumbComponentShape(),
                                              activeTrackColor:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              inactiveTrackColor:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.4),
                                              trackShape:
                                              const RoundedRectSliderTrackShape(),
                                            ),
                                            child: ExcludeSemantics(
                                              child: Slider(
                                                value: widget
                                                    .audioHandler.volume.value,
                                                onChanged: (_) {},
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 20.0,
                                      ),
                                      child: Icon(
                                        volumeValue == 0
                                            ? Icons.volume_off_rounded
                                            : volumeValue > 0.6
                                            ? Icons.volume_up_rounded
                                            : Icons.volume_down_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      builder: (
                          BuildContext context,
                          bool value,
                          Widget? child,
                          ) {
                        return Visibility(
                          visible: value,
                          child: child!,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

