// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radio_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      commentId: json['commentId'] as int? ?? 0,
      mediaId: json['mediaId'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      createdDate: json['createdDate'] as int? ?? 0,
      updatedDate: json['updatedDate'] as int? ?? 0,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      isOwner: json['isOwner'] as bool? ?? false,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'commentId': instance.commentId,
      'mediaId': instance.mediaId,
      'userId': instance.userId,
      'content': instance.content,
      'createdDate': instance.createdDate,
      'updatedDate': instance.updatedDate,
      'fullName': instance.fullName,
      'email': instance.email,
      'avatar': instance.avatar,
      'isOwner': instance.isOwner,
    };
