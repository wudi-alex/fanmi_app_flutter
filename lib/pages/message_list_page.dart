import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/config/color_constants.dart';
import 'package:fanmi/entity/card_info_entity.dart';
import 'package:fanmi/entity/relation_entity.dart';
import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/enums/gender_type_enum.dart';
import 'package:fanmi/enums/is_applicant_enum.dart';
import 'package:fanmi/enums/message_type_enum.dart';
import 'package:fanmi/enums/relation_type_enum.dart';
import 'package:fanmi/net/relation_service.dart';
import 'package:fanmi/utils/common_methods.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/utils/time_utils.dart';
import 'package:fanmi/view_models/card_list_model.dart';
import 'package:fanmi/view_models/conversion_list_model.dart';
import 'package:fanmi/view_models/message_list_model.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:fanmi/widgets/message_item.dart';
import 'package:fanmi/widgets/svg_icon.dart';
import 'package:fanmi/widgets/view_state_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  late UserModel userModel;
  late MessageListModel messageModel;
  late CardListModel cardListModel;
  late ConversionListModel conversionListModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _controller.dispose();
    messageModel.nowTalkingUserId = "";
  }

  @override
  Widget build(BuildContext context) {
    userModel = Provider.of<UserModel>(context);
    conversionListModel = Provider.of<ConversionListModel>(context);
    messageModel = Provider.of<MessageListModel>(context);
    messageModel.nowTalkingUserId = userId;
    cardListModel = Provider.of<CardListModel>(context);
    var cardList = cardListModel.cardList as List<CardInfoEntity>;
    var relation = conversionListModel.relationInfoMap[userId]!;
    var selfUserInfo = userModel.userTimInfo;
    String selfAvatarUrl = selfUserInfo.faceUrl!;

    String friendAvatarUrl =
        relation.isApplicant == 1 ? relation.tAvatar! : relation.uAvatar!;

    Widget body;
    if (messageModel.isBusy) {
      body = ViewStateBusyWidget();
    } else {
      var messageList =
          (messageModel.messageMap[userId] ?? []).reversed.toList();
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
                selfAvatarCardId: relation.isApplicant == 1
                    ? relation.addCardId
                    : relation.targetCardId,
                otherAvatarCardId: relation.isApplicant == 1
                    ? relation.targetCardId
                    : relation.addCardId,
              );
            case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
              return MessageItem(
                messageType: MessageTypeEnum.IMG,
                avatarUrl: avatarUrl,
                isSelf: isSelf,
                imgUrl: timMsg.imageElem!.imageList![0]!.url,
                isPeerRead: timMsg.isPeerRead ?? false,
                msgTimestamp: msgTimeStamp,
                selfAvatarCardId: relation.isApplicant == 1
                    ? relation.addCardId
                    : relation.targetCardId,
                otherAvatarCardId: relation.isApplicant == 1
                    ? relation.targetCardId
                    : relation.addCardId,
              );
            case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
              Map<String, Object> customDataMap = Map<String, Object>.from(
                  json.decode(timMsg.customElem!.data!));
              switch (int.parse(timMsg.customElem!.desc!)) {
                case MessageTypeEnum.CARD:
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
                    selfAvatarCardId: relation.isApplicant == 1
                        ? relation.addCardId
                        : relation.targetCardId,
                    otherAvatarCardId: relation.isApplicant == 1
                        ? relation.targetCardId
                        : relation.addCardId,
                  );
                case MessageTypeEnum.AGREE:
                  String text = customDataMap["text"]! as String;
                  return MessageItem(
                    messageType: MessageTypeEnum.NORMAL,
                    avatarUrl: avatarUrl,
                    isSelf: isSelf,
                    isPeerRead: timMsg.isPeerRead ?? false,
                    msgTimestamp: msgTimeStamp,
                    msgText: text,
                    selfAvatarCardId: relation.isApplicant == 1
                        ? relation.addCardId
                        : relation.targetCardId,
                    otherAvatarCardId: relation.isApplicant == 1
                        ? relation.targetCardId
                        : relation.addCardId,
                  );
                case MessageTypeEnum.QR:
                  String url = customDataMap["url"]! as String;
                  return MessageItem(
                    messageType: MessageTypeEnum.IMG,
                    avatarUrl: avatarUrl,
                    isSelf: isSelf,
                    isPeerRead: timMsg.isPeerRead ?? false,
                    msgTimestamp: msgTimeStamp,
                    imgUrl: url,
                    selfAvatarCardId: relation.isApplicant == 1
                        ? relation.addCardId
                        : relation.targetCardId,
                    otherAvatarCardId: relation.isApplicant == 1
                        ? relation.targetCardId
                        : relation.addCardId,
                  );
                default:
                  return Container();
              }
            default:
              return Container();
          }
        },
      );
      body = idleBody;
    }
    return Scaffold(
      appBar: appbar(relation),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(child: body),
          msgTextField(),
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //同意
                iconButton(
                  Icons.favorite,
                  () async {
                    if (relation.isApplicant == IsApplicantEnum.YES) {
                      SmartDialog.showToast("你是申请者哦～");
                      return;
                    } else if (relation.status == RelationTypeEnum.AGREED) {
                      SmartDialog.showToast("你已经同意过了哦～");
                      return;
                    }
                    if (sendMessageCheckStatus(userStatus, context)) {
                      final res = await showOkCancelAlertDialog(
                        context: context,
                        title: "同意交友申请",
                        message: "确定同意对方的交友申请吗？同意后你们将交换二维码哦",
                        okLabel: "确定",
                        cancelLabel: "取消",
                      );
                      if (res == OkCancelResult.ok) {
                        //设置关系为同意
                        await RelationService.setRelation(
                            uid: int.parse(userId),
                            targetUid: StorageManager.uid,
                            status: RelationTypeEnum.AGREED);
                        conversionListModel.changeRelationStatus(
                            userId, RelationTypeEnum.AGREED);
                        //发送同意消息
                        sendAgreeMessage(
                          userId: userId,
                          wxUrl: relation.tWx,
                          qqUrl: relation.tQq,
                          autoWxUrl: relation.uWx,
                          autoQqUrl: relation.uQq,
                        );
                      }
                    }
                  },
                ),
                //拒绝
                iconButton(
                  Icons.close,
                  () async {
                    if (relation.isApplicant == IsApplicantEnum.YES) {
                      SmartDialog.showToast("你是申请者哦～");
                      return;
                    } else if (relation.status == RelationTypeEnum.AGREED) {
                      SmartDialog.showToast("你已经同意过了哦～");
                      return;
                    }
                    if (sendMessageCheckStatus(userStatus, context)) {
                      final res = await showOkCancelAlertDialog(
                        context: context,
                        title: "拒绝交友申请",
                        message: "确定拒绝对方的交友申请吗？拒绝后双方将无法再交流并删除对话",
                        okLabel: "确定",
                        cancelLabel: "取消",
                      );
                      if (res == OkCancelResult.ok) {
                        //设置关系为拒绝
                        await RelationService.setRelation(
                            uid: int.parse(userId),
                            targetUid: StorageManager.uid,
                            status: RelationTypeEnum.REFUSED);
                        //发送删除消息
                        sendRefuseMessage(userId: userId);
                        //删除好友和对话消息，退出页面
                        conversionListModel.deleteConversion(userId);
                        messageModel.clearMessage(userId);
                        Navigator.of(context).pop();
                      } else {
                        return;
                      }
                    }
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
                      sendImgMessage(
                          userStatus: userStatus,
                          context: context,
                          path: file!.path,
                          userId: userId);
                    }
                  },
                ),
                //名片消息
                iconButton(
                  Icons.web_outlined,
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
                            .pushNamed(AppRouter.MainPageRoute, arguments: 1);
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

  Widget msgTextField() {
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
              suffixIcon: GestureDetector(
                child: Icon(Icons.send),
                onTap: () async {
                  if (_controller.text.length == 0) {
                    return;
                  }
                  await sendTextMessage(
                      userId: userId,
                      text: _controller.text,
                      context: context,
                      userStatus: userStatus);
                  _controller.text = "";
                },
              ),
              suffixIconConstraints: BoxConstraints(minHeight: 20.r),
            ),
            onSubmitted: (text) async {
              if (text.length == 0) {
                return;
              }
              await sendTextMessage(
                  userId: userId,
                  text: text,
                  context: context,
                  userStatus: userStatus);
              _controller.text = "";
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
        await sendCardMessage(
          cardId: card.id!,
          cardType: card.type!,
          userId: userId,
          context: context,
          userStatus: userStatus,
        );
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

  PreferredSizeWidget appbar(RelationEntity relation) {
    String friendName =
        relation.isApplicant == 1 ? relation.tName! : relation.uName!;
    String cardDesc = CardTypeEnum.getCardType(relation.targetCardType!).desc;
    return PreferredSize(
        child: SafeArea(
          child: Material(
            elevation: 0.5,
            color: Colors.white,
            child: Stack(
              children: [
                Positioned(
                  left: 5.r,
                  child: BackButton(
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            friendName,
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                          SizedBox(
                            width: 1.r,
                          ),
                          SvgPicture.asset(
                            GenderTypeEnum.getGender(relation.gender!).svgPath,
                            width: 13.r,
                            color: GenderTypeEnum.getGender(relation.gender!)
                                .color,
                          ),
                          SizedBox(
                            width: 2.r,
                          ),
                          Text(
                            getAge(relation.birthDate).toString(),
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.r),
                        child: Text(
                          "${relation.city!} · ${relation.isApplicant == 1 ? "你看过ta的$cardDesc名片" : "ta看过你的$cardDesc名片"}",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        preferredSize: Size(MediaQuery.of(context).size.width, 54.r));
  }

  get userStatus => int.parse(userModel.userStatus);
}
