import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class UserModel extends ChangeNotifier {
  V2TimUserFullInfo userTimInfo = V2TimUserFullInfo();

  setUser() {
    notifyListeners();
  }

  setUserTimInfo(V2TimUserFullInfo newInfo) {
    userTimInfo = newInfo;
    notifyListeners();
  }

  clear() {
    notifyListeners();
  }
}
