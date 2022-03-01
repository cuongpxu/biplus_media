import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:biplus_audio/biplus_radio.dart';
import 'package:biplus_media/src/helpers/picker.dart';
import 'package:biplus_media/src/helpers/song_helper.dart';
import 'package:biplus_media/src/widgets/snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PlaylistHelper {
  bool checkPlaylist(String name, String key) {
    if (name != 'Favorite Songs') {
      Hive.openBox(name).then((value) {
        return Hive.box(name).containsKey(key);
      });
    }
    return Hive.box(name).containsKey(key);
  }

  Future<void> removeLiked(String key) async {
    final Box likedBox = Hive.box('Favorite Songs');
    likedBox.delete(key);
    // setState(() {});
  }

  Future<void> addMapToPlaylist(String name, Map info) async {
    if (name != 'Favorite Songs') await Hive.openBox(name);
    final Box playlistBox = Hive.box(name);
    final List _songs = playlistBox.values.toList();
    info.addEntries([MapEntry('dateAdded', DateTime.now().toString())]);
    SongHelper().addSongsCount(
      name,
      playlistBox.values.length + 1,
      _songs.length >= 4
          ? _songs.sublist(0, 4)
          : _songs.sublist(0, _songs.length),
    );
    playlistBox.put(info['id'].toString(), info);
  }

  Future<void> addItemToPlaylist(String name, MediaItem mediaItem) async {
    if (name != 'Favorite Songs') await Hive.openBox(name);
    final Box playlistBox = Hive.box(name);
    final Map info = MediaItemConverter.mediaItemtoMap(mediaItem);
    info.addEntries([MapEntry('dateAdded', DateTime.now().toString())]);
    final List _songs = playlistBox.values.toList();
    SongHelper().addSongsCount(
      name,
      playlistBox.values.length + 1,
      _songs.length >= 4
          ? _songs.sublist(0, 4)
          : _songs.sublist(0, _songs.length),
    );
    playlistBox.put(mediaItem.id, info);
  }

  Future<void> addPlaylist(String inputName, List data) async {
    final RegExp avoid = RegExp(r'[\.\\\*\:\"\?#/;\|]');
    String name = inputName.replaceAll(avoid, '').replaceAll('  ', ' ');

    await Hive.openBox(name);
    final Box playlistBox = Hive.box(name);

    SongHelper().addSongsCount(
      name,
      data.length,
      data.length >= 4 ? data.sublist(0, 4) : data.sublist(0, data.length),
    );
    final Map result = {for (var v in data) v['id'].toString(): v};
    playlistBox.putAll(result);

    final List playlistNames =
    Hive.box('settings').get('playlistNames', defaultValue: []) as List;

    if (name.trim() == '') {
      name = 'Playlist ${playlistNames.length}';
    }
    while (playlistNames.contains(name)) {
      // ignore: use_string_buffers
      name += ' (1)';
    }
    playlistNames.add(name);
    Hive.box('settings').put('playlistNames', playlistNames);
  }

  Future<void> exportPlaylist(
      BuildContext context,
      String playlistName,
      String showName,
      ) async {
    final String dirPath = await Picker.selectFolder(
      context: context,
      message: AppLocalizations.of(context)!.selectExportLocation,
    );
    if (dirPath == '') {
      ShowSnackBar().showSnackBar(
        context,
        '${AppLocalizations.of(context)!.failedExport} "$showName"',
      );
      return;
    }
    await Hive.openBox(playlistName);
    final Box playlistBox = Hive.box(playlistName);
    final Map _songsMap = playlistBox.toMap();
    final String _songs = json.encode(_songsMap);
    final File file =
    await File('$dirPath/$showName.json').create(recursive: true);
    await file.writeAsString(_songs);
    ShowSnackBar().showSnackBar(
      context,
      '${AppLocalizations.of(context)!.exported} "$showName"',
    );
  }

  Future<void> sharePlaylist(
      BuildContext context,
      String playlistName,
      String showName,
      ) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String temp = appDir.path;

    await Hive.openBox(playlistName);
    final Box playlistBox = Hive.box(playlistName);
    final Map _songsMap = playlistBox.toMap();
    final String _songs = json.encode(_songsMap);
    final File file = await File('$temp/$showName.json').create(recursive: true);
    await file.writeAsString(_songs);

    await Share.shareFiles(
      [file.path],
      text: AppLocalizations.of(context)!.playlistShareText,
    );
    await Future.delayed(const Duration(seconds: 10), () {});
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List> importPlaylist(BuildContext context, List playlistNames) async {
    try {
      final String temp = await Picker.selectFile(
        context: context,
        ext: ['json'],
        message: AppLocalizations.of(context)!.selectJsonImport,
      );
      if (temp == '') {
        ShowSnackBar().showSnackBar(
          context,
          AppLocalizations.of(context)!.failedImport,
        );
        return playlistNames;
      }

      final RegExp avoid = RegExp(r'[\.\\\*\:\"\?#/;\|]');
      String playlistName = temp
          .split('/')
          .last
          .replaceAll('.json', '')
          .replaceAll(avoid, '')
          .replaceAll('  ', ' ');

      final File file = File(temp);
      final String finString = await file.readAsString();
      final Map _songsMap = json.decode(finString) as Map;
      final List _songs = _songsMap.values.toList();
      // playlistBox.put(mediaItem.id.toString(), info);
      // Hive.box(play)

      if (playlistName.trim() == '') {
        playlistName = 'Playlist ${playlistNames.length}';
      }
      if (playlistNames.contains(playlistName)) {
        playlistName = '$playlistName (1)';
      }
      playlistNames.add(playlistName);

      await Hive.openBox(playlistName);
      final Box playlistBox = Hive.box(playlistName);
      await playlistBox.putAll(_songsMap);

      SongHelper().addSongsCount(
        playlistName,
        _songs.length,
        _songs.length >= 4
            ? _songs.sublist(0, 4)
            : _songs.sublist(0, _songs.length),
      );
      ShowSnackBar().showSnackBar(
        context,
        '${AppLocalizations.of(context)!.importSuccess} "$playlistName"',
      );
      return playlistNames;
    } catch (e) {
      ShowSnackBar().showSnackBar(
        context,
        AppLocalizations.of(context)!.failedImport,
      );
    }
    return playlistNames;
  }
}