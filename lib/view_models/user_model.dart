import 'package:fanmi/entity/mine_board_entity.dart';
import 'package:fanmi/entity/user_info_entity.dart';
import 'package:fanmi/generated/json/mine_board_entity_helper.dart';
import 'package:fanmi/net/user_service.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:fanmi/generated/json/user_info_entity_helper.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class UserModel extends ChangeNotifier {
  V2TimUserFullInfo userTimInfo = V2TimUserFullInfo();
  UserInfoEntity userInfo = UserInfoEntity();
  MineBoardEntity boardEntity = MineBoardEntity();

  Future<String> init() async {
    try {
      var uid = StorageManager.uid;
      var resp = await UserService.getUserInfo();
      UserInfoEntity userInfo =
          userInfoEntityFromJson(UserInfoEntity(), resp.data['user']!);
      setUserInfo(userInfo);
      StorageManager.setUserInfo(userInfo);
      //更新im签名
      StorageManager.setTimUserSig(resp.data['tim_sig']);
      V2TimValueCallback<List<V2TimUserFullInfo>> infos =
          await TencentImSDKPlugin.v2TIMManager.getUsersInfo(userIDList: [uid.toString()]);
      if (infos.code == 0) {
        setUserTimInfo(infos.data![0]);
      }
      //更新面板数据
      var boardResp = await UserService.getMineBoardData();
      setMineBoard(mineBoardEntityFromJson(MineBoardEntity(), boardResp.data));
      return resp.data['tim_sig'];
    } catch (e, s) {
      setUserInfo(StorageManager.getUserInfo());
      setMineBoard(StorageManager.getBoardData());
      return StorageManager.getTimUserSig();
    }
  }

  setUserTimInfo(V2TimUserFullInfo newTimInfo) {
    userTimInfo = newTimInfo;
    notifyListeners();
  }

  setUserInfo(UserInfoEntity newInfo) {
    userInfo = newInfo;
    StorageManager.setUserInfo(newInfo);
    notifyListeners();
  }

  setMineBoard(MineBoardEntity data) {
    boardEntity = data;
    StorageManager.setBoardData(data);
    notifyListeners();
  }

  clear() {
    userTimInfo = V2TimUserFullInfo();
    userInfo = UserInfoEntity();
    boardEntity = MineBoardEntity();
    notifyListeners();
  }
}
