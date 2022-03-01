import 'package:audio_service/audio_service.dart';
import 'package:biplus_audio/biplus_radio.dart';
import 'package:biplus_media/src/api/biplus_media_api.dart';
import 'package:biplus_media/src/app/bloc/app_bloc.dart';
import 'package:biplus_media/src/helpers/biplus_media_item_converter.dart';
import 'package:biplus_media/src/pages/artist_search/view/artist_search_page.dart';
import 'package:biplus_media/src/pages/artist_search/widgets/horizontal_mc_list.dart';
import 'package:biplus_media/src/pages/audio_playing/view/audio_playing_page.dart';
import 'package:biplus_media/src/pages/listing/view/listing_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

import '../../../models/biplus_home_data.dart';
import '../../../models/mc.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({Key? key}) : super(key: key);

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  Map data = Hive.box('cache').get('homepage', defaultValue: {}) as Map;
  List sections = ['new_trending', 'popular', "mcs" /* ,  'likedRadio', 'likedMC' */];
  Map <String, String> sectionsName = {
    'new_trending': 'Trending Now',
    'popular': 'Popular',
    'mcs': 'Recommended MC',
    'likedRadio': 'Favorites',
    'likedMC': 'Favorite MC'
  };

  List<MediaItem> trendingItems = [];
  List<MediaItem> popularItems = [];
  List<Mc> mcs = [];

  @override
  void initState() {
    super.initState();
  }

@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = context.read<AppBloc>().state;
    getRadioData(appState.status == AppStatus.authenticated);
  }

  getRadioData(bool isAuth) async{
    BiplusHomeData? homeData = await BiplusMediaAPI().getHomePageData(isAuth);
    if (homeData != null){
      setState(() {
        trendingItems = BiplusMediaItemConverter().convertToMediaItemList(homeData.newTrending);
        popularItems = BiplusMediaItemConverter().convertToMediaItemList(homeData.popular);
        mcs = homeData.mcs;
      });
    }
  }

  String formatString(String? text) {
    return text == null
        ? ''
        : text
        .replaceAll('&amp;', '&')
        .replaceAll('&#039;', "'")
        .replaceAll('&quot;', '"')
        .trim();
  }

  String getSubTitle(Map item) {
    if (!item.containsKey("type")){
      return formatString(item['artist']?.toString());
    } else {
      final type = item['type'];
      if (type == 'charts') {
        return '';
      } else if (type == 'playlist' || type == 'radio_station') {
        return formatString(item['subtitle']?.toString());
      } else if (type == 'song') {
        return formatString(item['artist']?.toString());
      } else {
        final artists = item['more_info']?['artistMap']?['artists']
            .map((artist) => artist['name'])
            .toList();
        return formatString(artists?.join(', ')?.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
    MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
        ? MediaQuery.of(context).size.width / 2
        : MediaQuery.of(context).size.height / 2.5;
    if (boxSize > 250) boxSize = 250;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      itemCount: sections.length,
      itemBuilder: (context, idx) {
        if (sections[idx] == 'mcs') {
          if (mcs.isEmpty){
            return const SizedBox();
          } else {
            return Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                      child: Text(
                        sectionsName[sections[idx]] ?? 'Unknown',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                HorizontalMCList(
                  mcList: mcs,
                  onTap: (int idx) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (_, __, ___) => const ListingPage(
                          title: "Radios by MC",
                          type: ListingType.mc,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }
        }
        List<MediaItem> mediaItems = sections[idx] == 'new_trending' ? trendingItems : popularItems;
        return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sectionsName[sections[idx]] ?? 'Unknown',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ListingPage(
                                        type: sections[idx] == 'new_trending' ?
                                            ListingType.mostLike : ListingType.mostView,
                                        title: sectionsName[sections[idx]],
                                      )
                                ),
                              );
                            },
                            child: Text(AppLocalizations.of(context)!.viewAll)
                        )
                      ],
                    )
                  ),
                  SizedBox(
                    height: boxSize + 10,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      itemCount:  sections[idx] == 'new_trending' ? trendingItems.length :
                        sections[idx] == 'popular' ? popularItems.length :
                        sections[idx] == 'mcs' ? mcs.length :
                        popularItems.length,
                      itemBuilder: (context, index) {
                        if (mediaItems.isEmpty){
                          return const SizedBox();
                        } else {
                          Map item = MediaItemConverter.mediaItemtoMap(mediaItems[index]);
                          final subTitle = getSubTitle(item);
                          return GestureDetector(
                            onLongPress: () {
                              Feedback.forLongPress(context);
                                showDialog(context: context, builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    backgroundColor: Colors.transparent,
                                    contentPadding: EdgeInsets.zero,
                                    content: Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        errorWidget: (context, _, __) =>
                                        const Image(
                                          fit: BoxFit.cover,
                                          image: AssetImage('assets/cover.jpg'),
                                        ),
                                        imageUrl: item['image']
                                            .toString()
                                            .replaceAll('http:', 'https:')
                                            .replaceAll('50x50', '500x500')
                                            .replaceAll('150x150', '500x500'),
                                        placeholder: (context, url) => Image(
                                          fit: BoxFit.cover,
                                          image: (item['type'] == 'playlist' ||
                                              item['type'] == 'album')
                                              ? const AssetImage(
                                            'assets/album.png',
                                          )
                                              : item['type'] == 'artist'
                                              ? const AssetImage(
                                            'assets/artist.png',
                                          )
                                              : const AssetImage(
                                            'assets/cover.jpg',
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              );
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (_, __, ___) => AudioPlayingPage(
                                      songsList: mediaItems,
                                      index: index,
                                      offline: false,
                                      fromDownloads: false,
                                      fromMiniPlayer: false,
                                      recommend: true,
                                    )
                                ),
                              );
                            },
                            child: SizedBox(
                              width: boxSize - 30,
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      SizedBox.square(
                                        dimension: boxSize - 30,
                                        child: Card(
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            errorWidget: (context, _, __) => const Image(
                                                fit: BoxFit.cover,
                                                image: AssetImage('assets/cover.jpg')
                                            ),
                                            imageUrl: Uri.decodeFull(item['image']),
                                            placeholder: (context, url) => const Image(
                                                fit: BoxFit.cover,
                                                image: AssetImage('assets/cover.jpg')
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        formatString(item['title']?.toString()),
                                        textAlign: TextAlign.center,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (subTitle != '')
                                        Text(
                                          subTitle,
                                          textAlign: TextAlign.center,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .textTheme
                                                .caption!
                                                .color,
                                          ),
                                        )
                                      else
                                        const SizedBox(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
      },
    );
  }
}
