import 'dart:convert';

import 'package:fanmi/enums/message_type_enum.dart';
import 'package:fanmi/enums/user_status_enum.dart';
import 'package:fanmi/view_models/conversion_list_model.dart';
import 'package:fanmi/view_models/message_list_model.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:fanmi/widgets/appbars.dart';
import 'package:fanmi/widgets/message_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MessageListPage extends StatefulWidget {
  final String userId;

  const MessageListPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  get userId => widget.userId;

  RefreshController _refreshController = RefreshController();

  FocusNode _focusNode = FocusNode();
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel userModel = Provider.of<UserModel>(context);
    ConversionListModel conversionListModel =
        Provider.of<ConversionListModel>(context);
    MessageListModel messageListModel = Provider.of<MessageListModel>(context);

    var selfUserInfo = userModel.userTimInfo;
    var userInfo = conversionListModel.userInfoMap[userId];
    var friendInfo = conversionListModel.friendInfoMap[userId]!;
    var messageList = messageListModel.messageMap[userId];

    String selfAvatarUrl = selfUserInfo.faceUrl!;
    String friendAvatarUrl = friendInfo.friendCustomInfo!['avatar_url']!;
    String friendName = friendInfo.friendRemark!;

    int userStatus = userInfo!.customInfo!["user_status"]! as int;

    messageListModel.pullHistoryMessage(userId, null);

    return Scaffold(
      appBar: SubtitleAppBar(
        title: friendName,
      ),
      body: SmartRefresher(
        reverse: true,
        controller: _refreshController,
        footer: ClassicFooter(
          noDataText: "没有更早的消息",
        ),
        onLoading: () async {
          bool canLoadNext = await messageListModel.pullHistoryMessage(
              userId, messageListModel.messageMap[userId]!.last.msgID);
          if (canLoadNext) {
            _refreshController.loadNoData();
          } else {
            _refreshController.loadComplete();
          }
        },
        child: ListView.builder(
          reverse: true,
          shrinkWrap: true,
          itemCount: messageList!.length,
          itemBuilder: (BuildContext context, int index) {
            V2TimMessage timMsg = messageList[index];
            String avatarUrl = timMsg.isSelf! ? selfAvatarUrl : friendAvatarUrl;
            int? msgTimeStamp = (index == 0 ||
                    timMsg.timestamp! - messageList[index - 1].timestamp! >
                        10 * 60 * 1000)
                ? timMsg.timestamp
                : null;
            bool isSelf = timMsg.isSelf!;
            switch (timMsg.elemType) {
              case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
                return MessageItem(
                  messageType: MessageTypeEnum.NORMAL,
                  avatarUrl: avatarUrl,
                  isSelf: isSelf,
                  msgText: timMsg.textElem!.text,
                  isPeerRead: timMsg.isPeerRead ?? false,
                  msgTimestamp: msgTimeStamp,
                );
              case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
                return MessageItem(
                  messageType: MessageTypeEnum.IMG,
                  avatarUrl: avatarUrl,
                  isSelf: isSelf,
                  imgUrl: timMsg.imageElem!.imageList![0]!.url,
                  isPeerRead: timMsg.isPeerRead ?? false,
                  msgTimestamp: msgTimeStamp,
                );
              case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
                Map<String, Object> customDataMap =
                    json.decode(timMsg.customElem!.data!);
                if (timMsg.customElem!.desc ==
                    MessageTypeEnum.APPLICATION.toString()) {
                  Map<String, String> customDataMap =
                      json.decode(timMsg.customElem!.data!);
                  String content = customDataMap["text"]!;
                  return MessageItem(
                    messageType: MessageTypeEnum.NORMAL,
                    avatarUrl: avatarUrl,
                    isSelf: isSelf,
                    msgText: content,
                    isPeerRead: timMsg.isPeerRead ?? false,
                    msgTimestamp: msgTimeStamp,
                  );
                } else {
                  int cardId = customDataMap["cardId"]! as int;
                  return MessageItem(
                    messageType: MessageTypeEnum.CARD,
                    avatarUrl: avatarUrl,
                    isSelf: isSelf,
                    isPeerRead: timMsg.isPeerRead ?? false,
                    msgTimestamp: msgTimeStamp,
                    cardId: cardId,
                  );
                }
              default:
                return Container();
            }
          },
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 80.r,
        color: Colors.white,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
          color: Colors.grey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
            child: TextField(
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
              focusNode: _focusNode,
              controller: _controller,
              maxLines: 5,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
              ),
              onSubmitted: (text) {
                switch (userStatus) {
                  case UserStatusEnum.USER_STATUS_FORBIDDEN:
                    SmartDialog.showToast("该用户已被封禁");
                    break;
                  case UserStatusEnum.USER_STATUS_FREEZE:
                    SmartDialog.showToast("该用户已被冻结");
                    break;
                  case UserStatusEnum.USER_STATUS_DELETE:
                    SmartDialog.showToast("该用户已注销");
                    break;
                  case UserStatusEnum.USER_STATUS_NORMAL:
                    TencentImSDKPlugin.v2TIMManager.sendC2CTextMessage(
                      text: text,
                      userID: userId,
                    );
                    print('发送文字消息');
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
