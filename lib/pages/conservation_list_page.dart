import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:badges/badges.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/enums/message_type_enum.dart';
import 'package:fanmi/enums/relation_entity.dart';
import 'package:fanmi/utils/common_methods.dart';
import 'package:fanmi/utils/time_utils.dart';
import 'package:fanmi/view_models/conversion_list_model.dart';
import 'package:fanmi/view_models/message_list_model.dart';
import 'package:fanmi/widgets/appbars.dart';
import 'package:fanmi/widgets/common_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConversionListPage extends StatefulWidget {
  @override
  _ConversionListPageState createState() => _ConversionListPageState();
}

class _ConversionListPageState extends State<ConversionListPage> {
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
      body: ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, int index) => Divider(
          height: 0,
          thickness: 0.3.r,
        ),
        itemCount: conversionList.length,
        itemBuilder: (context, index) {
          Tuple2<V2TimConversation, RelationEntity?> conversionItem =
              conversionList[index];
          var conversion = conversionItem.item1;
          var relation = conversionItem.item2;
          int unReadCnt = conversion.unreadCount!;
          String name = relation != null
              ? (relation.isApplicant == 1 ? relation.tName! : relation.uName!)
              : conversion.showName!;
          String avatarUrl = relation != null
              ? (relation.isApplicant == 1
                  ? relation.tAvatar!
                  : relation.uAvatar!)
              : conversion.faceUrl!;
          String content = "";
          var lastMsg = conversion.lastMessage;
          if (lastMsg != null) {
            switch (lastMsg.elemType) {
              case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
                content = lastMsg.textElem!.text!;
                break;
              case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
                content = "[图片消息]";
                break;
              case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
                switch (int.parse(lastMsg.customElem!.desc!)) {
                  case MessageTypeEnum.APPLICATION:
                    Map<String, Object> customDataMap =
                        Map<String, Object>.from(
                            json.decode(lastMsg.customElem!.data!));
                    content = customDataMap["text"]! as String;
                    break;
                  case MessageTypeEnum.CARD:
                    content = "[名片消息]";
                    break;
                  case MessageTypeEnum.QR:
                    content = "[二维码消息]";
                    break;
                  default:
                    content = "";
                }
                break;
            }
          }
          String time = DateTime.fromMillisecondsSinceEpoch(
                  lastMsg != null ? lastMsg.timestamp! * 1000 : 0)
              .toString();
          return SwipeActionCell(
            backgroundColor: Colors.white,
            key: UniqueKey(),
            trailingActions: <SwipeAction>[
              SwipeAction(
                  title: "删除",
                  onTap: (CompletionHandler handler) async {
                    final res = await showOkCancelAlertDialog(
                      context: context,
                      title: "删除会话",
                      message: "删除后无法和对方对话了哦，确认删除吗",
                      okLabel: "删除",
                      cancelLabel: "取消",
                    );
                    if (res == OkCancelResult.ok) {
                      await TencentImSDKPlugin.v2TIMManager
                          .getConversationManager()
                          .deleteConversation(
                            conversationID: conversion.conversationID,
                          );
                      conversionListModel.updateConversionInfoMap([conversion],
                          isDelete: true);
                    } else {
                      return;
                    }
                  },
                  color: Colors.red),
            ],
            child: GestureDetector(
              onTap: () {
                String userId = conversion.userID!;
                msgModel.initData(userId);
                setRead(userId);
                Navigator.of(context).pushNamed(AppRouter.MessageListPageRoute,
                    arguments: userId);
              },
              child: conversionItemWidget(
                  unReadCnt: unReadCnt,
                  avatarUrl: avatarUrl,
                  name: name,
                  content: content,
                  time: time),
            ),
          );
        },
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
