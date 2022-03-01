// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biplus_home_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BiplusHomeData _$BiplusHomeDataFromJson(Map<String, dynamic> json) =>
    BiplusHomeData(
      BiplusHomeData._parseMediaItemsFromJson(json['newTrending'] as List),
      BiplusHomeData._parseMediaItemsFromJson(json['popular'] as List),
      json['mcs'] == null
          ? []
          : BiplusHomeData._parseMcsFromJson(json['mcs'] as List),
    );

Map<String, dynamic> _$BiplusHomeDataToJson(BiplusHomeData instance) =>
    <String, dynamic>{
      'newTrending': BiplusHomeData._toJsonFromMediaItems(instance.newTrending),
      'popular': BiplusHomeData._toJsonFromMediaItems(instance.popular),
      'mcs': BiplusHomeData._toJsonFromMcs(instance.mcs),
    };
