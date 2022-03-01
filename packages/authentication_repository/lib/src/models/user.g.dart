// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 2;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      userId: fields[0] as int,
      email: fields[2] as String,
      name: fields[1] as String,
      loginType: fields[3] as int,
      permissionId: fields[5] as int,
      status: fields[4] as int,
      avatar: fields[6] as String?,
      birthday: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.loginType)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.permissionId)
      ..writeByte(6)
      ..write(obj.avatar)
      ..writeByte(7)
      ..write(obj.birthday);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: json['userId'] as int,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      loginType: json['loginType'] as int? ?? 0,
      permissionId: json['permissionId'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      avatar: json['avatar'] as String? ?? '',
      birthday: User._parseDatetimeFromJson(json['birthday'] as int? ?? 0),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'loginType': instance.loginType,
      'status': instance.status,
      'permissionId': instance.permissionId,
      'avatar': instance.avatar,
      'birthday': User._toJsonFromDatetime(instance.birthday),
    };
