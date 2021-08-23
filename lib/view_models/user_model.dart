import 'package:fanmi/entity/mine_board_entity.dart';
import 'package:fanmi/entity/user_info_entity.dart';
import 'package:fanmi/enums/user_status_enum.dart';
import 'package:fanmi/generated/json/mine_board_entity_helper.dart';
import 'package:fanmi/net/user_service.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:fanmi/generated/json/user_info_entity_helper.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class UserModel extends ChangeNotifier {
  V2TimUserFullInfo userTimInfo = V2TimUserFullInfo();
  UserInfoEntity userInfo = UserInfoEntity();
  MineBoardEntity boardEntity = MineBoardEntity();
  String timSig = "";

  init() async {
    var userInfo = UserInfoEntity();
    try {
      var resp = await UserService.getUserInfo();
      UserInfoEntity userInfoResp =
          userInfoEntityFromJson(UserInfoEntity(), resp.data['user']!);
      userInfo = userInfoResp;
      //更新im签名
      timSig = resp.data['tim_sig'];
      //更新面板数据
      var boardResp = await UserService.getMineBoardData();
      setMineBoard(mineBoardEntityFromJson(MineBoardEntity(), boardResp.data));
    } catch (e, s) {
      setMineBoard(StorageManager.getBoardData());
      timSig = StorageManager.getTimUserSig();
      userInfo = StorageManager.getUserInfo();
    } finally {
      ///tim登录
      TencentImSDKPlugin.v2TIMManager
          .login(
        userID: StorageManager.uid.toString(),
        userSig: timSig,
      ).then((v) {
        setUserInfo(userInfo);
        StorageManager.setUserInfo(userInfo);
        StorageManager.setTimUserSig(timSig);
      });
    }
  }

  setUserTimInfo(V2TimUserFullInfo newInfo) async {
    userTimInfo = newInfo;
    notifyListeners();
  }

  setUserInfo(UserInfoEntity newInfo) async {
    userInfo = newInfo;
    StorageManager.setUserInfo(newInfo);
    //更新timinfo
    userTimInfo = V2TimUserFullInfo.fromJson({
      "userId": newInfo.uid.toString(),
      "nickName": newInfo.name,
      "faceUrl": newInfo.avatarUrl,
      "gender": newInfo.gender,
      "customInfo": {
        'Tag_Profile_Custom_City': newInfo.city,
        "Tag_Profile_Custom_Birth": newInfo.birthDate,
        "Tag_Profile_Custom_LLT": newInfo.lastLoginTime,
        "Tag_Profile_Custom_Status": newInfo.userStatus.toString(),
      },
    });
    await TencentImSDKPlugin.v2TIMManager.setSelfInfo(
      userFullInfo: userTimInfo,
    );
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
    timSig = "";
    notifyListeners();
  }

  get userStatus =>
      userTimInfo.customInfo!["Tag_Profile_Custom_Status"] ??
      UserStatusEnum.USER_STATUS_NORMAL;
}
