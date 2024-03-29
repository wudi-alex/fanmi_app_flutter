import 'package:fanmi/utils/platform_utils.dart';
import 'package:fanmi/utils/storage_manager.dart';

import 'http_client.dart';

class LoginService {
  static Future weixinLogin({required String code}) async {
    String deviceInfo = await PlatformUtils.getDeviceInfo();
    var resp = await http.post('/login/weixin_login', data: {
      "code": code,
      "platform": Platform.operatingSystem,
      "device": deviceInfo,
      "reg_id":StorageManager.regId,
    });
    return resp;
  }

  static Future qqLogin(
      {required String openId,
      required String name,
      required String avatarUrl}) async {
    String deviceInfo = await PlatformUtils.getDeviceInfo();
    var resp = await http.post('/login/qq_login', data: {
      "open_id": openId,
      "name": name,
      "avatar_url": avatarUrl,
      "platform": Platform.operatingSystem,
      "device": deviceInfo,
      "reg_id":StorageManager.regId,
    });
    return resp;
  }

  static Future appleLogin(
      {required String userIdentifier, String? name, String? mail}) async {
    String deviceInfo = await PlatformUtils.getDeviceInfo();
    var resp = await http.post('/login/apple_login', data: {
      "user_identifier": userIdentifier,
      "name": name,
      "platform": Platform.operatingSystem,
      "device": deviceInfo,
      "reg_id":StorageManager.regId,
    });
    return resp;
  }

  static Future emailLogin({
    required String email,
    required String emailPassword,
  }) async {
    String deviceInfo = await PlatformUtils.getDeviceInfo();
    var resp = await http.post('/login/email_login', data: {
      "email": email,
      "email_password": emailPassword,
      "platform": Platform.operatingSystem,
      "device": deviceInfo,
      "reg_id":StorageManager.regId,
    });
    return resp;
  }

  static Future emailRegister({
    required String email,
    required String emailPassword,
  }) async {
    String deviceInfo = await PlatformUtils.getDeviceInfo();
    var resp = await http.post('/login/email_register', data: {
      "email": email,
      "email_password": emailPassword,
      "platform": Platform.operatingSystem,
      "device": deviceInfo,
      "reg_id":StorageManager.regId,
    });
    return resp;
  }

  static Future emailPasswordRecover({
    required String email,
  }) async {
    var resp = await http.post('/login/email_password_recover', data: {
      "email": email,
    });
    return resp;
  }
}
