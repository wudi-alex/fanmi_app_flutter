import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// 网络请求工具类
class HttpUtils {
  HttpUtils._internal();

  static late Dio sDio;

  ///全局初始化
  static init(
      {String? baseUrl,
      int timeout = 500000,
      Map<String, dynamic>? headers}) {
    sDio = Dio(BaseOptions(
        connectTimeout: timeout,
        headers: headers));
  }

  ///error统一处理
  static void handleError(DioError e) {
    switch (e.type) {
      case DioErrorType.connectTimeout:
        showError("连接超时");
        break;
      case DioErrorType.sendTimeout:
        showError("请求超时");
        break;
      case DioErrorType.receiveTimeout:
        showError("响应超时");
        break;
      case DioErrorType.response:
        showError("出现异常");
        break;
      case DioErrorType.cancel:
        showError("请求取消");
        break;
      default:
        showError("未知错误");
        break;
    }
  }

  static void showError(String error) {
    print(error);
    // SmartDialog.showToast(error);
  }

  ///get请求
  static Future get(String url, [Map<String, dynamic>? params]) async {
    Response response;
    if (params != null) {
      response = await sDio.get(url, queryParameters: params);
    } else {
      response = await sDio.get(url);
    }
    return response.data;
  }

  ///下载文件
  static Future downloadFile(String urlPath, String savePath,
      {ProgressCallback? onReceiveProgress}) async {
    Response response = await sDio.download(urlPath, savePath,
        onReceiveProgress: onReceiveProgress,);
    return response;
  }
}
