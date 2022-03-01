
import 'package:biplus_media/src/models/biplus_media_item.dart';
import 'package:json_annotation/json_annotation.dart';

import 'mc.dart';

part 'biplus_home_data.g.dart';

@JsonSerializable(explicitToJson: true)
class BiplusHomeData {
  @JsonKey(fromJson: _parseMediaItemsFromJson, toJson: _toJsonFromMediaItems)
  final List<BiplusMediaItem> newTrending;

  @JsonKey(fromJson: _parseMediaItemsFromJson, toJson: _toJsonFromMediaItems)
  final List<BiplusMediaItem> popular;

  @JsonKey(defaultValue: [],fromJson: _parseMcsFromJson, toJson: _toJsonFromMcs)
  final List<Mc> mcs;

  BiplusHomeData(this.newTrending, this.popular, this.mcs);

  factory BiplusHomeData.fromJson(Map<String, dynamic> json) => _$BiplusHomeDataFromJson(json);

  Map<String, dynamic> toJson() => _$BiplusHomeDataToJson(this);

  static List<Mc> _parseMcsFromJson(List<dynamic> mcsResponse) {
    List<Mc> mcs = [];
    for(int i = 0; i < mcsResponse.length; i++){
      mcs.add(Mc.fromJson(mcsResponse[i]));
    }
    return mcs;
  }

  static List<dynamic> _toJsonFromMcs(List<Mc> mcs) {
    List<dynamic> mcsJson = [];
    for(int i = 0; i < mcs.length; i++){
      mcsJson.add(mcs[i].toJson());
    }
    return mcs;
  }

  static List<BiplusMediaItem> _parseMediaItemsFromJson(List<dynamic> bmiResponse) {
    List<BiplusMediaItem> bmiItems = [];
    for(int i = 0; i < bmiResponse.length; i++){
      bmiItems.add(BiplusMediaItem.fromJson(bmiResponse[i]));
    }
    return bmiItems;
  }

  static List<dynamic> _toJsonFromMediaItems(List<BiplusMediaItem> bmiItems) {
    List<dynamic> bmiItemsJson = [];
    for(int i = 0; i < bmiItems.length; i++){
      bmiItemsJson.add(bmiItems[i].toJson());
    }
    return bmiItemsJson;
  }
}