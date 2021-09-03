import 'package:fanmi/config/page_size_config.dart';
import 'package:fanmi/entity/card_preview_entity.dart';
import 'package:fanmi/net/user_service.dart';
import 'package:fanmi/view_models/view_state_refresh_list_model.dart';

class MineFavorListModel extends ViewStateRefreshListModel<CardPreviewEntity> {

  @override
  int get pageSize => PageSizeConfig.FAVOR_PAGE_SIZE;

  @override
  Future<List<CardPreviewEntity>> loadData({int? pageNum}) async {
    var res = await UserService.getFavorList(pageNum);
    return res;
  }
}
