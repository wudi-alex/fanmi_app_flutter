import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/enums/message_type_enum.dart';
import 'package:fanmi/utils/common_methods.dart';
import 'package:fanmi/utils/time_utils.dart';
import 'package:fanmi/view_models/conversion_list_model.dart';
import 'package:fanmi/view_models/message_list_model.dart';
import 'package:fanmi/widgets/appbars.dart';
import 'package:fanmi/widgets/common_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConversionListPage extends StatefulWidget {
  @override
  _ConversionListPageState createState() => _ConversionListPageState();
}

class _ConversionListPageState extends State<ConversionListPage> {
  RefreshController _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    ConversionListModel conversionListModel =
        Provider.of<ConversionListModel>(context);
    MessageListModel msgModel = Provider.of<MessageListModel>(context);
    var conversionList = conversionListModel.conversionPageList;
    return Scaffold(
      appBar: TitleAppBar(
        title: "消息",
      ),
      body: SmartRefresher(
        controller: _refreshController,
        footer: ClassicFooter(
          noDataText: "没有更多消息",
        ),
        onLoading: () {
          bool canLoadNext = conversionListModel.pullData();
          if (canLoadNext) {
            _refreshController.loadNoData();
          } else {
            _refreshController.loadComplete();
          }
        },
        child: ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (BuildContext context, int index) => Divider(
            height: 0,
            thickness: 0.3.r,
          ),
          itemCount: conversionList.length,
          itemBuilder: (context, index) {
            Tuple3<V2TimConversation, V2TimUserFullInfo?, V2TimFriendInfo?>
                conversionItem = conversionList[index];
            var conversion = conversionItem.item1;
            int unReadCnt = conversion.unreadCount!;
            String name = conversionItem.item3 != null
                ? conversionItem.item3!.friendRemark ??
                    conversionItem.item1.showName!
                : conversionItem.item1.showName!;
            String avatarUrl = conversionItem.item3 != null
                ? conversionItem.item3!.friendCustomInfo!["avatar_url"] ??
                    conversionItem.item1.faceUrl!
                : conversionItem.item1.faceUrl!;
            String content = "";
            var lastMsg = conversion.lastMessage!;
            switch (lastMsg.elemType) {
              case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
                content = lastMsg.textElem!.text!;
                break;
              case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
                content = "[图片消息]";
                break;
              case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
                if (lastMsg.customElem!.desc ==
                    MessageTypeEnum.APPLICATION.toString()) {
                  Map<String, String> customDataMap =
                      json.decode(lastMsg.customElem!.data!);
                  content = customDataMap["text"]!;
                } else {
                  content = "[名片消息]";
                }
                break;
            }
            String time =
                DateTime.fromMillisecondsSinceEpoch(lastMsg.timestamp! * 1000)
                    .toString();
            return GestureDetector(
              onTap: () {
                String userId = conversion.userID!;
                msgModel.initData(userId);
                Navigator.of(context).pushNamed(AppRouter.MessageListPageRoute,
                    arguments: userId);
              },
              child: conversionItemWidget(
                  unReadCnt: unReadCnt,
                  avatarUrl: avatarUrl,
                  name: name,
                  content: content,
                  time: time),
            );
          },
        ),
      ),
    );
  }

  Widget conversionItemWidget(
      {required int unReadCnt,
      required String avatarUrl,
      required String name,
      required String content,
      required String time}) {
    return ListTile(
        tileColor: Colors.white,
        leading: unReadCnt != 0
            ? Badge(
                badgeContent: Text(
                  unReadCnt.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600),
                ),
                child: CommonImage.avatar(
                  imgUrl: avatarUrl,
                  callback: () {},
                  radius: 5.r,
                  height: 43.r,
                ),
              )
            : CommonImage.avatar(
                imgUrl: avatarUrl,
                callback: () {},
                height: 43.r,
                radius: 5.r,
              ),
        title: Text(
          name,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          customTime(time),
          style: TextStyle(color: Colors.grey),
        ));
  }
}
