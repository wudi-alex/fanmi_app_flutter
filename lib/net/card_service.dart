import 'dart:convert';

import 'package:fanmi/entity/card_preview_entity.dart';
import 'package:fanmi/generated/json/card_preview_entity_helper.dart';

import 'http_client.dart';

class CardService {
  static Future<CardPreviewEntity> getCardPreview({required int cardId}) async {
    var resp =
        await http.post('/card/get_card_preview', data: {"card_id": cardId});
    return cardPreviewEntityFromJson(
        CardPreviewEntity(), json.decode(resp.data));
  }
}
