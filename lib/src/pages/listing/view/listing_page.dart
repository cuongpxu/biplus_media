import 'package:biplus_audio/biplus_radio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:biplus_media/src/pages/audio_playing/view/audio_playing_page.dart';
import 'package:biplus_media/src/widgets/copy_clipboard.dart';
import 'package:biplus_media/src/widgets/download_button.dart';
import 'package:biplus_media/src/widgets/empty_screen.dart';
import 'package:biplus_media/src/widgets/gradient_containers.dart';
import 'package:biplus_media/src/widgets/favorite_button.dart';
import 'package:biplus_media/src/widgets/mini_player.dart';
import 'package:biplus_media/src/widgets/song_tile_trailing_menu.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../api/biplus_media_api.dart';
import '../../../app/bloc/app_bloc.dart';
import '../../../helpers/biplus_media_item_converter.dart';
import '../../../models/biplus_media_item.dart';
import '../../../widgets/snackbar.dart';

enum ListingType {
  newest,
  mostLike,
  mostView,
  favorite,
  mc
}

class ListingPage extends StatefulWidget {

  const ListingPage({Key? key, required this.type, required this.title}) : super(key: key);
  final String? title;
  final ListingType type;

  @override
  _ListingPageState createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  bool _fetched = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<MediaItem> mediaItems = [];

  @override
  void initState() {
    super.initState();
    getRadioData();
  }

