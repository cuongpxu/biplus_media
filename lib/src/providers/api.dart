import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Api {
  static const String url = "https://google.com";

  // Get data
  static Future<Object?> getObjectData() async {
    Object? _result;
    try {
      var dio = Dio(BaseOptions(
        baseUrl: url,
        connectTimeout: 5000,
        receiveTimeout: 100000,
        // 5s
        headers: {
          HttpHeaders.userAgentHeader: 'dio',
          'api': '1.0.0',
        },
        contentType: Headers.jsonContentType,
        // Transform the response data to a String encoded with UTF8.
        // The default value is [ResponseType.JSON].
        responseType: ResponseType.plain,
      ));

      Response response;

      response = await dio.get('/get');
      // debugPrint(response.data);

      var responseMap = await dio.get(
        '/get',
        // Transform response data to Json Map
        options: Options(responseType: ResponseType.json),
      );
      debugPrint(responseMap.data);

      response = await dio.fetch(
        RequestOptions(path: url),
      );
      debugPrint(response.data);
    } catch (e) {
      debugPrint(e.toString());
    }
    return _result;
  }

  static postData() async {
    try {
      var dio = Dio(BaseOptions(
        baseUrl: url,
        connectTimeout: 5000,
        receiveTimeout: 100000,
        // 5s
        headers: {
          HttpHeaders.userAgentHeader: 'dio',
          'api': '1.0.0',
        },
        contentType: Headers.jsonContentType,
        // Transform the response data to a String encoded with UTF8.
        // The default value is [ResponseType.JSON].
        responseType: ResponseType.plain,
      ));
      Response response = await dio.post(
        '/post',
        data: {
          'id': 8,
          'info': {'name': 'wendux', 'age': 25}
        },
        // Send data with "application/x-www-form-urlencoded" format
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      debugPrint(response.data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Using proxy
  static queryWithProxy() async {
    try {
      var dio = Dio();
      dio.options
        ..headers['user-agent'] = 'xxx'
        ..contentType = 'text';
      // dio.options.connectTimeout = 2000;
      // More about HttpClient proxy topic please refer to Dart SDK doc.
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.findProxy = (uri) {
          //proxy all request to localhost:8888
          return 'PROXY localhost:8888';
        };
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      };

      Response<String> response;
      response = await dio.get(url);
      debugPrint('${response.statusCode}');
      response = await dio.get(url);
      debugPrint('${response.statusCode}');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Downloading by spiting as file in chunks
  Future downloadWithChunks(
    url,
    savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    const firstChunkSize = 102;
    const maxChunk = 3;

    var total = 0;
    var dio = Dio();
    var progress = <int>[];

    void Function(int, int) createCallback(no) {
      return (int received, int _) {
        progress[no] = received;
        if (onReceiveProgress != null && total != 0) {
          onReceiveProgress(progress.reduce((a, b) => a + b), total);
        }
      };
    }

    Future<Response> downloadChunk(url, start, end, no) async {
      progress.add(0);
      --end;
      return dio.download(
        url,
        savePath + 'temp$no',
        onReceiveProgress: createCallback(no),
        options: Options(
          headers: {'range': 'bytes=$start-$end'},
        ),
      );
    }

    Future mergeTempFiles(chunk) async {
      var f = File(savePath + 'temp0');
      var ioSink = f.openWrite(mode: FileMode.writeOnlyAppend);
      for (var i = 1; i < chunk; ++i) {
        var _f = File(savePath + 'temp$i');
        await ioSink.addStream(_f.openRead());
        await _f.delete();
      }
      await ioSink.close();
      await f.rename(savePath);
    }

    var response = await downloadChunk(url, 0, firstChunkSize, 0);
    if (response.statusCode == 206) {
      total = int.parse(response.headers
          .value(HttpHeaders.contentRangeHeader)!
          .split('/')
          .last);
      var reserved = total -
          int.parse(response.headers.value(Headers.contentLengthHeader)!);
      var chunk = (reserved / firstChunkSize).ceil() + 1;
      if (chunk > 1) {
        var chunkSize = firstChunkSize;
        if (chunk > maxChunk + 1) {
          chunk = maxChunk + 1;
          chunkSize = (reserved / maxChunk).ceil();
        }
        var futures = <Future>[];
        for (var i = 0; i < maxChunk; ++i) {
          var start = firstChunkSize + i * chunkSize;
          futures.add(downloadChunk(url, start, start + chunkSize, i + 1));
        }
        await Future.wait(futures);
      }
      await mergeTempFiles(chunk);
    }
  }
}
