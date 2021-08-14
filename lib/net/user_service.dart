import 'package:fanmi/utils/storage_manager.dart';

import 'http_client.dart';

class UserService {
  static Future getUserInfo() async {
    var resp = await http
        .post('/user/get_user_info', data: {"uid": StorageManager.uid});
    return resp;
  }

  static Future setUserInfo(Map userDict) async {
    var resp = await http.post('/user/set_user_info',
        data: {"uid": StorageManager.uid, "user_dict": userDict});
    return resp;
  }

  static Future regUserInfo(Map userDict) async {
    var resp = await http.post('/user/reg_user_info',
        data: {"uid": StorageManager.uid, "user_dict": userDict});
    return resp;
  }
}
