import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/entity/card_preview_entity.dart';
import 'package:fanmi/enums/action_type_enum.dart';
import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/net/action_service.dart';
import 'package:fanmi/pages/search_page/search_board.dart';
import 'package:fanmi/pages/search_page/search_tab.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/view_models/search_list_view_model.dart';
import 'package:fanmi/widgets/card_preview_widget.dart';
import 'package:fanmi/widgets/provider_widget.dart';
import 'package:fanmi/widgets/view_state_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  get isLogin => StorageManager.isLogin;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProviderWidget(
        model: SearchListViewModel(),
        onModelReady: (model) => (model as SearchListViewModel).initData(),
        builder: (context, model, child) {
          model as SearchListViewModel;
          Widget body;
          if (model.isBusy) {
            body = ViewStateBusyWidget();
          } else if (model.isError) {
            body = ViewStateErrorWidget(
                error: model.viewStateError!, onPressed: model.initData);
          } else if (model.isEmpty) {
            body = SingleChildScrollView(
              child: ViewStateEmptyWidget(
                  image: Padding(
                    padding: EdgeInsets.only(top: 50.r),
                    child: Image.asset(
                      "assets/images/no_card_background.png",
                      height: 200.r,
                      width: 170.r,
                    ),
                  ),
                  message: "",
                  onPressed: model.initData),
            );
          } else {
            body = SmartRefresher(
              controller: model.refreshController,
              header: WaterDropHeader(
                refresh: Text(
                  '正在努力加载中',
                  style: TextStyle(color: Colors.grey, fontSize: 15.sp),
                ),
                complete: Text(
                  '加载完毕',
                  style: TextStyle(color: Colors.grey, fontSize: 15.sp),
                ),
                failed: Text(
                  '加载失败',
                  style: TextStyle(color: Colors.grey, fontSize: 15.sp),
                ),
              ),
              footer: ClassicFooter(
                noDataText: "没有更多名片",
              ),
              onRefresh: model.refresh,
              onLoading: model.loadMore,
              enablePullUp: true,
              child: ListView.builder(
                  itemCount: model.list.length,
                  itemBuilder: (context, index) {
                    CardPreviewEntity item = model.list[index];
                    return CardPreviewWidget(
                      data: item,
                      callback: () {
                        if (StorageManager.uid != null &&
                            item.uid != StorageManager.uid) {
                          //添加点击事件
                          ActionService.addAction(
                              cardId: item.id!,
                              cardType: item.type!,
                              targetUid: item.uid!,
                              actionType: ActionTypeEnum.ACTION_CLICK);
                        }
                        Navigator.of(context).pushNamed(
                            AppRouter.CardInfoPageRoute,
                            arguments: item.id);
                      },
                    );
                  }),
            );
          }
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(95.r),
              child: SafeArea(
                child: Material(
                  elevation: 1,
                  child: Column(
                    children: [
                      SearchBoard(),
                      SearchTab(),
                    ],
                  ),
                ),
              ),
            ),
            body: body,
            resizeToAvoidBottomInset: false,
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 667),
      builder: () => RefreshConfiguration(
        hideFooterWhenNotFull: true, //列表数据不满一页,不触发加载更多
        child: MaterialApp(
          onGenerateRoute: AppRouter.generateRoute,
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: Container(child: SearchPage()),
            ),
            resizeToAvoidBottomInset: false,
          ),
        ),
      ),
    );
  }
}
