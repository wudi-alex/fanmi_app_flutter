import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:fanmi/net/status_code.dart';
import 'package:fanmi/utils/platform_utils.dart';

import 'package:flutter/foundation.dart';

export 'package:dio/dio.dart';

// 必须是顶层函数
_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

abstract class BaseHttp extends DioForNative {
  BaseHttp() {
    /// 初始化 加入app通用处理
    (transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
    interceptors..add(HeaderInterceptor());
    init();
  }

  void init();
}

/// 添加常用Header
class HeaderInterceptor extends InterceptorsWrapper {
  @override
  onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.connectTimeout = 5000;
    options.receiveTimeout = 5000;

    var appVersion = await PlatformUtils.getAppVersion();
    var version = Map()
      ..addAll({
        'appVerison': appVersion,
      });
    options.headers['version'] = version;
    options.headers['platform'] = Platform.operatingSystem;
    return super.onRequest(options, handler);
  }
}

/// 子类需要重写
abstract class BaseResponseData {
  int code = 0;
  String message = "";
  dynamic data;

  bool get success;

  @override
  String toString() {
    return 'BaseRespData{code: $code, message: $message, data: $data}';
  }
}

class ResponseData extends BaseResponseData {
  ResponseData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['msg'];
    data = json['data'];
  }

  bool get success => StatusCode.SUCCESS == code;
}

final Http http = Http();

class Http extends BaseHttp {
  @override
  void init() {
    options.baseUrl = "https://api.fanminet.com/api";
    interceptors..add(ApiInterceptor());
  }
}

class ApiInterceptor extends InterceptorsWrapper {
  @override
  onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    debugPrint('---api-request--->url--> ${options.baseUrl}${options.path}' +
        ' queryParameters: ${options.queryParameters}');
    return super.onRequest(options, handler);
  }

  @override
  onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint('---api-response--->resp----->${response.data}');
    ResponseData respData = ResponseData.fromJson(response.data);
    if (respData.success) {
      response.data = respData.data;
      response.statusCode = respData.code;
      return super.onResponse(response, handler);
    } else {
      throw NotSuccessException.fromRespData(respData);
    }
  }
}

/// 接口的code没有返回为true的异常
class NotSuccessException implements Exception {
  String message = "";
  int code = 0;

  NotSuccessException.fromRespData(BaseResponseData respData) {
    message = respData.message;
    code = respData.code;
  }

  @override
  String toString() {
    return 'NotExpectedException{respData: $message}';
  }
}
