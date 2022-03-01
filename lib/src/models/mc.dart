
import 'package:json_annotation/json_annotation.dart';

part 'mc.g.dart';

@JsonSerializable()
class Mc{
  @JsonKey(defaultValue: 0)
  final int? id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String nickName;
  @JsonKey(defaultValue: '')
  final String? email;
  @JsonKey(defaultValue: '')
  final String? phone;
  @JsonKey(defaultValue: '')
  final String? avatar;
  @JsonKey(defaultValue: 1)
  final int? gender;

  @JsonKey(fromJson: _parseDatetimeFromJson, toJson: _toJsonFromDatetime)
  final DateTime birthDay;

  const Mc(this.id, this.name, this.nickName, this.email,
      this.phone, this.avatar, this.gender, this.birthDay);

  factory Mc.fromJson(Map<String, dynamic> json) => _$McFromJson(json);
  Map<String, dynamic> toJson() => _$McToJson(this);

  static DateTime _parseDatetimeFromJson(int? int) => DateTime.fromMillisecondsSinceEpoch(int??0);
  static int _toJsonFromDatetime(DateTime time) => time.millisecondsSinceEpoch;
}