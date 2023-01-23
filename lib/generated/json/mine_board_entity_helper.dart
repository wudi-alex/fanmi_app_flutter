import 'package:fanmi/entity/mine_board_entity.dart';

mineBoardEntityFromJson(MineBoardEntity data, Map<String, dynamic> json) {
	if (json['click_add_num'] != null) {
		data.clickAddNum = json['click_add_num'] is String
				? int.tryParse(json['click_add_num'])
				: json['click_add_num'].toInt();
	}
	if (json['click_num'] != null) {
		data.clickNum = json['click_num'] is String
				? int.tryParse(json['click_num'])
				: json['click_num'].toInt();
	}
	if (json['exposure_add_num'] != null) {
		data.exposureAddNum = json['exposure_add_num'] is String
				? int.tryParse(json['exposure_add_num'])
				: json['exposure_add_num'].toInt();
	}
	if (json['exposure_num'] != null) {
		data.exposureNum = json['exposure_num'] is String
				? int.tryParse(json['exposure_num'])
				: json['exposure_num'].toInt();
	}
	if (json['favor_add_num'] != null) {
		data.favorAddNum = json['favor_add_num'] is String
				? int.tryParse(json['favor_add_num'])
				: json['favor_add_num'].toInt();
	}
	if (json['favor_num'] != null) {
		data.favorNum = json['favor_num'] is String
				? int.tryParse(json['favor_num'])
				: json['favor_num'].toInt();
	}
	if (json['search_add_num'] != null) {
		data.searchAddNum = json['search_add_num'] is String
				? int.tryParse(json['search_add_num'])
				: json['search_add_num'].toInt();
	}
	if (json['search_num'] != null) {
		data.searchNum = json['search_num'] is String
				? int.tryParse(json['search_num'])
				: json['search_num'].toInt();
	}
	return data;
}

Map<String, dynamic> mineBoardEntityToJson(MineBoardEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['click_add_num'] = entity.clickAddNum;
	data['click_num'] = entity.clickNum;
	data['exposure_add_num'] = entity.exposureAddNum;
	data['exposure_num'] = entity.exposureNum;
	data['favor_add_num'] = entity.favorAddNum;
	data['favor_num'] = entity.favorNum;
	data['search_add_num'] = entity.searchAddNum;
	data['search_num'] = entity.searchNum;
	return data;
}