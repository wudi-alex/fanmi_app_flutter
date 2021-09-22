import 'package:fanmi/generated/json/base/json_convert_content.dart';
import 'package:fanmi/generated/json/base/json_field.dart';

class BlockEntity with JsonConvert<BlockEntity> {
	int? id;
	int? uid;
	@JSONField(name: "blocked_uid")
	int? blockedUid;
	@JSONField(name: "blocked_card_id")
	int? blockedCardId;
	@JSONField(name: "blocked_avatar")
	String? blockedAvatar;
	@JSONField(name: "blocked_name")
	String? blockedName;
	int? status;
	@JSONField(name: "create_time")
	String? createTime;
	@JSONField(name: "update_time")
	String? updateTime;
}
