import 'package:audio_service/audio_service.dart';

// ignore: avoid_classes_with_only_static_members
class MediaItemConverter {
  static Map mediaItemtoMap(MediaItem mediaItem) {
    return {
      'id': mediaItem.id,
      'title': mediaItem.title,
      'album': mediaItem.album.toString(),
      'artist': mediaItem.artist.toString(),
      'duration': mediaItem.duration?.inSeconds.toString(),
      'image': mediaItem.artUri.toString(),
      'genre': mediaItem.genre.toString(),

      'url': mediaItem.extras!['url'].toString(),
      'description': mediaItem.extras!.containsKey('description') ? mediaItem.extras!['description'].toString() : null,
      'year': mediaItem.extras?['year'].toString(),
      'language': mediaItem.extras?['language'].toString(),
      '320kbps': mediaItem.extras?['320kbps'],
      'quality': mediaItem.extras?['quality'],
      'has_lyrics': mediaItem.extras!.containsKey('description') ? true : mediaItem.extras!['has_lyrics'],
      'release_date': mediaItem.extras?['release_date'],
      'album_id': mediaItem.extras?['album_id'],
      'subtitle': mediaItem.extras?['subtitle'],
      'perma_url': mediaItem.extras?['perma_url'],
    };
  }

  static MediaItem mapToMediaItem(Map song, {bool addedByAutoplay = false, bool autoplay = true}) {
    return MediaItem(
      id: song['id'].toString(),
      title: song['title'].toString(),
      album: song['album'].toString(),
      artist: song['artist'].toString(),
      duration: Duration(
        seconds: int.parse(
          !song.containsKey('duration') ? '180' :
          song['duration'] == null ? '180' : song['duration'].toString(),
        ),
      ),
      artUri: Uri.parse(
        song['image']
            .toString()
            .replaceAll('50x50', '500x500')
            .replaceAll('150x150', '500x500'),
      ),
      genre: song['language'].toString(),
      extras: {
        'url': song['url'],
        'description': song.containsKey('description') ? song['description'].toString() : null,
        'year': song['year'],
        'language': song['language'],
        '320kbps': song['320kbps'],
        'quality': song['quality'],
        'has_lyrics': song['has_lyrics'],
        'release_date': song['release_date'],
        'album_id': song['album_id'],
        'subtitle': song['subtitle'],
        'perma_url': song['perma_url'],
        'addedByAutoplay': addedByAutoplay,
        'autoplay': autoplay,
      },
    );
  }

  static MediaItem downMapToMediaItem(Map song) {
    return MediaItem(
      id: song['id'].toString(),
      album: song['album'].toString(),
      artist: song['artist'].toString(),
      duration: Duration(
        seconds: int.parse(
          !song.containsKey('duration') ? '180' :
          song['duration'] == null ? '180' : song['duration'].toString(),
        ),
      ),
      title: song['title'].toString(),
      artUri: Uri.file(song['image'].toString()),
      genre: song['genre'].toString(),
      extras: {
        'url': song['path'].toString(),
        'year': song['year'],
        'language': song['genre'],
        'release_date': song['release_date'],
        'album_id': song['album_id'],
        'subtitle': song['subtitle'],
        'quality': song['quality'],
      }
    );
  }
}
