// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserInfoAdapter extends TypeAdapter<UserInfo> {
  @override
  final int typeId = 1;

  @override
  UserInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserInfo(
      fields[0] as String,
      fields[1] as User,
    );
  }

  @override
  void write(BinaryWriter writer, UserInfo obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.token)
      ..writeByte(1)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      json['token'] as String? ?? '',
      UserInfo._parseUserFromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'token': instance.token,
      'user': UserInfo._toJsonFromUser(instance.user),
    };
