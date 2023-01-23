import 'package:fanmi/entity/board_item_entity.dart';

boardItemEntityFromJson(BoardItemEntity data, Map<String, dynamic> json) {
	if (json['action_type'] != null) {
		data.actionType = json['action_type'] is String
				? int.tryParse(json['action_type'])
				: json['action_type'].toInt();
	}
	if (json['avatar_url'] != null) {
		data.avatarUrl = json['avatar_url'].toString();
	}
	if (json['card_id'] != null) {
		data.cardId = json['card_id'] is String
				? int.tryParse(json['card_id'])
				: json['card_id'].toInt();
	}
	if (json['card_type'] != null) {
		data.cardType = json['card_type'] is String
				? int.tryParse(json['card_type'])
				: json['card_type'].toInt();
	}
	if (json['create_time'] != null) {
		data.createTime = json['create_time'].toString();
	}
	if (json['gender'] != null) {
		data.gender = json['gender'] is String
				? int.tryParse(json['gender'])
				: json['gender'].toInt();
	}
	if (json['name'] != null) {
		data.name = json['name'].toString();
	}
	if (json['search_word'] != null) {
		data.searchWord = json['search_word'].toString();
	}
	if (json['uid'] != null) {
		data.uid = json['uid'] is String
				? int.tryParse(json['uid'])
				: json['uid'].toInt();
	}
	return data;
}

Map<String, dynamic> boardItemEntityToJson(BoardItemEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['action_type'] = entity.actionType;
	data['avatar_url'] = entity.avatarUrl;
	data['card_id'] = entity.cardId;
	data['card_type'] = entity.cardType;
	data['create_time'] = entity.createTime;
	data['gender'] = entity.gender;
	data['name'] = entity.name;
	data['search_word'] = entity.searchWord;
	data['uid'] = entity.uid;
	return data;
}