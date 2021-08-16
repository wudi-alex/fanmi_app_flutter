import 'package:fanmi/generated/json/base/json_convert_content.dart';
import 'package:fanmi/generated/json/base/json_field.dart';

class MineBoardEntity with JsonConvert<MineBoardEntity> {
	@JSONField(name: "click_add_num")
	int? clickAddNum;
	@JSONField(name: "click_num")
	int? clickNum;
	@JSONField(name: "exposure_add_num")
	int? exposureAddNum;
	@JSONField(name: "exposure_num")
	int? exposureNum;
	@JSONField(name: "favor_add_num")
	int? favorAddNum;
	@JSONField(name: "favor_num")
	int? favorNum;
	@JSONField(name: "search_add_num")
	int? searchAddNum;
	@JSONField(name: "search_num")
	int? searchNum;
}
