
import 'dart:io';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:biplus_media/src/models/biplus_home_data.dart';
import 'package:biplus_media/src/models/biplus_media_item.dart';
import 'package:biplus_media/src/models/radio_comment.dart';
import 'package:biplus_media/src/models/user_info.dart';
import 'package:biplus_media/src/pages/auth/sign_up/sign_up.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../pages/listing/view/listing_page.dart';
import 'api_logging.dart';

class BiplusMediaAPI {
  final Dio _dio = Dio()..interceptors.add(Logging());

  static String baseUrl = 'http://192.168.3.40:8888/api/v1/';

  Map<String, String> headers = {
    'Accept': '*/*',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive'
  };
  Map<String, String> apiDomain = {
    'listMedia': 'media-publish/',
    'mediaDetail': 'media-publish/',
    'checkEmail': 'mail-management/',
    'sendOtp': 'otp-management/',
    'signUp': 'user-management/',
    'signIn': 'user-management/',
    'favorite': 'favourite-management/',
    'media': 'media-publish/',
    'mediaAuth': 'auth/media-publish/',
  };
  Map<String, String> endPoints = {
    'homePageData': 'home-page',
    'listMedia': 'medias',
    'mediaDetail': 'media',
    'checkEmail': 'email-valid',
    'signUp': 'sign-up',
    'signIn': 'sign-in',
    'sendOtp': 'send-to',
    'checkOtp': 'check',
    'listFavorite': 'favourites',
    'addFavorite': 'favourite',
    'like': 'like',
    'listComment': 'comments',
    'addComment': 'comment',
  };

