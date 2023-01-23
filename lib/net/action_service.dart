import 'package:fanmi/utils/storage_manager.dart';

import 'http_client.dart';

class ActionService {
  static Future addAction(
      {required int cardId,
      required int cardType,
      required int targetUid,
      required int actionType}) async {
    var resp = await http.post('/action/add_action', data: {
      "uid": StorageManager.uid,
      "card_id": cardId,
      "card_type": cardType,
      "target_uid": targetUid,
      "action_type": actionType
    });
    return resp;
  }

  static Future addFavor({
    required int cardId,
    required int cardType,
    required int targetUid,
  }) async {
    var resp = await http.post('/action/add_favor', data: {
      "uid": StorageManager.uid,
      "card_id": cardId,
      "card_type": cardType,
      "target_uid": targetUid,
    });
    return resp;
  }

  static Future cancelFavor({
    required int cardId,
  }) async {
    var resp = await http.post('/action/cancel_favor', data: {
      "uid": StorageManager.uid,
      "card_id": cardId,
    });
    return resp;
  }
}
