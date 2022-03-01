// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mc _$McFromJson(Map<String, dynamic> json) => Mc(
      json['id'] as int? ?? 0,
      json['name'] as String? ?? '',
      json['nickName'] as String? ?? '',
      json['email'] as String? ?? '',
      json['phone'] as String? ?? '',
      json['avatar'] as String? ?? '',
      json['gender'] as int? ?? 1,
      Mc._parseDatetimeFromJson(json['birthDay'] as int?),
    );

Map<String, dynamic> _$McToJson(Mc instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nickName': instance.nickName,
      'email': instance.email,
      'phone': instance.phone,
      'avatar': instance.avatar,
      'gender': instance.gender,
      'birthDay': Mc._toJsonFromDatetime(instance.birthDay),
    };
