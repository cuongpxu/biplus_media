import 'package:biplus_audio/biplus_radio.dart';
import 'package:biplus_media/src/pages/album_search/view/album_search_page.dart';
import 'package:biplus_media/src/pages/artist_search/view/artist_search_page.dart';
import 'package:biplus_media/src/pages/audio_listing/view/audio_listing_page.dart';
import 'package:biplus_media/src/pages/audio_playing/view/audio_playing_page.dart';
import 'package:biplus_media/src/pages/listing/view/listing_page.dart';
import 'package:biplus_media/src/pages/search/widgets/search_bar.dart';
import 'package:biplus_media/src/widgets/copy_clipboard.dart';
import 'package:biplus_media/src/widgets/download_button.dart';
import 'package:biplus_media/src/widgets/empty_screen.dart';
import 'package:biplus_media/src/widgets/gradient_containers.dart';
import 'package:biplus_media/src/widgets/favorite_button.dart';
import 'package:biplus_media/src/widgets/mini_player.dart';
import 'package:biplus_media/src/widgets/snackbar.dart';
import 'package:biplus_media/src/widgets/song_tile_trailing_menu.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:audio_service/audio_service.dart';

import '../../../api/biplus_media_api.dart';
import '../../../app/bloc/app_bloc.dart';
import '../../../helpers/biplus_media_item_converter.dart';
import '../../../models/biplus_media_item.dart';

class SearchPage extends StatefulWidget {
  final String query;
  final bool fromHome;
  final bool autofocus;

  const SearchPage({
    Key? key,
    required this.query,
    this.fromHome = false,
    this.autofocus = false,
  }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  bool status = false;
  List<MediaItem> searchedData = [];

  bool fetched = false;
  bool alertShown = false;
  bool? fromHome;

  // List search = Hive.box('settings').get('search', defaultValue: [],) as List;
  // bool showHistory =
  // Hive.box('settings').get('showHistory', defaultValue: true) as bool;
  bool liveSearch =
      Hive.box('settings').get('liveSearch', defaultValue: true) as bool;

  final controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.query;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> fetchResults() async {
    if (query != '') {
      List<BiplusMediaItem> medias;
      final appState = context.read<AppBloc>().state;
      bool isAuth = appState.status == AppStatus.authenticated;
      medias = await BiplusMediaAPI()
          .getRadioSongs(isAuth: isAuth, searchKey: query);
      searchedData
          .addAll(BiplusMediaItemConverter().convertToMediaItemList(medias));
    }
    fetched = true;

    setState(
      () {},
    );
  }

  Widget nothingFound(BuildContext context) {
    if (!alertShown) {
      ShowSnackBar().showSnackBar(
        context,
        AppLocalizations.of(context)!.useVpn,
        duration: const Duration(seconds: 5),
      );
      alertShown = true;
    }
    return emptyScreen(
      context,
      0,
      ':( ',
      100,
      AppLocalizations.of(context)!.sorry,
      60,
      AppLocalizations.of(context)!.resultsNotFound,
      20,
    );
  }

  @override
  Widget build(BuildContext context) {
    fromHome ??= widget.fromHome;
    if (!status) {
      status = true;
      fetchResults();
    }
    return GradientContainer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: SearchBar(
                  controller: controller,
                  liveSearch: liveSearch,
                  autofocus: widget.autofocus,
                  hintText: AppLocalizations.of(context)!.searchText,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  body: !fetched
                      ? SizedBox(
                          child: Center(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.width / 8,
                              width: MediaQuery.of(context).size.width / 8,
                              child: const CircularProgressIndicator(),
                            ),
                          ),
                        )
                      : (searchedData.isEmpty)
                          ? nothingFound(context)
                          : ListView(
                              padding: const EdgeInsets.only(top: 70),
                              children: [
                                ...searchedData.map((entry) {
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
                                        borderRadius:
                                            BorderRadius.circular(7.0),
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
                                        imageUrl:
                                            Uri.decodeFull(miMap['image']),
                                        placeholder: (context, url) =>
                                            const Image(
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
                                        if (context
                                                .read<AppBloc>()
                                                .state
                                                .status ==
                                            AppStatus.authenticated)
                                          FavoriteButton(
                                            mediaItem: entry,
                                            onLikeChange: () async {
                                              bool addFavorite =
                                                  await BiplusMediaAPI()
                                                      .addFavorite(
                                                          mediaId: int.parse(
                                                              entry.id),
                                                          isFavourite: !entry
                                                                  .extras?[
                                                              'is_favourite']);
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
                                            songsList: searchedData,
                                            index: searchedData.indexWhere(
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
                            ),
                  onSubmitted: (String _query) {
                    setState(
                      () {
                        fetched = false;
                        query = _query;
                        status = false;
                        fromHome = false;
                        searchedData = [];
                      },
                    );
                  },
                ),
              ),
            ),
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }
}
