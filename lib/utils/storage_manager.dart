import 'dart:convert';

import 'package:fanmi/entity/user_info_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fanmi/generated/json/user_info_entity_helper.dart';

class StorageManager {
  static late SharedPreferences sp;

  /// 键名
  static const uidKey = 'uidKey';
  static const userKey = 'userKey';
  static const loveCardKey = 'loveCardKey';
  static const friendCardKey = 'friendCardKey';
  static const skillCardKey = 'skillCardKey';
  static const helpCardKey = 'helpCardKey';
  static const groupCardKey = 'groupCardKey';
  static const boardDataKey = 'boardDataKey';
  static const timUserSigKey = 'timUserSigKey';

  static get isLogin => sp.getInt(uidKey) != null;

  static get uid => sp.getInt(uidKey);

  static init() async {
    sp = await SharedPreferences.getInstance();
  }

  static getUserInfo() {
    UserInfoEntity userInfoEntity = userInfoEntityFromJson(
        UserInfoEntity(), json.decode(sp.getString(userKey)!));
    return userInfoEntity;
  }

  static saveUserInfo(UserInfoEntity userInfoEntity) async {
    await sp.setString(
        userKey, json.encode(userInfoEntityToJson(userInfoEntity)));
  }

  static getTimUserSig() {
    return sp.getString(timUserSigKey)!;
  }

  static clear() {
    sp.remove(uidKey);
    sp.remove(userKey);
    sp.remove(loveCardKey);
    sp.remove(friendCardKey);
    sp.remove(skillCardKey);
    sp.remove(helpCardKey);
    sp.remove(groupCardKey);
    sp.remove(boardDataKey);
    sp.remove(timUserSigKey);
  }
}
