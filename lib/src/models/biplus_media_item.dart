
import 'package:json_annotation/json_annotation.dart';

import 'mc.dart';

part 'biplus_media_item.g.dart';

@JsonSerializable(explicitToJson: true)
class BiplusMediaItem {

  final int mediaId;

  @JsonKey(defaultValue: '')
  final String name;

  @JsonKey(defaultValue: '')
  final String description;

  @JsonKey(defaultValue: '')
  final String image;

  @JsonKey(defaultValue: '')
  final String radioUrl;

  @JsonKey(defaultValue: '')
  final String linkShare;

  @JsonKey(defaultValue: 0)
  final int ownerId;

  @JsonKey(defaultValue: 0)
  final int totalView;

  @JsonKey(defaultValue: 0)
  final int totalLike;

  @JsonKey(defaultValue: 180)
  final int duration;

  @JsonKey(defaultValue: false)
  final bool? isLike;

  @JsonKey(defaultValue: false)
  final bool? isFavourite;

  @JsonKey(fromJson: _parseDatetimeFromJson, toJson: _toJsonFromDatetime)
  final DateTime? createdDate;
  @JsonKey(fromJson: _parseDatetimeFromJson, toJson: _toJsonFromDatetime)
  final DateTime? updatedDate;

  @JsonKey(fromJson: _parseMcsFromJson, toJson: _toJsonFromMcs)
  final List<Mc> mcs;

  @JsonKey(ignore: true)
  bool selected = false;

  BiplusMediaItem(this.mediaId, this.name, this.description, this.image,
      this.radioUrl, this.linkShare, this.ownerId,
      this.totalView, this.totalLike, this.duration,
      this.createdDate, this.updatedDate, this.mcs, this.isLike, this.isFavourite);

  factory BiplusMediaItem.fromJson(Map<String, dynamic> json) => _$BiplusMediaItemFromJson(json);

  Map<String, dynamic> toJson() => _$BiplusMediaItemToJson(this);

  static DateTime _parseDatetimeFromJson(int? int) => DateTime.fromMillisecondsSinceEpoch(int??0);
  static int _toJsonFromDatetime(DateTime? time) => time!.millisecondsSinceEpoch;

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

  String getMcsString(){
    String mcs = '';
    for(int i = 0; i < this.mcs.length; i++){
      if (i == this.mcs.length - 1){
        mcs += this.mcs[i].nickName;
      } else {
        mcs += '${this.mcs[i].nickName}, ';
      }
    }
    return mcs;
  }
}