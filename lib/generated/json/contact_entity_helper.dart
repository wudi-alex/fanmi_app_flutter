import 'package:fanmi/entity/contact_entity.dart';

contactEntityFromJson(ContactEntity data, Map<String, dynamic> json) {
	if (json['avatar'] != null) {
		data.avatar = json['avatar'].toString();
	}
	if (json['card_id'] != null) {
		data.cardId = json['card_id'] is String
				? int.tryParse(json['card_id'])
				: json['card_id'].toInt();
	}
	if (json['name'] != null) {
		data.name = json['name'].toString();
	}
	if (json['qq'] != null) {
		data.qq = json['qq'].toString();
	}
	if (json['uid'] != null) {
		data.uid = json['uid'] is String
				? int.tryParse(json['uid'])
				: json['uid'].toInt();
	}
	if (json['wx'] != null) {
		data.wx = json['wx'].toString();
	}
	return data;
}

Map<String, dynamic> contactEntityToJson(ContactEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['avatar'] = entity.avatar;
	data['card_id'] = entity.cardId;
	data['name'] = entity.name;
	data['qq'] = entity.qq;
	data['uid'] = entity.uid;
	data['wx'] = entity.wx;
	return data;
}