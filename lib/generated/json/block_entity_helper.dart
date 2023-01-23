import 'package:fanmi/entity/block_entity.dart';

blockEntityFromJson(BlockEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id'] is String
				? int.tryParse(json['id'])
				: json['id'].toInt();
	}
	if (json['uid'] != null) {
		data.uid = json['uid'] is String
				? int.tryParse(json['uid'])
				: json['uid'].toInt();
	}
	if (json['blocked_uid'] != null) {
		data.blockedUid = json['blocked_uid'] is String
				? int.tryParse(json['blocked_uid'])
				: json['blocked_uid'].toInt();
	}
	if (json['blocked_card_id'] != null) {
		data.blockedCardId = json['blocked_card_id'] is String
				? int.tryParse(json['blocked_card_id'])
				: json['blocked_card_id'].toInt();
	}
	if (json['blocked_avatar'] != null) {
		data.blockedAvatar = json['blocked_avatar'].toString();
	}
	if (json['blocked_name'] != null) {
		data.blockedName = json['blocked_name'].toString();
	}
	if (json['status'] != null) {
		data.status = json['status'] is String
				? int.tryParse(json['status'])
				: json['status'].toInt();
	}
	if (json['create_time'] != null) {
		data.createTime = json['create_time'].toString();
	}
	if (json['update_time'] != null) {
		data.updateTime = json['update_time'].toString();
	}
	return data;
}

Map<String, dynamic> blockEntityToJson(BlockEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['uid'] = entity.uid;
	data['blocked_uid'] = entity.blockedUid;
	data['blocked_card_id'] = entity.blockedCardId;
	data['blocked_avatar'] = entity.blockedAvatar;
	data['blocked_name'] = entity.blockedName;
	data['status'] = entity.status;
	data['create_time'] = entity.createTime;
	data['update_time'] = entity.updateTime;
	return data;
}