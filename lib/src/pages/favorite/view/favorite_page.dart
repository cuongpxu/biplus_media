import 'package:biplus_media/src/helpers/song_helper.dart';
import 'package:biplus_media/src/pages/favorite/widgets/audio_tab.dart';
import 'package:biplus_media/src/pages/top_chart/widgets/custom_physics.dart';
import 'package:biplus_media/src/widgets/data_search.dart';
import 'package:biplus_media/src/widgets/download_button.dart';
import 'package:biplus_media/src/widgets/gradient_containers.dart';
import 'package:biplus_media/src/widgets/mini_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class FavoritePage extends StatefulWidget {
  final String playlistName;
  final String? showName;

  const FavoritePage({Key? key, required this.playlistName, required this.showName}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> with SingleTickerProviderStateMixin {
  Box? favoriteBox;
  bool added = false;
  // String? tempPath = Hive.box('settings').get('tempDirPath')?.toString();
  List _songs = [];
  final Map<String, List<Map>> _albums = {};
  final Map<String, List<Map>> _artists = {};
  final Map<String, List<Map>> _genres = {};
  List _sortedAlbumKeysList = [];
  List _sortedArtistKeysList = [];
  List _sortedGenreKeysList = [];
  TabController? _tcontroller;
  // int currentIndex = 0;
  int sortValue = Hive.box('settings').get('sortValue', defaultValue: 1) as int;
  int orderValue =
  Hive.box('settings').get('orderValue', defaultValue: 1) as int;
  int albumSortValue =
  Hive.box('settings').get('albumSortValue', defaultValue: 2) as int;

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  void initState() {
    _tcontroller = TabController(length: 1, vsync: this);
    // if (tempPath == null) {
    //   getTemporaryDirectory().then((value) {
    //     Hive.box('settings').put('tempDirPath', value.path);
    //   });
    // }
    // _tcontroller!.addListener(changeTitle);
    getLiked();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tcontroller!.dispose();
  }

  // void changeTitle() {
  //   setState(() {
  //     currentIndex = _tcontroller!.index;
  //   });
  // }

  void getLiked() {
    favoriteBox = Hive.box(widget.playlistName);
    _songs = favoriteBox?.values.toList() ?? [];
    SongHelper().addSongsCount(
      widget.playlistName,
      _songs.length,
      _songs.length >= 4
          ? _songs.sublist(0, 4)
          : _songs.sublist(0, _songs.length),
    );
    setArtistAlbum();
  }

  void setArtistAlbum() {
    for (final element in _songs) {
      if (_albums.containsKey(element['album'])) {
        final List<Map> tempAlbum = _albums[element['album']]!;
        tempAlbum.add(element as Map);
        _albums.addEntries([MapEntry(element['album'].toString(), tempAlbum)]);
      } else {
        _albums.addEntries([
          MapEntry(element['album'].toString(), [element as Map])
        ]);
      }

      if (_artists.containsKey(element['artist'])) {
        final List<Map> tempArtist = _artists[element['artist']]!;
        tempArtist.add(element);
        _artists
            .addEntries([MapEntry(element['artist'].toString(), tempArtist)]);
      } else {
        _artists.addEntries([
          MapEntry(element['artist'].toString(), [element])
        ]);
      }

      if (_genres.containsKey(element['genre'])) {
        final List<Map> tempGenre = _genres[element['genre']]!;
        tempGenre.add(element);
        _genres.addEntries([MapEntry(element['genre'].toString(), tempGenre)]);
      } else {
        _genres.addEntries([
          MapEntry(element['genre'].toString(), [element])
        ]);
      }
    }

    sortSongs(sortVal: sortValue, order: orderValue);

    _sortedAlbumKeysList = _albums.keys.toList();
    _sortedArtistKeysList = _artists.keys.toList();
    _sortedGenreKeysList = _genres.keys.toList();

    sortAlbums();

    added = true;
    setState(() {});
  }

  void sortSongs({required int sortVal, required int order}) {
    switch (sortVal) {
      case 0:
        _songs.sort(
              (a, b) => a['title']
              .toString()
              .toUpperCase()
              .compareTo(b['title'].toString().toUpperCase()),
        );
        break;
      case 1:
        _songs.sort(
              (a, b) => a['dateAdded']
              .toString()
              .toUpperCase()
              .compareTo(b['dateAdded'].toString().toUpperCase()),
        );
        break;
      case 2:
        _songs.sort(
              (a, b) => a['album']
              .toString()
              .toUpperCase()
              .compareTo(b['album'].toString().toUpperCase()),
        );
        break;
      case 3:
        _songs.sort(
              (a, b) => a['artist']
              .toString()
              .toUpperCase()
              .compareTo(b['artist'].toString().toUpperCase()),
        );
        break;
      case 4:
        _songs.sort(
              (a, b) => a['duration']
              .toString()
              .toUpperCase()
              .compareTo(b['duration'].toString().toUpperCase()),
        );
        break;
      default:
        _songs.sort(
              (b, a) => a['dateAdded']
              .toString()
              .toUpperCase()
              .compareTo(b['dateAdded'].toString().toUpperCase()),
        );
        break;
    }

    if (order == 1) {
      _songs = _songs.reversed.toList();
    }
  }

  void sortAlbums() {
    if (albumSortValue == 0) {
      _sortedAlbumKeysList.sort(
            (a, b) =>
            a.toString().toUpperCase().compareTo(b.toString().toUpperCase()),
      );
      _sortedArtistKeysList.sort(
            (a, b) =>
            a.toString().toUpperCase().compareTo(b.toString().toUpperCase()),
      );
      _sortedGenreKeysList.sort(
            (a, b) =>
            a.toString().toUpperCase().compareTo(b.toString().toUpperCase()),
      );
    }
    if (albumSortValue == 1) {
      _sortedAlbumKeysList.sort(
            (b, a) =>
            a.toString().toUpperCase().compareTo(b.toString().toUpperCase()),
      );
      _sortedArtistKeysList.sort(
            (b, a) =>
            a.toString().toUpperCase().compareTo(b.toString().toUpperCase()),
      );
      _sortedGenreKeysList.sort(
            (b, a) =>
            a.toString().toUpperCase().compareTo(b.toString().toUpperCase()),
      );
    }
    if (albumSortValue == 2) {
      _sortedAlbumKeysList
          .sort((b, a) => _albums[a]!.length.compareTo(_albums[b]!.length));
      _sortedArtistKeysList
          .sort((b, a) => _artists[a]!.length.compareTo(_artists[b]!.length));
      _sortedGenreKeysList
          .sort((b, a) => _genres[a]!.length.compareTo(_genres[b]!.length));
    }
    if (albumSortValue == 3) {
      _sortedAlbumKeysList
          .sort((a, b) => _albums[a]!.length.compareTo(_albums[b]!.length));
      _sortedArtistKeysList
          .sort((a, b) => _artists[a]!.length.compareTo(_artists[b]!.length));
      _sortedGenreKeysList
          .sort((a, b) => _genres[a]!.length.compareTo(_genres[b]!.length));
    }
    if (albumSortValue == 4) {
      _sortedAlbumKeysList.shuffle();
      _sortedArtistKeysList.shuffle();
      _sortedGenreKeysList.shuffle();
    }
  }

  void deleteLiked(Map song) {
    setState(() {
      favoriteBox!.delete(song['id']);
      if (_albums[song['album']]!.length == 1) {
        _sortedAlbumKeysList.remove(song['album']);
      }
      _albums[song['album']]!.remove(song);

      if (_artists[song['artist']]!.length == 1) {
        _sortedArtistKeysList.remove(song['artist']);
      }
      _artists[song['artist']]!.remove(song);

      if (_genres[song['genre']]!.length == 1) {
        _sortedGenreKeysList.remove(song['genre']);
      }
      _genres[song['genre']]!.remove(song);

      _songs.remove(song);
      SongHelper().addSongsCount(
        widget.playlistName,
        _songs.length,
        _songs.length >= 4
            ? _songs.sublist(0, 4)
            : _songs.sublist(0, _songs.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: 4,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: Text(
                    widget.showName == null
                        ? widget.playlistName[0].toUpperCase() +
                        widget.playlistName.substring(1)
                        : widget.showName![0].toUpperCase() +
                        widget.showName!.substring(1),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  centerTitle: true,
                  backgroundColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.secondary,
                  elevation: 0,
                  bottom: TabBar(
                    controller: _tcontroller,
                    tabs: [
                      Tab(
                        text: AppLocalizations.of(context)!.songs,
                      ),
                    ],
                  ),
                  actions: [
                    if (_songs.isNotEmpty)
                      MultiDownloadButton(
                        data: _songs,
                        playlistName: widget.showName == null
                            ? widget.playlistName[0].toUpperCase() +
                            widget.playlistName.substring(1)
                            : widget.showName![0].toUpperCase() +
                            widget.showName!.substring(1),
                      ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.search),
                      tooltip: AppLocalizations.of(context)!.search,
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: DownloadsSearch(data: _songs),
                        );
                      },
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.sort_rounded),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      onSelected:
                      // (currentIndex == 0) ?
                          (int value) {
                        if (value < 5) {
                          sortValue = value;
                          Hive.box('settings').put('sortValue', value);
                        } else {
                          orderValue = value - 5;
                          Hive.box('settings').put('orderValue', orderValue);
                        }
                        sortSongs(sortVal: sortValue, order: orderValue);
                        setState(() {});
                      },
                      // : (int value) {
                      //     albumSortValue = value;
                      //     Hive.box('settings').put('albumSortValue', value);
                      //     sortAlbums();
                      //     setState(() {});
                      //   },
                      itemBuilder:
                      // (currentIndex == 0)
                      // ?
                          (context) {
                        final List<String> sortTypes = [
                          AppLocalizations.of(context)!.displayName,
                          AppLocalizations.of(context)!.dateAdded,
                          AppLocalizations.of(context)!.album,
                          AppLocalizations.of(context)!.artist,
                          AppLocalizations.of(context)!.duration,
                        ];
                        final List<String> orderTypes = [
                          AppLocalizations.of(context)!.inc,
                          AppLocalizations.of(context)!.dec,
                        ];
                        final menuList = <PopupMenuEntry<int>>[];
                        menuList.addAll(
                          sortTypes
                              .map(
                                (e) => PopupMenuItem(
                              value: sortTypes.indexOf(e),
                              child: Row(
                                children: [
                                  if (sortValue == sortTypes.indexOf(e))
                                    Icon(
                                      Icons.check_rounded,
                                      color: Theme.of(context).brightness ==
                                          Brightness.dark
                                          ? Colors.white
                                          : Colors.grey[700],
                                    )
                                  else
                                    const SizedBox(),
                                  const SizedBox(width: 10),
                                  Text(
                                    e,
                                  ),
                                ],
                              ),
                            ),
                          )
                              .toList(),
                        );
                        menuList.add(
                          const PopupMenuDivider(
                            height: 10,
                          ),
                        );
                        menuList.addAll(
                          orderTypes
                              .map(
                                (e) => PopupMenuItem(
                              value:
                              sortTypes.length + orderTypes.indexOf(e),
                              child: Row(
                                children: [
                                  if (orderValue == orderTypes.indexOf(e))
                                    Icon(
                                      Icons.check_rounded,
                                      color: Theme.of(context).brightness ==
                                          Brightness.dark
                                          ? Colors.white
                                          : Colors.grey[700],
                                    )
                                  else
                                    const SizedBox(),
                                  const SizedBox(width: 10),
                                  Text(
                                    e,
                                  ),
                                ],
                              ),
                            ),
                          )
                              .toList(),
                        );
                        return menuList;
                        //       : (context) => [
                        //             PopupMenuItem(
                        //               value: 0,
                        //               child: Row(
                        //                 children: [
                        //                   if (albumSortValue == 0)
                        //                     Icon(
                        //                       Icons.check_rounded,
                        //                       color: Theme.of(context).brightness ==
                        //                               Brightness.dark
                        //                           ? Colors.white
                        //                           : Colors.grey[700],
                        //                     )
                        //                   else
                        //                     const SizedBox(),
                        //                   const SizedBox(width: 10),
                        //                   Text(
                        //                     AppLocalizations.of(context)!.az,
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //             PopupMenuItem(
                        //               value: 1,
                        //               child: Row(
                        //                 children: [
                        //                   if (albumSortValue == 1)
                        //                     Icon(
                        //                       Icons.check_rounded,
                        //                       color: Theme.of(context).brightness ==
                        //                               Brightness.dark
                        //                           ? Colors.white
                        //                           : Colors.grey[700],
                        //                     )
                        //                   else
                        //                     const SizedBox(),
                        //                   const SizedBox(width: 10),
                        //                   Text(
                        //                     AppLocalizations.of(context)!.za,
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //             PopupMenuItem(
                        //               value: 2,
                        //               child: Row(
                        //                 children: [
                        //                   if (albumSortValue == 2)
                        //                     Icon(
                        //                       Icons.check_rounded,
                        //                       color: Theme.of(context).brightness ==
                        //                               Brightness.dark
                        //                           ? Colors.white
                        //                           : Colors.grey[700],
                        //                     )
                        //                   else
                        //                     const SizedBox(),
                        //                   const SizedBox(width: 10),
                        //                   Text(
                        //                     AppLocalizations.of(context)!.tenToOne,
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //             PopupMenuItem(
                        //               value: 3,
                        //               child: Row(
                        //                 children: [
                        //                   if (albumSortValue == 3)
                        //                     Icon(
                        //                       Icons.check_rounded,
                        //                       color: Theme.of(context).brightness ==
                        //                               Brightness.dark
                        //                           ? Colors.white
                        //                           : Colors.grey[700],
                        //                     )
                        //                   else
                        //                     const SizedBox(),
                        //                   const SizedBox(width: 10),
                        //                   Text(
                        //                     AppLocalizations.of(context)!.oneToTen,
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //             PopupMenuItem(
                        //               value: 4,
                        //               child: Row(
                        //                 children: [
                        //                   if (albumSortValue == 4)
                        //                     Icon(
                        //                       Icons.shuffle_rounded,
                        //                       color: Theme.of(context).brightness ==
                        //                               Brightness.dark
                        //                           ? Colors.white
                        //                           : Colors.grey[700],
                        //                     )
                        //                   else
                        //                     const SizedBox(),
                        //                   const SizedBox(width: 10),
                        //                   Text(
                        //                     AppLocalizations.of(context)!.shuffle,
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ],
                        // ),
                      },
                    ),
                  ],
                ),
                body: !added
                    ? SizedBox(
                  child: Center(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width / 8,
                      width: MediaQuery.of(context).size.width / 8,
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                )
                    : TabBarView(
                  physics: const CustomPhysics(),
                  controller: _tcontroller,
                  children: [
                    SongsTab(
                      songs: _songs,
                      onDelete: (Map item) {
                        deleteLiked(item);
                      },
                      playlistName: widget.playlistName,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }
}
