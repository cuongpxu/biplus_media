
import 'package:authentication_repository/authentication_repository.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'user_info.g.dart';

@HiveType(typeId: 1)
@JsonSerializable(explicitToJson: true)
class UserInfo {
  
  @HiveField(0)
  @JsonKey(defaultValue: '')
  final String token;

  @HiveField(1)
  @JsonKey(fromJson: _parseUserFromJson, toJson: _toJsonFromUser)
  final User user;

  UserInfo(this.token, this.user);

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);


  static User _parseUserFromJson(Map<String, dynamic> userResponse) {
    return User.fromJson(userResponse);
  }

  static Map<String, dynamic> _toJsonFromUser(User user) {
    return user.toJson();
  }
}