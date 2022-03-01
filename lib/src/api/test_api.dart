
import 'package:biplus_media/src/api/biplus_media_api.dart';
import 'package:biplus_media/src/models/biplus_media_item.dart';

void main() async{
  List<BiplusMediaItem> medias = await BiplusMediaAPI().getRadioSongs();
  print(medias.length);

  BiplusMediaItem? m = await BiplusMediaAPI().getRadioDetail(1);
  print(m?.name);
}