  var baseOptions = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: 5000,
    receiveTimeout: 3000,
    // 5s
    headers: {
      HttpHeaders.userAgentHeader: 'dio',
      'api': '1.0.0',
    },
    contentType: Headers.jsonContentType,
    // Transform the response data to a String encoded with UTF8.
    // The default value is [ResponseType.JSON].
    responseType: ResponseType.json,
  );

  Future<Response> getResponse(String path) async {
    UserInfo? userInfo = await Hive.box('settings').get('user');
    final token = userInfo?.token;
    baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: {
        HttpHeaders.authorizationHeader: token,
      },
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
    _dio.options = baseOptions;

    try {
      Response response = await _dio.get('$baseUrl$path');
      // print(response.data);
      return response;
    } catch (e) {
      return Response(statusMessage: e.toString(),
          statusCode: 404, requestOptions: RequestOptions(
            path: path
          ));
    }
  }

  Future<Response> postData(String path, Map<String, dynamic> data) async {
    UserInfo? userLocal = await Hive.box('settings').get('user');
    final token = userLocal?.token;
    baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: {
        HttpHeaders.authorizationHeader: token
      },
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
    _dio.options = baseOptions;

    try {
      Response response = await _dio.post('$baseUrl$path', data: data);
      return response;
    } catch (e) {
      return Response(statusMessage: e.toString(),
          statusCode: 404, requestOptions: RequestOptions(
              path: path
          ));
    }
  }

  Future<Response> delete(String path) async {
    UserInfo? userLocal = await Hive.box('settings').get('user');
    final token = userLocal?.token;
    baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: {
        HttpHeaders.authorizationHeader: token
      },
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
    _dio.options = baseOptions;

    try {
      Response response = await _dio.delete('$baseUrl$path');
      return response;
    } catch (e) {
      return Response(statusMessage: e.toString(),
          statusCode: 404, requestOptions: RequestOptions(
              path: path
          ));
    }
  }

  Future<BiplusHomeData?> getHomePageData(bool isAuth) async {
    final String params = (isAuth ? 'auth/' : '') + "${apiDomain['listMedia']}${endPoints['homePageData']}";
    final res = await getResponse(params);
    if (res.statusCode == 200) {
      return BiplusHomeData.fromJson(res.data['data']);
    }
    return null;
  }

  Future<List<BiplusMediaItem>> getRadioSongs({bool isAuth = false, String searchKey='', ListingType sort = ListingType.newest, int offset = 0}) async {
    final String params = (isAuth ? 'auth/' : '') + "${apiDomain['listMedia']}${endPoints['listMedia']}?q=$searchKey&sort=${sort.index}&offset=$offset";
    final res = await getResponse(params);
    if (res.statusCode == 200) {
      final List<BiplusMediaItem> medias = [];
      for (int i = 0; i < res.data['data'].length; i++) {
        medias.add(BiplusMediaItem.fromJson(res.data['data'][i]));
      }
      print(medias.length);
      return medias;
    }
    return [];
  }

  Future<BiplusMediaItem?> getRadioDetail(int id) async {
    final String params = "${apiDomain['mediaDetail']}${endPoints['mediaDetail']}?id=$id";
    final res = await getResponse(params);
    if (res.statusCode == 200) {
      return BiplusMediaItem.fromJson(res.data['data']);
    }
    return null;
  }

  Future<Map<String, dynamic>?> checkEmail(String email) async {
    final String params = "${apiDomain['signUp']}${endPoints['checkEmail']}?email=$email";
    final res = await getResponse(params);
    if (res.statusCode == 200) {
      return (res.data);
    }
    return null;
  }

  Future<Map<String, dynamic>?> checkOtp(String email, int type, String otp) async {
    final String params = "${apiDomain['sendOtp']}${endPoints['checkOtp']}?email=$email&type=$type&otp=$otp";
    final res = await getResponse(params);
    if (res.statusCode == 200) {
      return (res.data);
    }
    return null;
  }

  Future<UserInfo?> signUp(String email, String password) async {
    final String path = "${apiDomain['signUp']}${endPoints['signUp']}";
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'loginType': LoginType.email
    };
    final res = await postData(path, data);
    if (res.statusCode == 200) {
      return (UserInfo.fromJson(res.data['data']));
    }
    throw SignUpWithEmailAndPasswordFailure(res.data['message']);
  }

  Future<UserInfo?> signIn({required int loginType, String? email, String? password,
    String? socialId, String? fullName, String? avatar}) async {
    final String path = "${apiDomain['signIn']}${endPoints['signIn']}";
    final Map<String, dynamic> data = {
      'loginType': loginType,
      'email': email,
      'password': password,
      'socialId': socialId,
      'fullName': fullName,
      'avatar': avatar
    };
    print(data);
    final res = await postData(path, data);
    if (res.statusCode == 200){
      if (res.data['errorCode'] == 200) {
        print(res.data);
        return (UserInfo.fromJson(res.data['data']));
      }else {
        throw LogInWithEmailAndPasswordFailure(res.data['message']);
      }
    }else{
      throw const LogInWithEmailAndPasswordFailure('Có lỗi xảy ra, vui lòng thử lại!');
    }
  }

  Future<List<BiplusMediaItem>> getFavoriteRadio() async {
    final String params = "${apiDomain['favorite']}${endPoints['listFavorite']}";
    final res = await getResponse(params);
    if (res.statusCode == 200) {
      final List<BiplusMediaItem> medias = [];
      for (int i = 0; i < res.data['data'].length; i++) {
        medias.add(BiplusMediaItem.fromJson(res.data['data'][i]));
      }
      print(medias.length);
      return medias;
    }
    return [];
  }

  Future<bool> addFavorite({required int mediaId, required bool isFavourite}) async {
    final String path = "${apiDomain['favorite']}${endPoints['addFavorite']}";
    final Map<String, dynamic> data = {
      'mediaId': mediaId,
      'isFavourite': isFavourite
    };
    final res = await postData(path, data);
    if (res.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> likeRadio({required int mediaId, required bool isLike}) async {
    final String path = "${apiDomain['media']}${endPoints['like']}";
    final Map<String, dynamic> data = {
      'mediaId': mediaId,
      'isLike': isLike
    };
    final res = await postData(path, data);
    if (res.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<List<Comment>> getRadioComment({required int mediaId, int offset = 0}) async {
    final String params = "${apiDomain['mediaAuth']}${endPoints['listComment']}?mediaId=$mediaId&offset=$offset";
    final res = await getResponse(params);
    if (res.statusCode == 200) {
      final List<Comment> comments = [];
      for (int i = 0; i < res.data['data'].length; i++) {
        comments.add(Comment.fromJson(res.data['data'][i]));
      }
      return comments;
    }
    return [];
  }

  Future<Comment?> addComment({required int mediaId, required String content}) async {
    final String path = "${apiDomain['mediaAuth']}${endPoints['addComment']}";
    final Map<String, dynamic> data = {
      'mediaId': mediaId,
      'content': content
    };
    final res = await postData(path, data);
    if (res.statusCode == 200) {
      return Comment.fromJson(res.data['data']);
    }
    return null;
  }

  Future<bool> deleteComment({required int mediaId, required int commentId}) async {
    final String path = "${apiDomain['mediaAuth']}media/$mediaId/comment/$commentId";
    final res = await delete(path);
    if (res.statusCode == 200) {
      return true;
    }
    return false;
  }
}