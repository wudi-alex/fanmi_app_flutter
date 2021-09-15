import 'package:fanmi/entity/board_item_entity.dart';
import 'package:fanmi/enums/action_type_enum.dart';
import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/enums/gender_type_enum.dart';
import 'package:fanmi/utils/time_utils.dart';
import 'package:fanmi/view_models/mine_board_list_model.dart';
import 'package:fanmi/widgets/appbars.dart';
import 'package:fanmi/widgets/common_image.dart';
import 'package:fanmi/widgets/provider_widget.dart';
import 'package:fanmi/widgets/view_state_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MineBoardListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderWidget(
        model: MineBoardListModel(),
        onModelReady: (MineBoardListModel model) => model.initData(),
        builder: (context, MineBoardListModel model, child) {
          Widget body;
          if (model.isBusy) {
            body = ViewStateBusyWidget();
          } else if (model.isError) {
            body = ViewStateErrorWidget(
                error: model.viewStateError!, onPressed: model.initData);
          } else if (model.isEmpty) {
            body = CustomEmptyWidget(
              img: "assets/images/no_visitor_background.png",
            );
          } else {
            body = SmartRefresher(
              controller: model.refreshController,
              header: WaterDropHeader(),
              footer: ClassicFooter(
                noDataText: "没有更多访客了",
              ),
              onRefresh: model.refresh,
              onLoading: model.loadMore,
              enablePullUp: true,
              enablePullDown: false,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: model.list.length,
                itemBuilder: (context, index) {
                  BoardItemEntity item = model.list[index];
                  return BoardItem(data: item);
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
              title: "我的访客",
            ),
            body: body,
            resizeToAvoidBottomInset: false,
          );
        });
  }
}

class BoardItem extends StatelessWidget {
  final BoardItemEntity data;

  const BoardItem({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GenderTypeEnum gender = GenderTypeEnum.getGender(data.gender!);
    CardTypeEnum cardType = CardTypeEnum.getCardType(data.cardType!);
    String genderText = data.gender == 0 ? "她" : "他";
    String text = "";
    switch (data.actionType) {
      case ActionTypeEnum.ACTION_SEARCH:
        text = "$genderText搜索 ${data.searchWord!} 时搜索到了你的${cardType.desc}名片";
        break;
      case ActionTypeEnum.ACTION_CLICK:
        text = "$genderText点击了你的${cardType.desc}名片";
        break;
      case ActionTypeEnum.ACTION_FAVOR:
        text = "$genderText收藏了你的${cardType.desc}名片";
        break;
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8.r, horizontal: 10.r),
      child: Row(
        children: [
          CommonImage.avatar(
            height: 38.r,
            radius: 5.r,
            imgUrl: data.avatarUrl!,
          ),
          SizedBox(
            width: 5.r,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    data.name!,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(
                    width: 2.r,
                  ),
                  SvgPicture.asset(
                    gender.svgPath,
                    width: 10.r,
                    color: gender.color,
                  ),
                ],
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 260.r),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            customTime(data.createTime!),
            style: TextStyle(color: Colors.grey, fontSize: 13.sp),
          )
        ],
      ),
    );
  }
}
