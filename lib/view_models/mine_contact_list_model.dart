import 'package:fanmi/config/page_size_config.dart';
import 'package:fanmi/entity/contact_entity.dart';
import 'package:fanmi/net/user_service.dart';
import 'package:fanmi/view_models/view_state_refresh_list_model.dart';

class MineContactListModel extends ViewStateRefreshListModel<ContactEntity> {
  @override
  int get pageSize => PageSizeConfig.CONTACT_PAGE_SIZE;

  @override
  Future<List<ContactEntity>> loadData({int? pageNum}) async {
    var res = await UserService.getContactList(pageNum);
    return res;
  }
}
