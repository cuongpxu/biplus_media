
import 'package:json_annotation/json_annotation.dart';

part 'radio_comment.g.dart';

@JsonSerializable()
class Comment {
  @JsonKey(defaultValue: 0)
  int? commentId;
  @JsonKey(defaultValue: 0)
  int? mediaId;
  @JsonKey(defaultValue: 0)
  int? userId;
  @JsonKey(defaultValue: '')
  String? content;
  @JsonKey(defaultValue: 0)
  int? createdDate;
  @JsonKey(defaultValue: 0)
  int? updatedDate;
  @JsonKey(defaultValue: '')
  String? fullName;
  @JsonKey(defaultValue: '')
  String? email;
  @JsonKey(defaultValue: '')
  String? avatar;
  @JsonKey(defaultValue: false)
  bool? isOwner;

  Comment(
      {this.commentId,
        this.mediaId,
        this.userId,
        this.content,
        this.createdDate,
        this.updatedDate,
        this.fullName,
        this.email,
        this.avatar,
        this.isOwner});

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

