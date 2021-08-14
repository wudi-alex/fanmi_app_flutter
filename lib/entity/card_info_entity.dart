import 'package:fanmi/generated/json/base/json_convert_content.dart';
import 'package:fanmi/generated/json/base/json_field.dart';

class CardInfoEntity with JsonConvert<CardInfoEntity> {
  String? album;
  @JSONField(name: "avatar_url")
  String? avatarUrl;
  @JSONField(name: "card_favor_num")
  int? cardFavorNum;
  @JSONField(name: "card_status")
  int? cardStatus;
  @JSONField(name: "click_num")
  int? clickNum;
  @JSONField(name: "cover_url")
  String? coverUrl;
  @JSONField(name: "create_time")
  String? createTime;
  @JSONField(name: "exposure_num")
  int? exposureNum;
  int? id;
  @JSONField(name: "is_exposure_contact")
  int? isExposureContact;
  @JSONField(name: "is_exposure_data")
  int? isExposureData;
  @JSONField(name: "is_favored")
  int? isFavored;
  @JSONField(name: "is_need_card")
  int? isNeedCard;
  String? name;
  @JSONField(name: "qq_qr_url")
  String? qqQrUrl;
  @JSONField(name: "search_num")
  int? searchNum;
  @JSONField(name: "self_desc")
  String? selfDesc;
  String? sign;
  int? type;
  int? uid;
  @JSONField(name: "update_time")
  String? updateTime;
  @JSONField(name: "wx_qr_url")
  String? wxQrUrl;

  equal(CardInfoEntity card) {
    return id == card.id &&
        album == card.album &&
        avatarUrl == card.avatarUrl &&
        cardStatus == card.cardStatus &&
        coverUrl == card.coverUrl &&
        isExposureContact == card.isExposureContact &&
        isExposureData == card.isExposureData &&
        isFavored == card.isFavored &&
        isNeedCard == card.isNeedCard &&
        name == card.name &&
        qqQrUrl == card.qqQrUrl &&
        selfDesc == card.selfDesc &&
        sign == card.sign &&
        type == card.type &&
        uid == card.uid &&
        wxQrUrl == card.wxQrUrl;
  }
}
