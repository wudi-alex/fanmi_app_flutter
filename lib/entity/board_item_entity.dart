import 'package:fanmi/generated/json/base/json_convert_content.dart';
import 'package:fanmi/generated/json/base/json_field.dart';

class BoardItemEntity with JsonConvert<BoardItemEntity> {
	@JSONField(name: "action_type")
	int? actionType;
	@JSONField(name: "avatar_url")
	String? avatarUrl;
	@JSONField(name: "card_id")
	int? cardId;
	@JSONField(name: "card_type")
	int? cardType;
	@JSONField(name: "create_time")
	String? createTime;
	int? gender;
	String? name;
	@JSONField(name: "search_word")
	String? searchWord;
	int? uid;
}
