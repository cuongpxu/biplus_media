// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biplus_media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BiplusMediaItem _$BiplusMediaItemFromJson(Map<String, dynamic> json) =>
    BiplusMediaItem(
      json['mediaId'] as int,
      json['name'] as String? ?? '',
      json['description'] as String? ?? '',
      json['image'] as String? ?? '',
      json['radioUrl'] as String? ?? '',
      json['linkShare'] as String? ?? '',
      json['ownerId'] as int? ?? 0,
      json['totalView'] as int? ?? 0,
      json['totalLike'] as int? ?? 0,
      json['duration'] as int? ?? 180,
      BiplusMediaItem._parseDatetimeFromJson(json['createdDate'] as int?),
      BiplusMediaItem._parseDatetimeFromJson(json['updatedDate'] as int?),
      BiplusMediaItem._parseMcsFromJson(json['mcs'] as List),
      json['isLike'] as bool? ?? false,
      json['isFavourite'] as bool? ?? false,
    );

Map<String, dynamic> _$BiplusMediaItemToJson(BiplusMediaItem instance) =>
    <String, dynamic>{
      'mediaId': instance.mediaId,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'radioUrl': instance.radioUrl,
      'linkShare': instance.linkShare,
      'ownerId': instance.ownerId,
      'totalView': instance.totalView,
      'totalLike': instance.totalLike,
      'duration': instance.duration,
      'isLike': instance.isLike,
      'isFavourite': instance.isFavourite,
      'createdDate': BiplusMediaItem._toJsonFromDatetime(instance.createdDate),
      'updatedDate': BiplusMediaItem._toJsonFromDatetime(instance.updatedDate),
      'mcs': BiplusMediaItem._toJsonFromMcs(instance.mcs),
    };
