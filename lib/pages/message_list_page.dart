import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/config/color_constants.dart';
import 'package:fanmi/entity/card_info_entity.dart';
import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/enums/message_type_enum.dart';
import 'package:fanmi/enums/user_status_enum.dart';
import 'package:fanmi/utils/common_methods.dart';
import 'package:fanmi/view_models/card_list_model.dart';
import 'package:fanmi/view_models/conversion_list_model.dart';
import 'package:fanmi/view_models/message_list_model.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:fanmi/widgets/appbars.dart';
import 'package:fanmi/widgets/message_item.dart';
import 'package:fanmi/widgets/svg_icon.dart';
import 'package:fanmi/widgets/view_state_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MessageListPage extends StatefulWidget {
  final String userId;

  const MessageListPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  get userId => widget.userId;

  FocusNode _focusNode = FocusNode();
  TextEditingController _controller = TextEditingController();
  ScrollController scrollController = ScrollController();

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
    setRead(userId);
    UserModel userModel = Provider.of<UserModel>(context);
    ConversionListModel conversionListModel =
        Provider.of<ConversionListModel>(context);

    MessageListModel model = Provider.of<MessageListModel>(context);
    CardListModel cardListModel = Provider.of<CardListModel>(context);
    var cardList = cardListModel.cardList as List<CardInfoEntity>;

    var selfUserInfo = userModel.userTimInfo;
    var userInfo = conversionListModel.userInfoMap[userId];
    // var friendInfo = conversionListModel.friendInfoMap[userId]!;
    // var messageList = messageListModel.messageMap[userId];

    String selfAvatarUrl = selfUserInfo.faceUrl!;
    // String friendAvatarUrl = friendInfo.friendCustomInfo!['avatar_url']!;
    // String friendName = friendInfo.friendRemark!;
    String friendAvatarUrl = selfUserInfo.faceUrl!;
    String friendName = "对方";

    // int userStatus = userInfo!.customInfo!["user_status"]! as int;
    int userStatus = UserStatusEnum.USER_STATUS_NORMAL;

    Widget body;
    if (model.isBusy) {
      body = ViewStateBusyWidget();
    } else {
      var messageList = (model.messageMap[userId] ?? []).reversed.toList();
      Widget idleBody = ListView.builder(
        reverse: true,
        shrinkWrap: true,
        itemCount: messageList.length,
        itemBuilder: (BuildContext context, int index) {
          V2TimMessage timMsg = messageList[index];
          String avatarUrl = timMsg.isSelf! ? selfAvatarUrl : friendAvatarUrl;
          int? msgTimeStamp = (index == 0 ||
                  messageList[index - 1].timestamp! - timMsg.timestamp! > 100)
              ? timMsg.timestamp
              : null;
          // int? msgTimeStamp=timMsg.timestamp!;
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
              Map<String, Object> customDataMap = Map<String, Object>.from(
                  json.decode(timMsg.customElem!.data!));
              int cardId = customDataMap["card_id"]! as int;
              int cardType = customDataMap["card_type"]! as int;
              return MessageItem(
                messageType: MessageTypeEnum.CARD,
                avatarUrl: avatarUrl,
                isSelf: isSelf,
                isPeerRead: timMsg.isPeerRead ?? false,
                msgTimestamp: msgTimeStamp,
                cardId: cardId,
                cardType: cardType,
              );
            default:
              return Container();
          }
        },
      );
      body = idleBody;
    }
    return Scaffold(
      appBar: SubtitleAppBar(
        title: friendName,
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(child: body),
          msgTextField(userStatus),
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //同意
                iconButton(
                  Icons.favorite,
                  () async {
                    final res = await showOkCancelAlertDialog(
                      context: context,
                      title: "同意交友申请",
                      message: "确定同意对方的交友申请吗？同意后你们将交换二维码哦",
                      okLabel: "确定",
                      cancelLabel: "取消",
                    );
                  },
                ),
                //拒绝
                iconButton(
                  Icons.close,
                  () async {
                    final res = await showOkCancelAlertDialog(
                      context: context,
                      title: "拒绝交友申请",
                      message: "确定拒绝对方的交友申请吗？拒绝后双方将无法再交流并删除对话",
                      okLabel: "确定",
                      cancelLabel: "取消",
                    );
                  },
                ),
                //图片消息
                iconButton(
                  Icons.image,
                  () async {
                    var assets = await AssetPicker.pickAssets(
                      context,
                      pageSize: 400,
                      maxAssets: 1,
                      themeColor: Colors.blue,
                      requestType: RequestType.image,
                      previewThumbSize: const <int>[500, 800],
                      gridThumbSize: 400,
                    );
                    if (assets != null) {
                      var imageAsset = assets[0];
                      var file = await imageAsset.originFile;
                      //发送图片消息
                      await TencentImSDKPlugin.v2TIMManager
                          .getMessageManager()
                          .sendImageMessage(
                            imagePath: file!.path,
                            receiver: userId,
                            groupID: "",
                            priority: 0,
                            onlineUserOnly: false,
                            isExcludedFromUnreadCount: false,
                          );
                    }
                  },
                ),
                //名片消息
                iconButton(
                  Icons.account_box_rounded,
                  () async {
                    if (cardList.isEmpty) {
                      final res = await showOkCancelAlertDialog(
                        context: context,
                        title: "发送名片",
                        message: "你还没有创建过名片哦，要不要去创建一个？",
                        okLabel: "去创建",
                        cancelLabel: "我知道啦",
                      );
                      if (res == OkCancelResult.ok) {
                        Navigator.of(context)
                            .pushNamed(AppRouter.CardListPageRoute);
                      } else {
                        return;
                      }
                    }
                    //显示可发送名片
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Container(
                        height: 40.r * cardList.length + 50.r,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(
                            vertical: 20.r, horizontal: 10.r),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.r),
                                topRight: Radius.circular(15.r)),
                            color: Colors.white),
                        child: ListView(
                          children:
                              cardList.map((card) => sheetItem(card)).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget msgTextField(int userStatus) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // height: 70.r,
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.fromLTRB(15.r, 10.r, 15.r, 8.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5.r)),
          color: ColorConstants.mi_color,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 10.r),
          constraints: BoxConstraints(minHeight: 40.r),
          child: TextField(
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400),
            focusNode: _focusNode,
            controller: _controller,
            maxLines: 5,
            minLines: 1,
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
            ),
            onSubmitted: (text) async {
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
                  await TencentImSDKPlugin.v2TIMManager.sendC2CTextMessage(
                    text: text,
                    userID: userId,
                  );
                  _controller.text = "";
                  print('发送文字消息');
              }
            },
          ),
        ),
      ),
    );
  }

  Widget iconButton(IconData icon, VoidCallback callback) {
    return Container(
      padding: EdgeInsets.only(bottom: 8.r),
      child: GestureDetector(
        onTap: callback,
        child: Icon(
          icon,
          color: Colors.grey,
          size: 27.r,
        ),
      ),
    );
  }

  Widget sheetItem(CardInfoEntity card) {
    CardTypeEnum cardType = CardTypeEnum.getCardType(card.type!);
    return GestureDetector(
      onTap: () async {
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .sendCustomMessage(
                data: json.encode({
                  "card_id": card.id,
                  "card_type": card.type,
                }),
                receiver: userId,
                groupID: "",
                priority: 0,
                offlinePushInfo: OfflinePushInfo(
                  desc:
                      "我给你发送了我的${CardTypeEnum.getCardType(card.type!).desc}名片，快来看看吧～",
                ));
        Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.r),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(
              svgPath: cardType.svgPath,
              width: 26.r,
            ),
            SizedBox(
              width: 10.r,
            ),
            Text(
              cardType.desc,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
