import 'package:fanmi/entity/board_item_entity.dart';
import 'package:fanmi/entity/card_preview_entity.dart';
import 'package:fanmi/entity/contact_entity.dart';
import 'package:fanmi/generated/json/board_item_entity_helper.dart';
import 'package:fanmi/generated/json/card_preview_entity_helper.dart';
import 'package:fanmi/generated/json/contact_entity_helper.dart';
import 'package:fanmi/utils/platform_utils.dart';
import 'package:fanmi/utils/storage_manager.dart';

import 'http_client.dart';

class UserService {

  static Future getUserInfo() async {
    print(StorageManager.regId);
    String deviceInfo = await PlatformUtils.getDeviceInfo();
    var resp = await http.post('/user/get_user_info', data: {
      "uid": StorageManager.uid,
      "platform": Platform.operatingSystem,
      "device": deviceInfo,
      "reg_id":StorageManager.regId,
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

  static Future getContactList(int? page) async {
    var resp = await http.post('/user/get_contact_list',
        data: {"uid": StorageManager.uid, "page": page});
    return resp.data
        .map<ContactEntity>((item) =>
            contactEntityFromJson(ContactEntity(), item) as ContactEntity)
        .toList();
  }

  static Future getFavorList(int? page) async {
    var resp = await http.post('/user/get_favor_list',
        data: {"uid": StorageManager.uid, "page": page});
    return resp.data
        .map<CardPreviewEntity>((item) =>
            cardPreviewEntityFromJson(CardPreviewEntity(), item)
                as CardPreviewEntity)
        .toList();
  }

  static Future getBoardList(int? page) async {
    var resp = await http.post('/user/get_board_list',
        data: {"uid": StorageManager.uid, "page": page});
    return resp.data
        .map<BoardItemEntity>((item) =>
            boardItemEntityFromJson(BoardItemEntity(), item) as BoardItemEntity)
        .toList();
  }

  static Future deleteUserAccount() async {
    var resp = await http
        .post('/user/delete_user_account', data: {"uid": StorageManager.uid});
    return resp;
  }
}
