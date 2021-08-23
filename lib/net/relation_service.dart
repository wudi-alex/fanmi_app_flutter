import 'package:fanmi/net/http_client.dart';
import 'package:fanmi/utils/storage_manager.dart';

class RelationService {
  static Future addRelation({
    required int targetUid,
    required int targetCardId,
    required int targetCardType,
    int? addCardId,
    int? addCardType,
    required String uAvatar,
    required String uName,
    required String tAvatar,
    required String tName,
    String? uWx,
    String? uQq,
    String? tWx,
    String? tQq,
  }) async {
    var resp = await http.post('/relation/add_relation', data: {
      "uid": StorageManager.uid,
      "target_uid": targetUid,
      "target_card_id": targetCardId,
      "target_card_type": targetCardType,
      "add_card_id": addCardId,
      "add_card_type": addCardType,
      "u_avatar": uAvatar,
      "u_name": uName,
      "t_avatar": tAvatar,
      "t_name": tName,
      "u_wx": uWx,
      "u_qq": uQq,
      "t_wx": tWx,
      "t_qq": tQq,
    });
    return resp;
  }
}
