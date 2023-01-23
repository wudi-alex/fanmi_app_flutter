import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/entity/block_entity.dart';
import 'package:fanmi/net/user_service.dart';
import 'package:fanmi/view_models/mine_block_list_model.dart';
import 'package:fanmi/widgets/appbars.dart';
import 'package:fanmi/widgets/common_image.dart';
import 'package:fanmi/widgets/provider_widget.dart';
import 'package:fanmi/widgets/view_state_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MineBlockListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderWidget(
      model: MineBoardListModel(),
      onModelReady: (model) => (model as MineBoardListModel).initData(),
      builder: (context, MineBoardListModel model, child) {
        Widget body;
        if (model.isBusy) {
          body = ViewStateBusyWidget();
        } else if (model.isError) {
          body = ViewStateErrorWidget(
              error: model.viewStateError!, onPressed: model.initData);
        } else if (model.isEmpty) {
          body = CustomEmptyWidget(
            img: "assets/images/no_contact_background.png",
          );
        } else {
          body = SmartRefresher(
            controller: model.refreshController,
            header: WaterDropHeader(),
            footer: ClassicFooter(
              noDataText: "没有更多黑名单用户",
            ),
            onRefresh: model.refresh,
            onLoading: model.loadMore,
            enablePullUp: true,
            enablePullDown: false,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: model.list.length,
              itemBuilder: (context, index) {
                BlockEntity item = model.list[index];
                return ListTile(
                  tileColor: Colors.white,
                  leading: CommonImage.avatar(
                    height: 43.r,
                    radius: 5.r,
                    imgUrl: item.blockedAvatar,
                    callback: () {
                      Navigator.of(context).pushNamed(
                          AppRouter.CardInfoPageRoute,
                          arguments: item.blockedCardId);
                    },
                  ),
                  title: Text(
                    item.blockedName!,
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                  ),
                  trailing: GestureDetector(
                    child: Text(
                      '取消拉黑',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue),
                    ),
                    onTap: () {
                      model.cancelBlock(item.blockedUid!, context);
                    },
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => Divider(
                height: 0,
                thickness: 0.3.r,
              ),
            ),
          );
        }
        return Scaffold(
          appBar: SubtitleAppBar(
            title: "黑名单",
          ),
          body: body,
          resizeToAvoidBottomInset: false,
        );
      },
    );
  }
}
