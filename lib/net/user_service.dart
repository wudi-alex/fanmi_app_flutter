import 'package:fanmi/utils/platform_utils.dart';
import 'package:fanmi/utils/storage_manager.dart';

import 'http_client.dart';

class UserService {
  static Future getUserInfo() async {
    String deviceInfo = await PlatformUtils.getDeviceInfo();
    var resp = await http.post('/user/get_user_info', data: {
      "uid": StorageManager.uid,
      "platform": Platform.operatingSystem,
      "device": deviceInfo,
    });
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

  static Future getMineBoardData() async {
    var resp = await http
        .post('/user/get_mine_board_data', data: {"uid": StorageManager.uid});
    return resp;
  }
}
