import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
part 'user.g.dart';

/// {@template user}
/// User model
///
/// [User.empty] represents an unauthenticated user.
/// {@endtemplate}
@HiveType(typeId: 2)
@JsonSerializable()
class User extends Equatable{
  const User({
    required this.userId,
    this.email = "",
    this.name = "",
    this.loginType = 0,
    this.permissionId = 0,
    this.status = 0,
    this.avatar,
    this.birthday
  });
  @HiveField(0)
  final int userId;

  @HiveField(1)
  @JsonKey(defaultValue: '')
  final String name;

  @HiveField(2)
  @JsonKey(defaultValue: '')
  final String email;

  @HiveField(3)
  @JsonKey(defaultValue: 0)
  final int loginType;

  @HiveField(4)
  @JsonKey(defaultValue: 0)
  final int status;

  @HiveField(5)
  @JsonKey(defaultValue: 0)
  final int permissionId;

  @HiveField(6)
  @JsonKey(defaultValue: '')
  final String? avatar;

  @HiveField(7)
  @JsonKey(fromJson: _parseDatetimeFromJson, toJson: _toJsonFromDatetime)
  final DateTime? birthday;

  static DateTime _parseDatetimeFromJson(int? int) => DateTime.fromMillisecondsSinceEpoch(int?? 0);
  static int _toJsonFromDatetime(DateTime? time) => time?.millisecondsSinceEpoch??0;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Empty user which represents an unauthenticated user.
  static const empty = User(userId: 0);

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  @override
  List<Object?> get props => [userId, email, name, loginType,
    permissionId, status, avatar, birthday];
}