import 'package:fanmi/entity/card_preview_entity.dart';
import 'package:fanmi/generated/json/card_preview_entity_helper.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:flutter/material.dart';
import 'http_client.dart';

class CardService {
  static Future getCardPreview({required int cardId}) async {
    var resp =
        await http.post('/card/get_card_preview', data: {"card_id": cardId});
    return resp;
  }

  static Future getCardInfo({required int cardId}) async {
    var resp = await http.post('/card/get_card_info',
        data: {"uid": StorageManager.uid, "card_id": cardId});
    return resp;
  }

  static Future setCardInfo(
      {required int? cardId,
      required int cardType,
      required Map cardDict}) async {
    var resp = await http.post('/card/set_card_info', data: {
      "uid": StorageManager.uid,
      "card_id": cardId,
      "card_type": cardType,
      "card_dict": cardDict,
    });
    return resp;
  }

  static Future deleteCard({required int cardId}) async {
    var resp = await http.post('/card/delete_card', data: {
      "uid": StorageManager.uid,
      "card_id": cardId,
    });
    return resp;
  }

  static Future getCardList() async {
    var resp = await http.post('/card/get_user_card_list', data: {
      "uid": StorageManager.uid,
    });
    return resp;
  }

  static Future<List<CardPreviewEntity>> cardSearch(
      {required String searchWord,
      required int rankType,
      int? cardFilter,
      int? genderFilter,
      required int page}) async {
    var resp = await http.post('/card/search', data: {
      "uid": StorageManager.uid,
      "search_word": searchWord,
      "rank_type": rankType,
      "card_filter": cardFilter,
      "gender_filter": genderFilter,
      "page": page,
    });
    return resp.data
        .map<CardPreviewEntity>((item) =>
            cardPreviewEntityFromJson(CardPreviewEntity(), item)
                as CardPreviewEntity)
        .toList();
  }

  static Future<List<CardPreviewEntity>> cardRec(
      {required int rankType,
      int? cardFilter,
      int? genderFilter,
      required int page}) async {
    var resp = await http.post('/card/rec', data: {
      "uid": StorageManager.uid,
      "rank_type": rankType,
      "card_filter": cardFilter,
      "gender_filter": genderFilter,
      "page": page,
    });
    return resp.data
        .map<CardPreviewEntity>((item) =>
            cardPreviewEntityFromJson(CardPreviewEntity(), item)
                as CardPreviewEntity)
        .toList();
  }
}
