import 'package:fanmi/generated/json/base/json_convert_content.dart';
import 'package:fanmi/generated/json/base/json_field.dart';

class UserInfoEntity with JsonConvert<UserInfoEntity> {
	@JSONField(name: "avatar_url")
	String? avatarUrl;
	@JSONField(name: "birth_date")
	String? birthDate;
	String? city;
	@JSONField(name: "create_time")
	String? createTime;
	String? device;
	String? email;
	@JSONField(name: "email_password")
	String? emailPassword;
	int? gender;
	@JSONField(name: "last_login_time")
	String? lastLoginTime;
	@JSONField(name: "login_platform")
	String? loginPlatform;
	String? name;
	String? platform;
	String? province;
	@JSONField(name: "qq_qr_url")
	String? qqQrUrl;
	int? uid;
	@JSONField(name: "update_time")
	String? updateTime;
	@JSONField(name: "user_status")
	int? userStatus;
	@JSONField(name: "wx_qr_url")
	String? wxQrUrl;
}
