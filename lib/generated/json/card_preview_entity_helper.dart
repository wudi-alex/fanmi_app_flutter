import 'package:fanmi/entity/card_preview_entity.dart';

cardPreviewEntityFromJson(CardPreviewEntity data, Map<String, dynamic> json) {
	if (json['avatar_url'] != null) {
		data.avatarUrl = json['avatar_url'].toString();
	}
	if (json['birth_date'] != null) {
		data.birthDate = json['birth_date'].toString();
	}
	if (json['album'] != null) {
		data.album = json['album'].toString();
	}
	if (json['id'] != null) {
		data.id = json['id'] is String
				? int.tryParse(json['id'])
				: json['id'].toInt();
	}
	if (json['desc'] != null) {
		data.desc = json['desc'].toString();
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
	if (json['city'] != null) {
		data.city = json['city'].toString();
	}
	if (json['gender'] != null) {
		data.gender = json['gender'] is String
				? int.tryParse(json['gender'])
				: json['gender'].toInt();
	}
	if (json['last_login_time'] != null) {
		data.lastLoginTime = json['last_login_time'].toString();
	}
	if (json['name'] != null) {
		data.name = json['name'].toString();
	}
	if (json['sign'] != null) {
		data.sign = json['sign'].toString();
	}
	if (json['create_time'] != null) {
		data.createTime = json['create_time'].toString();
	}
	if (json['update_time'] != null) {
		data.updateTime = json['update_time'].toString();
	}
	return data;
}

Map<String, dynamic> cardPreviewEntityToJson(CardPreviewEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['avatar_url'] = entity.avatarUrl;
	data['birth_date'] = entity.birthDate;
	data['album'] = entity.album;
	data['id'] = entity.id;
	data['desc'] = entity.desc;
	data['type'] = entity.type;
	data['uid'] = entity.uid;
	data['city'] = entity.city;
	data['gender'] = entity.gender;
	data['last_login_time'] = entity.lastLoginTime;
	data['name'] = entity.name;
	data['sign'] = entity.sign;
	data['create_time'] = entity.createTime;
	data['update_time'] = entity.updateTime;
	return data;
}