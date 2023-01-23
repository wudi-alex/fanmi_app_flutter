import 'package:fanmi/config/page_size_config.dart';
import 'package:fanmi/entity/board_item_entity.dart';
import 'package:fanmi/net/user_service.dart';
import 'package:fanmi/view_models/view_state_refresh_list_model.dart';

class MineBoardListModel extends ViewStateRefreshListModel<BoardItemEntity> {
  @override
  int get pageSize => PageSizeConfig.BOARD_LIST_PAGE_SIZE;

  @override
  Future<List<BoardItemEntity>> loadData({int? pageNum}) async {
    var res = await UserService.getBoardList(pageNum);
    return res;
  }
}
