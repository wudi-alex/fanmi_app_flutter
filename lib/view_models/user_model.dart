import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class UserModel extends ChangeNotifier {
  V2TimUserFullInfo _userTimInfo = V2TimUserFullInfo();

  init() {}

  setUser() {
    notifyListeners();
  }

  setUserTimInfo(V2TimUserFullInfo newInfo) {
    _userTimInfo = newInfo;
    notifyListeners();
  }

  clear() {
    notifyListeners();
  }
}