  getRadioData() async{
    List<BiplusMediaItem> medias;
    final appState = context.read<AppBloc>().state;
    bool isAuth = appState.status == AppStatus.authenticated;
    switch (widget.type) {
      case ListingType.mc:
        medias = await BiplusMediaAPI().getRadioSongs();
        break;
      case ListingType.favorite:
        medias = await BiplusMediaAPI().getFavoriteRadio();
        break;
      default:
        medias = await BiplusMediaAPI().getRadioSongs(isAuth: isAuth, sort: widget.type, offset: mediaItems.length);
        break;
    }
    setState(() {
      mediaItems.addAll(BiplusMediaItemConverter().convertToMediaItemList(medias));
      _fetched = !_fetched;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onRefresh() async {
    setState(() {
      _fetched = !_fetched;
      mediaItems.clear();
      getRadioData();
      // _isLoading = !_isLoading;
      // _isLoadMore = true;
    });
  }

  Future<void> _onLoading() async {
    List<BiplusMediaItem> medias;
    switch (widget.type) {
      case ListingType.mc:
        medias = await BiplusMediaAPI().getRadioSongs();
        break;
      case ListingType.favorite:
        medias = await BiplusMediaAPI().getFavoriteRadio();
        break;
      default:
        medias = await BiplusMediaAPI().getRadioSongs(sort: widget.type, offset: mediaItems.length);
        break;
    }
    _refreshController.loadComplete();
    setState(() {
      mediaItems.addAll(BiplusMediaItemConverter().convertToMediaItemList(medias));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                    title: Text(widget.title!),
                    centerTitle: true,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.transparent
                            : Theme.of(context).colorScheme.secondary,
                    elevation: 0),
                body: !_fetched
                  ? SizedBox(
                child: Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width / 8,
                    width: MediaQuery.of(context).size.width / 8,
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ) : mediaItems.isEmpty
                    ? emptyScreen(
                        context,
                        0,
                        ':( ',
                        100,
                        AppLocalizations.of(context)!.sorry,
                        60,
                        AppLocalizations.of(context)!.resultsNotFound,
                        20)
                    : SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: true,
                        header: const WaterDropHeader(),
                        footer: CustomFooter(
                          builder: (context, mode) {
                            Widget body;
                            if (mode == LoadStatus.idle) {
                              body = const Text("Pull to load more");
                            } else if (mode == LoadStatus.loading) {
                              body = const CupertinoActivityIndicator();
                            } else if (mode == LoadStatus.failed) {
                              body = const Text("Load Failed! Click retry!");
                            } else if (mode == LoadStatus.canLoading) {
                              body = const Text("Release to load more");
                            } else {
                              body = const Text("No more Data");
                            }
                            return SizedBox(
                              height: 55.0,
                              child: Center(child: body),
                            );
                          },
                        ),
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        child: ListView(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        opaque: false,
                                        pageBuilder: (_, __, ___) =>
                                            AudioPlayingPage(
                                          songsList: mediaItems,
                                          index: 0,
                                          offline: false,
                                          fromDownloads: false,
                                          fromMiniPlayer: false,
                                          recommend: true,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        top: 20, bottom: 5),
                                    height: 45.0,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5.0,
                                          offset: Offset(0.0, 3.0),
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.play_arrow_rounded,
                                          color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary ==
                                                  Colors.white
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                        const SizedBox(width: 5.0),
                                        Text(
                                          AppLocalizations.of(context)!.play,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                            color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary ==
                                                    Colors.white
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final List tempList = List.from(mediaItems);
                                    tempList.shuffle();
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        opaque: false,
                                        pageBuilder: (_, __, ___) =>
                                            AudioPlayingPage(
                                          songsList: tempList,
                                          index: 0,
                                          offline: false,
                                          fromDownloads: false,
                                          fromMiniPlayer: false,
                                          recommend: true,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      top: 20,
                                      bottom: 5,
                                    ),
                                    height: 45.0,
                                    width: 130,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5.0,
                                          offset: Offset(0.0, 3.0),
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.shuffle_rounded,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 5.0),
                                        Text(
                                          AppLocalizations.of(context)!.shuffle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ...mediaItems.map((entry) {
                              Map miMap =
                                  MediaItemConverter.mediaItemtoMap(entry);
                              return ListTile(
                                contentPadding:
                                    const EdgeInsets.only(left: 15.0),
                                title: Text(
                                  '${miMap["title"]}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onLongPress: () {
                                  copyToClipboard(
                                    context: context,
                                    text: '${miMap["title"]}',
                                  );
                                },
                                leading: Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    errorWidget: (context, _, __) =>
                                        const Image(
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                        'assets/cover.jpg',
                                      ),
                                    ),
                                    imageUrl: Uri.decodeFull(miMap['image']),
                                    placeholder: (context, url) => const Image(
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                        'assets/cover.jpg',
                                      ),
                                    ),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // DownloadButton(
                                    //   data: miMap,
                                    //   icon: 'download',
                                    // ),
                                    if (context.read<AppBloc>().state.status ==
                                        AppStatus.authenticated)
                                      FavoriteButton(
                                        mediaItem: entry,
                                        onLikeChange: () async {
                                          bool addFavorite =
                                              await BiplusMediaAPI()
                                                  .addFavorite(
                                                      mediaId:
                                                          int.parse(entry.id),
                                                      isFavourite:
                                                          !entry.extras?[
                                                              'is_favourite']);
                                          if (addFavorite) {
                                            if (widget.type == ListingType.favorite){
                                              setState(() {
                                                mediaItems.remove(entry);
                                              });
                                            }
                                            ShowSnackBar().showSnackBar(
                                              context,
                                              entry.extras?['is_favourite']
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .addedToFav
                                                  : AppLocalizations.of(
                                                          context)!
                                                      .removedFromFav,
                                            );
                                          }
                                        },
                                      ),
                                    SongTileTrailingMenu(data: miMap),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (_, __, ___) =>
                                          AudioPlayingPage(
                                        songsList: mediaItems,
                                        index: mediaItems.indexWhere(
                                          (element) => element == entry,
                                        ),
                                        offline: false,
                                        fromDownloads: false,
                                        fromMiniPlayer: false,
                                        recommend: true,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList()
                          ],
                        ))),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }

  List<Widget> inflateMediaItems(BuildContext context) {
    List<Widget> items = [];
    for (int i = 0; i < mediaItems.length; i++) {
      Map miMap = MediaItemConverter.mediaItemtoMap(mediaItems[i]);
      items.add(ListTile(
        contentPadding: const EdgeInsets.only(left: 15.0),
        title: Text(
          '${miMap["title"]}',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        onLongPress: () {
          copyToClipboard(
            context: context,
            text: '${miMap["title"]}',
          );
        },
        leading: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            errorWidget: (context, _, __) => const Image(
              fit: BoxFit.cover,
              image: AssetImage(
                'assets/cover.jpg',
              ),
            ),
            imageUrl: Uri.decodeFull(miMap['image']),
            placeholder: (context, url) => const Image(
              fit: BoxFit.cover,
              image: AssetImage(
                'assets/cover.jpg',
              ),
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DownloadButton(
              data: miMap,
              icon: 'download',
            ),
            GestureDetector(
              child: FavoriteButton(
                mediaItem: null,
                data: miMap,
              ),
            ),
            SongTileTrailingMenu(data: miMap),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => AudioPlayingPage(
                songsList: mediaItems,
                index: i,
                offline: false,
                fromDownloads: false,
                fromMiniPlayer: false,
                recommend: true,
              ),
            ),
          );
        },
      ));
    }
    return items;
  }
}
