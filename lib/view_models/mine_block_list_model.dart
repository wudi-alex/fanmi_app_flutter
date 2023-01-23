import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fanmi/config/page_size_config.dart';
import 'package:fanmi/entity/block_entity.dart';
import 'package:fanmi/net/user_service.dart';
import 'package:fanmi/view_models/view_state_refresh_list_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MineBoardListModel extends ViewStateRefreshListModel<BlockEntity> {
  @override
  int get pageSize => PageSizeConfig.BLOCK_LIST_PAGE_SIZE;

  @override
  Future<List<BlockEntity>> loadData({int? pageNum}) async {
    var res = await UserService.getBlockList(page: pageNum!);
    return res;
  }

  cancelBlock(int blockedUid, BuildContext context) async {
    final res = await showOkCancelAlertDialog(
      context: context,
      title: "取消拉黑该用户",
      message: "确定取消拉黑该用户吗？取消拉黑后该用户所有内容及消息可正常展示",
      okLabel: "确定",
      cancelLabel: "取消",
    );
    if (res == OkCancelResult.ok) {
      EasyLoading.show(status: "取消拉黑中");
      Future.wait([
        UserService.cancelBlock(blockedUid: blockedUid),
        TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .deleteFromBlackList(
          userIDList: [blockedUid.toString()],
        ),
      ]).then((v) {
        list.removeWhere((element) => element.blockedUid == blockedUid);
        notifyListeners();
        EasyLoading.showSuccess("取消拉黑成功");
      }).onError((error, stackTrace) {
        EasyLoading.showError("取消拉黑失败");
      });
    }
  }
}
