import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/entity/contact_entity.dart';
import 'package:fanmi/view_models/mine_contact_list_model.dart';
import 'package:fanmi/widgets/provider_widget.dart';
import 'package:fanmi/widgets/view_state_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:fanmi/widgets/appbars.dart';
import 'package:fanmi/widgets/common_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MineContactListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderWidget(
      model: MineContactListModel(),
      onModelReady: (model) => (model as MineContactListModel).initData(),
      builder: (context, MineContactListModel model, child) {
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
              noDataText: "没有更多联系人",
            ),
            onRefresh: model.refresh,
            onLoading: model.loadMore,
            enablePullUp: true,
            enablePullDown: false,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: model.list.length,
              itemBuilder: (context, index) {
                ContactEntity item = model.list[index];
                return ContactTile(
                  cardId: item.cardId,
                  avatarUrl: item.avatar!,
                  name: item.name!,
                  wxQrUrl: item.wx,
                  qqQrUrl: item.qq,
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
            title: "通讯录",
          ),
          body: body,
          resizeToAvoidBottomInset: false,
        );
      },
    );
  }
}

class ContactTile extends StatelessWidget {
  final int? cardId;
  final String avatarUrl;
  final String name;
  final String? wxQrUrl;
  final String? qqQrUrl;

  const ContactTile(
      {Key? key,
      required this.avatarUrl,
      required this.name,
      this.wxQrUrl,
      this.qqQrUrl,
      this.cardId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var desc = '';
    if (wxQrUrl != null && qqQrUrl != null) {
      desc = '微信/QQ';
    } else if (wxQrUrl != null) {
      desc = '微信';
    } else {
      desc = 'QQ';
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRouter.MineContactDetailPageRoute,
            arguments: [name, wxQrUrl, qqQrUrl]);
      },
      child: ListTile(
        tileColor: Colors.white,
        leading: CommonImage.avatar(
          imgUrl: avatarUrl,
          callback: cardId != null
              ? () {
                  // Navigator.of(context).pushNamed(AppRouter.CardDetailPageRoute,
                  //     arguments: [cardId,1,'','',false]);
                }
              : null,
          radius: 5.r,
          height: 43.r,
        ),
        title: Text(
          name,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          desc,
          style: TextStyle(
              fontSize: 16.sp, fontWeight: FontWeight.w400, color: Colors.grey),
        ),
      ),
    );
  }
}

class MineContactDetailPage extends StatelessWidget {
  final String name;
  final String? wxQrUrl;
  final String? qqQrUrl;

  const MineContactDetailPage(
      {Key? key, required this.name, this.wxQrUrl, this.qqQrUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubtitleAppBar(
        title: name,
      ),
      body: ListView(
        children: [
          wxQrUrl != null ? qrImage(wxQrUrl!) : SizedBox.shrink(),
          qqQrUrl != null ? qrImage(qqQrUrl!) : SizedBox.shrink()
        ],
      ),
    );
  }

  Widget qrImage(String url) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 10.r),
        child: CommonImage(
          imgUrl: url,
          width: 250.r,
          height: 450.r,
          radius: 10.r,
        ),
      );
}
