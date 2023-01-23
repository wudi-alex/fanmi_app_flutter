import 'package:fanmi/generated/json/base/json_convert_content.dart';
import 'package:fanmi/generated/json/base/json_field.dart';

class ContactEntity with JsonConvert<ContactEntity> {
	String? avatar;
	@JSONField(name: "card_id")
	int? cardId;
	String? name;
	String? qq;
	int? uid;
	String? wx;
}
