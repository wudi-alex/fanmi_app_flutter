import 'package:fanmi/entity/card_info_entity.dart';
import 'package:fanmi/generated/json/card_info_entity_helper.dart';
import 'package:fanmi/net/card_service.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:flutter/cupertino.dart';

class CardListModel extends ChangeNotifier {
  Map<int, CardInfoEntity> cardMap = Map();

  get cardList => cardMap.values;

  init() async {
    List<CardInfoEntity> list = [];
    try {
      var resp = await CardService.getCardList();
      list = resp.data
          .map<CardInfoEntity>((item) =>
              cardInfoEntityFromJson(CardInfoEntity(), item) as CardInfoEntity)
          .toList();
      StorageManager.setCardListInfo(list);
    } catch (e, s) {
      print(e);
      list = StorageManager.getCardListInfo();
    }
    list.forEach((card) {
      cardMap[card.type!] = card;
    });
  }

  //todo：
  setCard(int type) async {
    var card = cardMap[type]!;
    try {
      await CardService.setCardInfo(
          cardId: card.id,
          cardType: card.type!,
          cardDict: cardInfoEntityToJson(card));
    } catch (e, s) {

    }
    notifyListeners();
  }

  clear() {

  }
}
