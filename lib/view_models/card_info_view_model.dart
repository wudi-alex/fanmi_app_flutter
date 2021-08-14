import 'package:fanmi/entity/card_info_entity.dart';
import 'package:fanmi/generated/json/card_info_entity_helper.dart';
import 'package:fanmi/net/card_service.dart';
import 'package:fanmi/view_models/view_state_model.dart';

class CardInfoViewModel extends ViewStateModel {
  final int cardId;
  late CardInfoEntity cardInfoEntity;

  CardInfoViewModel(this.cardId);

  initData() async {
    setBusy();
    CardService.getCardInfo(cardId: cardId).then((v) {
      cardInfoEntity = cardInfoEntityFromJson(CardInfoEntity(), v.data);
      setIdle();
    }).onError((e, s) {
      setError(e, s);
    });
  }
}
