import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/entity/card_preview_entity.dart';
import 'package:fanmi/view_models/mine_favor_list_model.dart';
import 'package:fanmi/widgets/appbars.dart';
import 'package:fanmi/widgets/card_preview_widget.dart';
import 'package:fanmi/widgets/provider_widget.dart';
import 'package:fanmi/widgets/view_state_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MineFavorListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderWidget(
      model: MineFavorListModel(),
      onModelReady: (model) => (model as MineFavorListModel).initData(),
      builder: (context, MineFavorListModel model, child) {
        Widget body;
        if (model.isBusy) {
          body = ViewStateBusyWidget();
        } else if (model.isError) {
          body = ViewStateErrorWidget(
              error: model.viewStateError!, onPressed: model.initData);
        } else if (model.isEmpty) {
          body = CustomEmptyWidget(
            img: "assets/images/no_collect_background.png",
          );
        } else {
          body = SmartRefresher(
            controller: model.refreshController,
            header: WaterDropHeader(),
            footer: ClassicFooter(
              noDataText: "没有更多收藏名片",
            ),
            onRefresh: model.refresh,
            onLoading: model.loadMore,
            enablePullUp: true,
            enablePullDown: false,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: model.list.length,
              itemBuilder: (context, index) {
                CardPreviewEntity item = model.list[index];
                return CardPreviewWidget(
                  data: item,
                  callback: () {
                    Navigator.of(context).pushNamed(AppRouter.CardInfoPageRoute,
                        arguments: item.id);
                  },
                );
              },
            ),
          );
        }
        return Scaffold(
          appBar: SubtitleAppBar(
            title: "收藏夹",
          ),
          body: body,
          resizeToAvoidBottomInset: false,
        );
      },
    );
  }
}
