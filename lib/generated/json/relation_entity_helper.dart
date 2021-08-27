import 'package:fanmi/enums/relation_entity.dart';

relationEntityFromJson(RelationEntity data, Map<String, dynamic> json) {
	if (json['add_card_id'] != null) {
		data.addCardId = json['add_card_id'] is String
				? int.tryParse(json['add_card_id'])
				: json['add_card_id'].toInt();
	}
	if (json['add_card_type'] != null) {
		data.addCardType = json['add_card_type'] is String
				? int.tryParse(json['add_card_type'])
				: json['add_card_type'].toInt();
	}
	if (json['birth_date'] != null) {
		data.birthDate = json['birth_date'].toString();
	}
	if (json['city'] != null) {
		data.city = json['city'].toString();
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
	if (json['is_applicant'] != null) {
		data.isApplicant = json['is_applicant'] is String
				? int.tryParse(json['is_applicant'])
				: json['is_applicant'].toInt();
	}
	if (json['last_login_time'] != null) {
		data.lastLoginTime = json['last_login_time'].toString();
	}
	if (json['status'] != null) {
		data.status = json['status'] is String
				? int.tryParse(json['status'])
				: json['status'].toInt();
	}
	if (json['t_avatar'] != null) {
		data.tAvatar = json['t_avatar'].toString();
	}
	if (json['t_name'] != null) {
		data.tName = json['t_name'].toString();
	}
	if (json['t_qq'] != null) {
		data.tQq = json['t_qq'].toString();
	}
	if (json['t_wx'] != null) {
		data.tWx = json['t_wx'].toString();
	}
	if (json['target_card_id'] != null) {
		data.targetCardId = json['target_card_id'] is String
				? int.tryParse(json['target_card_id'])
				: json['target_card_id'].toInt();
	}
	if (json['target_card_type'] != null) {
		data.targetCardType = json['target_card_type'] is String
				? int.tryParse(json['target_card_type'])
				: json['target_card_type'].toInt();
	}
	if (json['target_uid'] != null) {
		data.targetUid = json['target_uid'] is String
				? int.tryParse(json['target_uid'])
				: json['target_uid'].toInt();
	}
	if (json['u_avatar'] != null) {
		data.uAvatar = json['u_avatar'].toString();
	}
	if (json['u_name'] != null) {
		data.uName = json['u_name'].toString();
	}
	if (json['u_qq'] != null) {
		data.uQq = json['u_qq'].toString();
	}
	if (json['u_wx'] != null) {
		data.uWx = json['u_wx'].toString();
	}
	if (json['uid'] != null) {
		data.uid = json['uid'] is String
				? int.tryParse(json['uid'])
				: json['uid'].toInt();
	}
	if (json['user_status'] != null) {
		data.userStatus = json['user_status'] is String
				? int.tryParse(json['user_status'])
				: json['user_status'].toInt();
	}
	return data;
}

Map<String, dynamic> relationEntityToJson(RelationEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['add_card_id'] = entity.addCardId;
	data['add_card_type'] = entity.addCardType;
	data['birth_date'] = entity.birthDate;
	data['city'] = entity.city;
	data['gender'] = entity.gender;
	data['id'] = entity.id;
	data['is_applicant'] = entity.isApplicant;
	data['last_login_time'] = entity.lastLoginTime;
	data['status'] = entity.status;
	data['t_avatar'] = entity.tAvatar;
	data['t_name'] = entity.tName;
	data['t_qq'] = entity.tQq;
	data['t_wx'] = entity.tWx;
	data['target_card_id'] = entity.targetCardId;
	data['target_card_type'] = entity.targetCardType;
	data['target_uid'] = entity.targetUid;
	data['u_avatar'] = entity.uAvatar;
	data['u_name'] = entity.uName;
	data['u_qq'] = entity.uQq;
	data['u_wx'] = entity.uWx;
	data['uid'] = entity.uid;
	data['user_status'] = entity.userStatus;
	return data;
}