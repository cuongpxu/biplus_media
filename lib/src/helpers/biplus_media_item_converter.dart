import 'package:biplus_media/src/models/biplus_media_item.dart';
import 'package:audio_service/audio_service.dart';
import 'package:intl/intl.dart';

class BiplusMediaItemConverter {

  MediaItem mapBiplusMediaItemToMediaItem (
      BiplusMediaItem biplusMediaItem, {bool addedByAutoplay = false, bool autoplay = true}) {
    Map bmiMap = biplusMediaItem.toJson();
    return MediaItem(
        id: bmiMap['mediaId'].toString(),
        album: bmiMap['album'].toString(),
        artist: biplusMediaItem.getMcsString(),
        duration: Duration(
          seconds: int.parse(
            !bmiMap.containsKey('duration') ? '180' :
            bmiMap['duration'] == null ? '180' : bmiMap['duration'].toString(),
          ),
        ),
        title: bmiMap['name'].toString(),
        artUri: Uri.file(bmiMap['image'].toString()),
        genre: bmiMap.containsKey('genre') ? bmiMap['genre'].toString() : 'vi',
        extras: {
          'url': bmiMap['radioUrl'].toString(),
          'description': bmiMap['description'].toString(),
          'year': biplusMediaItem.createdDate?.year,
          'language': bmiMap.containsKey('genre') ? bmiMap['genre'].toString() : 'vi',
          'release_date': DateFormat('dd/MM/yyyy HH:mm:ss').format(biplusMediaItem.createdDate!).toString(),
          'album_id': bmiMap['album_id'],
          'subtitle': bmiMap['subtitle'],
          'quality': bmiMap['quality'],
          'date_modified': DateFormat('dd/MM/yyyy HH:mm:ss').format(biplusMediaItem.updatedDate!).toString(),
          'perma_url': bmiMap['link_share'],
          'addedByAutoplay': addedByAutoplay,
          'autoplay': autoplay,
          'is_like': biplusMediaItem.isLike,
          'is_favourite': biplusMediaItem.isFavourite,
        });
  }

  List<MediaItem> convertToMediaItemList(List<BiplusMediaItem> bmItems){
    List<MediaItem> mediaItems = [];
    for (var item in bmItems) {
      mediaItems.add(BiplusMediaItemConverter().mapBiplusMediaItemToMediaItem(item));
    }
    return mediaItems;
  }
}
