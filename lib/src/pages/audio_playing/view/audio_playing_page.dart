import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:biplus_audio/biplus_radio.dart';
import 'package:biplus_media/src/configs/biplus_media_theme.dart';
import 'package:biplus_media/src/helpers/dominant_color.dart';
import 'package:biplus_media/src/pages/audio_listing/view/audio_listing_page.dart';
import 'package:biplus_media/src/pages/audio_playing/widgets/art_work.dart';
import 'package:biplus_media/src/pages/audio_playing/widgets/name_n_controls.dart';
import 'package:biplus_media/src/widgets/add_playlist.dart';
import 'package:biplus_media/src/widgets/equalizer.dart';
import 'package:biplus_media/src/widgets/popup.dart';
import 'package:biplus_media/src/widgets/snackbar.dart';
import 'package:biplus_media/src/widgets/textinput_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AudioPlayingPage extends StatefulWidget {
  final List songsList;
  final bool fromMiniPlayer;
  final bool? offline;
  final int index;
  final bool recommend;
  final bool fromDownloads;

  const AudioPlayingPage({
    Key? key,
    required this.index,
    required this.songsList,
    required this.fromMiniPlayer,
    required this.offline,
    required this.recommend,
    required this.fromDownloads,
  }) : super(key: key);

  @override
  _AudioPlayingPageState createState() => _AudioPlayingPageState();
}

class _AudioPlayingPageState extends State<AudioPlayingPage> {
  bool fromMiniPlayer = false;
  String preferredQuality = Hive.box('settings')
      .get('streamingQuality', defaultValue: '96 kbps')
      .toString();
  String repeatMode =
  Hive.box('settings').get('repeatMode', defaultValue: 'None').toString();
  bool enforceRepeat =
  Hive.box('settings').get('enforceRepeat', defaultValue: false) as bool;
  bool useImageColor =
  Hive.box('settings').get('useImageColor', defaultValue: true) as bool;
  bool getLyricsOnline =
  Hive.box('settings').get('getLyricsOnline', defaultValue: true) as bool;
  bool useFullScreenGradient = Hive.box('settings')
      .get('useFullScreenGradient', defaultValue: false) as bool;
  List<MediaItem> globalQueue = [];
  int globalIndex = 0;
  List response = [];
  bool offline = false;
  bool fromDownloads = false;
  String defaultCover = '';
  final BiplusMediaTheme currentTheme = GetIt.I<BiplusMediaTheme>();
  final ValueNotifier<Color?> gradientColor =
  ValueNotifier<Color?>(GetIt.I<BiplusMediaTheme>().playGradientColor);
  final PanelController _panelController = PanelController();
  final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  void sleepTimer(int time) {
    audioHandler.customAction('sleepTimer', {'time': time});
  }

  void sleepCounter(int count) {
    audioHandler.customAction('sleepCounter', {'count': count});
  }

  late Duration _time;

  Future<void> main() async {
    await Hive.openBox('Favorite Songs');
  }

  @override
  void initState() {
    super.initState();
    main();
    response = widget.songsList;
    globalIndex = widget.index;
    if (globalIndex == -1) {
      globalIndex = 0;
    }
    fromDownloads = widget.fromDownloads;
    if (widget.offline == null) {
      if (audioHandler.mediaItem.value?.extras!['url'].startsWith('http') as bool) {
        offline = false;
      } else {
        offline = true;
      }
    } else {
      offline = widget.offline!;
    }

    fromMiniPlayer = widget.fromMiniPlayer;
    if (!fromMiniPlayer) {
      // if (Theme.of(context).platform != TargetPlatform.android) {
      //   // Don't know why but it fixes the playback issue with iOS Side
      //   audioHandler.stop();
      // }
      if (offline) {
        fromDownloads
            ? setDownValues(response)
            : (Platform.isWindows || Platform.isLinux)
            ? setOffDesktopValues(response)
            : setOffValues(response);
      } else {
        setValues(response);
        updateNplay();
      }
    }
  }

