import 'package:fanmi/generated/json/base/json_convert_content.dart';
import 'package:fanmi/generated/json/base/json_field.dart';

class CardPreviewEntity with JsonConvert<CardPreviewEntity> {
	@JSONField(name: "avatar_url")
	String? avatarUrl;
	@JSONField(name: "birth_date")
	String? birthDate;
	String? album;
	int? id;
	String? desc;
	int? type;
	int? uid;
	String? city;
	int? gender;
	@JSONField(name: "last_login_time")
	String? lastLoginTime;
	String? name;
	String? sign;
	@JSONField(name: "create_time")
	String? createTime;
	@JSONField(name: "update_time")
	String? updateTime;
}
