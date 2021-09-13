import 'package:fanmi/entity/card_info_entity.dart';

cardInfoEntityFromJson(CardInfoEntity data, Map<String, dynamic> json) {
	if (json['album'] != null) {
		data.album = json['album'].toString();
	}
	if (json['avatar_url'] != null) {
		data.avatarUrl = json['avatar_url'].toString();
	}
	if (json['birth_date'] != null) {
		data.birthDate = json['birth_date'].toString();
	}
	if (json['card_favor_num'] != null) {
		data.cardFavorNum = json['card_favor_num'] is String
				? int.tryParse(json['card_favor_num'])
				: json['card_favor_num'].toInt();
	}
	if (json['card_status'] != null) {
		data.cardStatus = json['card_status'] is String
				? int.tryParse(json['card_status'])
				: json['card_status'].toInt();
	}
	if (json['city'] != null) {
		data.city = json['city'].toString();
	}
	if (json['click_num'] != null) {
		data.clickNum = json['click_num'] is String
				? int.tryParse(json['click_num'])
				: json['click_num'].toInt();
	}
	if (json['cover_url'] != null) {
		data.coverUrl = json['cover_url'].toString();
	}
	if (json['create_time'] != null) {
		data.createTime = json['create_time'].toString();
	}
	if (json['exposure_num'] != null) {
		data.exposureNum = json['exposure_num'] is String
				? int.tryParse(json['exposure_num'])
				: json['exposure_num'].toInt();
	}
	if (json['gender'] != null) {
		data.gender = json['gender'] is String
				? int.tryParse(json['gender'])
				: json['gender'].toInt();
	}
	if (json['id'] != null) {
		data.id = json['id'] is String
				? int.tryParse(json['id'])
				: json['id'].toInt();
	}
	if (json['is_exposure_contact'] != null) {
		data.isExposureContact = json['is_exposure_contact'] is String
				? int.tryParse(json['is_exposure_contact'])
				: json['is_exposure_contact'].toInt();
	}
	if (json['is_exposure_data'] != null) {
		data.isExposureData = json['is_exposure_data'] is String
				? int.tryParse(json['is_exposure_data'])
				: json['is_exposure_data'].toInt();
	}
	if (json['is_favored'] != null) {
		data.isFavored = json['is_favored'] is String
				? int.tryParse(json['is_favored'])
				: json['is_favored'].toInt();
	}
	if (json['is_need_card'] != null) {
		data.isNeedCard = json['is_need_card'] is String
				? int.tryParse(json['is_need_card'])
				: json['is_need_card'].toInt();
	}
	if (json['name'] != null) {
		data.name = json['name'].toString();
	}
	if (json['qq_qr_url'] != null) {
		data.qqQrUrl = json['qq_qr_url'].toString();
	}
	if (json['relation_is_applicant'] != null) {
		data.relationIsApplicant = json['relation_is_applicant'] is String
				? int.tryParse(json['relation_is_applicant'])
				: json['relation_is_applicant'].toInt();
	}
	if (json['relation_name'] != null) {
		data.relationName = json['relation_name'].toString();
	}
	if (json['relation_status'] != null) {
		data.relationStatus = json['relation_status'] is String
				? int.tryParse(json['relation_status'])
				: json['relation_status'].toInt();
	}
	if (json['search_num'] != null) {
		data.searchNum = json['search_num'] is String
				? int.tryParse(json['search_num'])
				: json['search_num'].toInt();
	}
	if (json['self_desc'] != null) {
		data.selfDesc = json['self_desc'].toString();
	}
	if (json['sign'] != null) {
		data.sign = json['sign'].toString();
	}
	if (json['type'] != null) {
		data.type = json['type'] is String
				? int.tryParse(json['type'])
				: json['type'].toInt();
	}
	if (json['uid'] != null) {
		data.uid = json['uid'] is String
				? int.tryParse(json['uid'])
				: json['uid'].toInt();
	}
	if (json['update_time'] != null) {
		data.updateTime = json['update_time'].toString();
	}
	if (json['wx_qr_url'] != null) {
		data.wxQrUrl = json['wx_qr_url'].toString();
	}
	return data;
}

Map<String, dynamic> cardInfoEntityToJson(CardInfoEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['album'] = entity.album;
	data['avatar_url'] = entity.avatarUrl;
	data['birth_date'] = entity.birthDate;
	data['card_favor_num'] = entity.cardFavorNum;
	data['card_status'] = entity.cardStatus;
	data['city'] = entity.city;
	data['click_num'] = entity.clickNum;
	data['cover_url'] = entity.coverUrl;
	data['create_time'] = entity.createTime;
	data['exposure_num'] = entity.exposureNum;
	data['gender'] = entity.gender;
	data['id'] = entity.id;
	data['is_exposure_contact'] = entity.isExposureContact;
	data['is_exposure_data'] = entity.isExposureData;
	data['is_favored'] = entity.isFavored;
	data['is_need_card'] = entity.isNeedCard;
	data['name'] = entity.name;
	data['qq_qr_url'] = entity.qqQrUrl;
	data['relation_is_applicant'] = entity.relationIsApplicant;
	data['relation_name'] = entity.relationName;
	data['relation_status'] = entity.relationStatus;
	data['search_num'] = entity.searchNum;
	data['self_desc'] = entity.selfDesc;
	data['sign'] = entity.sign;
	data['type'] = entity.type;
	data['uid'] = entity.uid;
	data['update_time'] = entity.updateTime;
	data['wx_qr_url'] = entity.wxQrUrl;
	return data;
}