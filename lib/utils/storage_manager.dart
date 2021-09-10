import 'dart:convert';

import 'package:fanmi/entity/card_info_entity.dart';
import 'package:fanmi/entity/mine_board_entity.dart';
import 'package:fanmi/entity/user_info_entity.dart';
import 'package:fanmi/entity/relation_entity.dart';
import 'package:fanmi/generated/json/card_info_entity_helper.dart';
import 'package:fanmi/generated/json/mine_board_entity_helper.dart';
import 'package:fanmi/generated/json/relation_entity_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fanmi/generated/json/user_info_entity_helper.dart';

class StorageManager {
  static late SharedPreferences sp;

  /// 键名
  static const uidKey = 'uidKey';
  static const userKey = 'userKey';
  static const cardListKey = 'cardListKey';
  static const timUserSigKey = 'timUserSigKey';
  static const boardDataKey = 'boardDataKey';
  static const relationListKey = 'relationListKey';
  static String regId = '';

  static get isLogin => sp.getInt(uidKey) != null;

  static get uid => sp.getInt(uidKey);

  static init() async {
    sp = await SharedPreferences.getInstance();
  }

  static setUid(int uid) async {
    await sp.setInt(uidKey, uid);
  }

  static UserInfoEntity getUserInfo() {
    UserInfoEntity userInfoEntity = userInfoEntityFromJson(
        UserInfoEntity(), json.decode(sp.getString(userKey)!));
    return userInfoEntity;
  }

  static setUserInfo(UserInfoEntity userInfoEntity) async {
    await sp.setString(
        userKey, json.encode(userInfoEntityToJson(userInfoEntity)));
  }

  static String getTimUserSig() {
    return sp.getString(timUserSigKey)!;
  }

  static setTimUserSig(String sig) async {
    await sp.setString(timUserSigKey, sig);
  }

  static List<CardInfoEntity> getCardListInfo() {
    var cardStringList = sp.getStringList(cardListKey) ?? [];
    return cardStringList
        .map((cardString) =>
            cardInfoEntityFromJson(CardInfoEntity(), json.decode(cardString))
                as CardInfoEntity)
        .toList();
  }

  static setCardListInfo(List<CardInfoEntity> cardList) async {
    await sp.setStringList(
        cardListKey,
        cardList
            .map((card) => json.encode(cardInfoEntityToJson(card)))
            .toList());
  }

  static MineBoardEntity getBoardData() {
    var boardDataStr = sp.getString(boardDataKey)!;
    return mineBoardEntityFromJson(
        MineBoardEntity(), json.decode(boardDataStr));
  }

  static setBoardData(MineBoardEntity data) async {
    await sp.setString(boardDataKey, json.encode(mineBoardEntityToJson(data)));
  }

  static List<RelationEntity> getRelationList() {
    var relationStringList = sp.getStringList(relationListKey) ?? [];
    return relationStringList
        .map((relationString) => relationEntityFromJson(
            RelationEntity(), json.decode(relationString)) as RelationEntity)
        .toList();
  }

  static setRelationList(List<RelationEntity> relationList) async {
    await sp.setStringList(
        relationListKey,
        relationList
            .map((relation) => json.encode(relationEntityToJson(relation)))
            .toList());
  }

  static clear() {
    sp.remove(uidKey);
    sp.remove(userKey);
    sp.remove(cardListKey);
    sp.remove(timUserSigKey);
    sp.remove(relationListKey);
  }
}
