import 'package:fanmi/entity/user_info_entity.dart';

userInfoEntityFromJson(UserInfoEntity data, Map<String, dynamic> json) {
	if (json['avatar_url'] != null) {
		data.avatarUrl = json['avatar_url'].toString();
	}
	if (json['birth_date'] != null) {
		data.birthDate = json['birth_date'].toString();
	}
	if (json['city'] != null) {
		data.city = json['city'].toString();
	}
	if (json['create_time'] != null) {
		data.createTime = json['create_time'].toString();
	}
	if (json['device'] != null) {
		data.device = json['device'].toString();
	}
	if (json['email'] != null) {
		data.email = json['email'].toString();
	}
	if (json['email_password'] != null) {
		data.emailPassword = json['email_password'].toString();
	}
	if (json['gender'] != null) {
		data.gender = json['gender'] is String
				? int.tryParse(json['gender'])
				: json['gender'].toInt();
	}
	if (json['last_login_time'] != null) {
		data.lastLoginTime = json['last_login_time'].toString();
	}
	if (json['login_platform'] != null) {
		data.loginPlatform = json['login_platform'].toString();
	}
	if (json['name'] != null) {
		data.name = json['name'].toString();
	}
	if (json['platform'] != null) {
		data.platform = json['platform'].toString();
	}
	if (json['province'] != null) {
		data.province = json['province'].toString();
	}
	if (json['qq_qr_url'] != null) {
		data.qqQrUrl = json['qq_qr_url'].toString();
	}
	if (json['uid'] != null) {
		data.uid = json['uid'] is String
				? int.tryParse(json['uid'])
				: json['uid'].toInt();
	}
	if (json['update_time'] != null) {
		data.updateTime = json['update_time'].toString();
	}
	if (json['user_status'] != null) {
		data.userStatus = json['user_status'] is String
				? int.tryParse(json['user_status'])
				: json['user_status'].toInt();
	}
	if (json['wx_qr_url'] != null) {
		data.wxQrUrl = json['wx_qr_url'].toString();
	}
	return data;
}

Map<String, dynamic> userInfoEntityToJson(UserInfoEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['avatar_url'] = entity.avatarUrl;
	data['birth_date'] = entity.birthDate;
	data['city'] = entity.city;
	data['create_time'] = entity.createTime;
	data['device'] = entity.device;
	data['email'] = entity.email;
	data['email_password'] = entity.emailPassword;
	data['gender'] = entity.gender;
	data['last_login_time'] = entity.lastLoginTime;
	data['login_platform'] = entity.loginPlatform;
	data['name'] = entity.name;
	data['platform'] = entity.platform;
	data['province'] = entity.province;
	data['qq_qr_url'] = entity.qqQrUrl;
	data['uid'] = entity.uid;
	data['update_time'] = entity.updateTime;
	data['user_status'] = entity.userStatus;
	data['wx_qr_url'] = entity.wxQrUrl;
	return data;
}