  Future<MediaItem> setTags(SongModel response, Directory tempDir) async {
    String playTitle = response.title;
    playTitle == ''
        ? playTitle = response.displayNameWOExt
        : playTitle = response.title;
    String playArtist = response.artist!;
    playArtist == '<unknown>'
        ? playArtist = 'Unknown'
        : playArtist = response.artist!;

    final String playAlbum = response.album!;
    final int playDuration = response.duration ?? 180000;
    final String imagePath = '${tempDir.path}/${response.displayNameWOExt}.jpg';

    final MediaItem tempDict = MediaItem(
      id: response.id.toString(),
      album: playAlbum,
      duration: Duration(milliseconds: playDuration),
      title: playTitle.split('(')[0],
      artist: playArtist,
      genre: response.genre,
      artUri: Uri.file(imagePath),
      extras: {
        'url': response.data,
        'date_added': response.dateAdded,
        'date_modified': response.dateModified,
        'size': response.size,
        'year': response.getMap['year'],
      },
    );
    return tempDict;
  }

  void setOffDesktopValues(List response) {
    getTemporaryDirectory().then((tempDir) async {
      final File file = File('${tempDir.path}/cover.jpg');
      if (!await file.exists()) {
        final byteData = await rootBundle.load('assets/cover.jpg');
        await file.writeAsBytes(
          byteData.buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      }
      globalQueue.addAll(
        response.map(
              (song) => MediaItem(
            id: song['id'].toString(),
            album: song['album'].toString(),
            artist: song['artist'].toString(),
            duration: Duration(
              seconds: int.parse(
                (song['duration'] == null || song['duration'] == 'null')
                    ? '180'
                    : song['duration'].toString(),
              ),
            ),
            title: song['title'].toString(),
            artUri: Uri.file(file.path),
            genre: song['genre'].toString(),
            extras: {
              'url': song['path'].toString(),
              'subtitle': song['subtitle'],
              'quality': song['quality'],
            },
          ),
        ),
      );
      updateNplay();
    });
  }

  void setOffValues(List response) {
    getTemporaryDirectory().then((tempDir) async {
      final File file = File('${tempDir.path}/cover.jpg');
      if (!await file.exists()) {
        final byteData = await rootBundle.load('assets/cover.jpg');
        await file.writeAsBytes(
          byteData.buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      }
      for (int i = 0; i < response.length; i++) {
        globalQueue.add(
          await setTags(response[i] as SongModel, tempDir),
        );
      }
      updateNplay();
    });
  }

  void setDownValues(List response) {
    globalQueue.addAll(
      response.map(
            (song) => MediaItemConverter.downMapToMediaItem(song as Map),
      ),
    );
    updateNplay();
  }

  void setValues(List response) async{
    // globalQueue.addAll(
    //   response.map(
    //         (song) => MediaItemConverter.mapToMediaItem(
    //       song as Map,
    //       autoplay: widget.recommend,
    //     ),
    //   ),
    // );
    globalQueue.addAll(
      response.map(
            (song) {
              if (song is MediaItem){
                return song;
              } else {
                return MediaItemConverter.mapToMediaItem(
                  song as Map,
                  autoplay: widget.recommend,
                );
              }
            }
      ),
    );
  }

  Future<void> updateNplay() async {
    await audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    await audioHandler.updateQueue(globalQueue);
    await audioHandler.skipToQueueItem(globalIndex);
    await audioHandler.play();
    if (enforceRepeat) {
      switch (repeatMode) {
        case 'None':
          audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
          break;
        case 'All':
          audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
          break;
        case 'One':
          audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
          break;
        default:
          break;
      }
    } else {
      audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
      Hive.box('settings').put('repeatMode', 'None');
    }
  }

  String format(String msg) {
    return '${msg[0].toUpperCase()}${msg.substring(1)}: '.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    BuildContext? scaffoldContext;

    return Dismissible(
      direction: DismissDirection.down,
      background: Container(color: Colors.transparent),
      key: const Key('audioPlayingPage'),
      onDismissed: (direction) {
        Navigator.pop(context);
      },
      child: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, snapshot) {
          final MediaItem? mediaItem = snapshot.data;
          if (mediaItem == null) return const SizedBox();
          mediaItem.artUri.toString().startsWith('file')
              ? getColors(
            FileImage(
              File(
                mediaItem.artUri!.toFilePath(),
              ),
            ),
          ).then((value) => gradientColor.value = value)
              : getColors(
            CachedNetworkImageProvider(
              Uri.decodeFull(mediaItem.artUri.toString())
            ),
          ).then((value) => gradientColor.value = value);
          return ValueListenableBuilder(
            valueListenable: gradientColor,
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.expand_more_rounded),
                    color: Theme.of(context).colorScheme.primary,
                    tooltip: AppLocalizations.of(context)!.back,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: Image.asset(
                        'assets/lyrics.png',
                      ),
                      color: Theme.of(context).colorScheme.primary,
                      tooltip: AppLocalizations.of(context)!.lyrics,
                      onPressed: () => cardKey.currentState!.toggleCard(),
                    ),
                    if (!offline)
                      IconButton(
                        icon: const Icon(Icons.share_rounded),
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: AppLocalizations.of(context)!.share,
                        onPressed: () {
                          Share.share(
                            mediaItem.extras!['perma_url'].toString(),
                          );
                        },
                      ),
                    PopupMenuButton(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                      onSelected: (int? value) {
                        if (value == 10) {
                          final Map details =
                          MediaItemConverter.mediaItemtoMap(mediaItem);
                          details['duration'] =
                          '${int.parse(details["duration"].toString()) ~/ 60}:${int.parse(details["duration"].toString()) % 60}';
                          // style: Theme.of(context).textTheme.caption,
                          if (mediaItem.extras?['size'] != null) {
                            details.addEntries([
                              MapEntry(
                                'date_modified',
                                DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(
                                    mediaItem.extras!['date_modified']
                                        .toString(),
                                  ) * 1000,
                                ).toString().split('.').first,
                              ),
                              MapEntry(
                                'size',
                                '${((mediaItem.extras!['size'] as int) / (1024 * 1024)).toStringAsFixed(2)} MB',
                              ),
                            ]);
                          }
                          PopupDialog().showPopup(
                            context: context,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(25.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: details.keys.map((e) {
                                  return RichText(
                                    text: TextSpan(
                                      text: format(
                                        e.toString(),
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: details[e].toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }
                        if (value == 5) {
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
                        if (value == 4) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const Equalizer();
                            },
                          );
                        }
                        if (value == 1) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.sleepTimer,
                                  style: TextStyle(
                                    color:
                                    Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(10.0),
                                children: [
                                  ListTile(
                                    title: Text(
                                      AppLocalizations.of(context)!.sleepDur,
                                    ),
                                    subtitle: Text(
                                      AppLocalizations.of(context)!.sleepDurSub,
                                    ),
                                    dense: true,
                                    onTap: () {
                                      Navigator.pop(context);
                                      setTimer(
                                        context,
                                        scaffoldContext,
                                      );
                                    },
                                  ),
                                  ListTile(
                                    title: Text(
                                      AppLocalizations.of(context)!.sleepAfter,
                                    ),
                                    subtitle: Text(
                                      AppLocalizations.of(context)!
                                          .sleepAfterSub,
                                    ),
                                    dense: true,
                                    isThreeLine: true,
                                    onTap: () {
                                      Navigator.pop(context);
                                      setCounter();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        if (value == 0) {
                          AddToPlaylist().addToPlaylist(context, mediaItem);
                        }
                      },
                      itemBuilder: (context) => offline
                          ? [
                        if (mediaItem.extras?['album_id'] != null)
                          PopupMenuItem(
                            value: 5,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.album_rounded,
                                  color:
                                  Theme.of(context).iconTheme.color,
                                ),
                                const SizedBox(width: 10.0),
                                Text(
                                  AppLocalizations.of(context)!.viewAlbum,
                                ),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.timer,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              const SizedBox(width: 10.0),
                              Text(
                                AppLocalizations.of(context)!.sleepTimer,
                              ),
                            ],
                          ),
                        ),
                        if (Hive.box('settings').get('supportEq', defaultValue: false) as bool)
                          PopupMenuItem(
                            value: 4,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.equalizer_rounded,
                                  color:
                                  Theme.of(context).iconTheme.color,
                                ),
                                const SizedBox(width: 10.0),
                                Text(
                                  AppLocalizations.of(context)!.equalizer,
                                ),
                              ],
                            ),
                          ),
                        // PopupMenuItem(
                        //   value: 10,
                        //   child: Row(
                        //     children: [
                        //       Icon(
                        //         Icons.info_rounded,
                        //         color: Theme.of(context).iconTheme.color,
                        //       ),
                        //       const SizedBox(width: 10.0),
                        //       Text(
                        //         AppLocalizations.of(context)!.songInfo,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ]
                          : [
                        if (mediaItem.extras?['album_id'] != null)
                          PopupMenuItem(
                            value: 5,
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
                        // PopupMenuItem(
                        //   value: 0,
                        //   child: Row(
                        //     children: [
                        //       Icon(
                        //         Icons.playlist_add_rounded,
                        //         color: Theme.of(context).iconTheme.color,
                        //       ),
                        //       const SizedBox(width: 10.0),
                        //       Text(
                        //         AppLocalizations.of(context)!.addToPlaylist,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.timer,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              const SizedBox(width: 10.0),
                              Text(
                                AppLocalizations.of(context)!.sleepTimer,
                              ),
                            ],
                          ),
                        ),
                        if (Hive.box('settings').get('supportEq', defaultValue: false) as bool)
                          PopupMenuItem(
                            value: 4,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.equalizer_rounded,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                const SizedBox(width: 10.0),
                                Text(
                                  AppLocalizations.of(context)!.equalizer,
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  ],
                ),
                body: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    if (constraints.maxWidth > constraints.maxHeight) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Artwork
                          ArtWork(
                            cardKey: cardKey,
                            mediaItem: mediaItem,
                            width: min(
                              constraints.maxHeight / 0.9,
                              constraints.maxWidth / 1.8,
                            ),
                            audioHandler: audioHandler,
                            offline: offline,
                            getLyricsOnline: getLyricsOnline,
                          ),

                          // title and controls
                          NameNControls(
                            mediaItem: mediaItem,
                            offline: offline,
                            width: constraints.maxWidth / 2,
                            height: constraints.maxHeight,
                            panelController: _panelController,
                            audioHandler: audioHandler,
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        // Artwork
                        ArtWork(
                          cardKey: cardKey,
                          mediaItem: mediaItem,
                          width: constraints.maxWidth,
                          audioHandler: audioHandler,
                          offline: offline,
                          getLyricsOnline: getLyricsOnline,
                        ),

                        // title and controls
                        NameNControls(
                          mediaItem: mediaItem,
                          offline: offline,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight -
                              (constraints.maxWidth * 0.85),
                          panelController: _panelController,
                          audioHandler: audioHandler,
                        ),
                      ],
                    );
                  },
                ),
                // }
              ),
            ),
            builder: (BuildContext context, Color? value, Widget? child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: !useImageColor
                        ? Alignment.topLeft
                        : Alignment.topCenter,
                    end: !useImageColor
                        ? Alignment.bottomRight
                        : !useFullScreenGradient
                        ? Alignment.center
                        : Alignment.bottomCenter,
                    colors: !useImageColor
                        ? Theme.of(context).brightness == Brightness.dark
                        ? currentTheme.getBackGradient()
                        : [
                          const Color(0xfff5f9ff),
                          Colors.white,
                        ] : Theme.of(context).brightness == Brightness.dark
                        ? [
                          value ?? Colors.grey[900]!,
                          currentTheme.getPlayGradient(),
                        ] : [
                          value ?? const Color(0xfff5f9ff),
                          Colors.white,
                        ],
                  ),
                ),
                child: child,
              );
            },
          );
          // );
        },
      ),
    );
  }

  Future<dynamic> setTimer(BuildContext context, BuildContext? scaffoldContext) {
    return showDialog(context: context, builder: (context) {
        return SimpleDialog(
          title: Center(
            child: Text(
              AppLocalizations.of(context)!.selectDur,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          children: [
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    primaryColor: Theme.of(context).colorScheme.secondary,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    onTimerDurationChanged: (value) {
                      _time = value;
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    sleepTimer(0);
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    primary:
                    Theme.of(context).colorScheme.secondary == Colors.white
                        ? Colors.black
                        : Colors.white,
                  ),
                  onPressed: () {
                    sleepTimer(_time.inMinutes);
                    Navigator.pop(context);
                    ShowSnackBar().showSnackBar(
                      context,
                      '${AppLocalizations.of(context)!.sleepTimerSetFor} ${_time.inMinutes} ${AppLocalizations.of(context)!.minutes}',
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> setCounter() async {
    await showTextInputDialog(
      context: context,
      title: AppLocalizations.of(context)!.enterSongsCount,
      initialText: '',
      keyboardType: TextInputType.number,
      onSubmitted: (String value) {
        sleepCounter(
          int.parse(value),
        );
        Navigator.pop(context);
        ShowSnackBar().showSnackBar(
          context,
          '${AppLocalizations.of(context)!.sleepTimerSetFor} $value ${AppLocalizations.of(context)!.songs}',
        );
      },
    );
  }
}
