import 'dart:convert';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/entity/mine_board_entity.dart';
import 'package:fanmi/enums/message_type_enum.dart';
import 'package:fanmi/enums/user_status_enum.dart';
import 'package:fanmi/generated/json/mine_board_entity_helper.dart';
import 'package:fanmi/net/common_service.dart';
import 'package:fanmi/net/user_service.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/view_models/card_list_model.dart';
import 'package:fanmi/view_models/conversion_list_model.dart';
import 'package:fanmi/view_models/message_list_model.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

logout(BuildContext context) async {
  await TencentImSDKPlugin.v2TIMManager.logout();

  ///内存清除
  Provider.of<ConversionListModel>(context, listen: false).clear();
  Provider.of<UserModel>(context, listen: false).clear();
  Provider.of<MessageListModel>(context, listen: false).clear();
  Provider.of<CardListModel>(context, listen: false).clear();

  ///本地缓存清除
  StorageManager.clear();
  // Navigator.of(context).pushNamed(AppRouter.LoginPageRoute);
}

initData(BuildContext context) {
  Provider.of<UserModel>(context, listen: false).init(() {
    Provider.of<ConversionListModel>(context, listen: false).init();
  }, () {
    Provider.of<ConversionListModel>(context, listen: false).errorCallBack();
  });
  Provider.of<CardListModel>(context, listen: false).init();
}

catchError(Object? error, String errorMsg) {
  if (error is DioError) {
    EasyLoading.showError(error.error.message);
  } else {
    EasyLoading.showError(errorMsg);
  }
}

//设置已读
setRead(String userId) async {
  await TencentImSDKPlugin.v2TIMManager
      .getMessageManager()
      .markC2CMessageAsRead(
        userID: userId,
      );
}

//发送消息时检查用户状态
sendMessageCheckStatus(int userStatus, BuildContext context) {
  switch (userStatus) {
    case UserStatusEnum.USER_STATUS_FORBIDDEN:
      showOkAlertDialog(
        context: context,
        title: "发送消息",
        message: "封禁状态无法发送消息，如有需求请联系管理员申诉",
      );
      return false;
    case UserStatusEnum.USER_STATUS_FREEZE:
      showOkAlertDialog(
        context: context,
        title: "发送消息",
        message: "冻结状态无法发送消息，如有需求请联系管理员申诉",
      );
      return false;
    default:
      return true;
  }
}

//发送文字消息
sendTextMessage({
  required String userId,
  required String text,
  required BuildContext context,
  required int userStatus,
}) async {
  if (sendMessageCheckStatus(userStatus, context)) {
    await TencentImSDKPlugin.v2TIMManager.sendC2CTextMessage(
      text: text,
      userID: userId,
    );
  }
}

//发送名片消息
sendCardMessage(
    {required int cardId,
    required int cardType,
    required String userId,
    required int userStatus,
    required BuildContext context}) async {
  if (sendMessageCheckStatus(userStatus, context)) {
    await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendCustomMessage(
          data: json.encode({
            "card_id": cardId,
            "card_type": cardType,
          }),
          receiver: userId,
          groupID: "",
          priority: 0,
          desc: MessageTypeEnum.CARD.toString(),
          offlinePushInfo: OfflinePushInfo(title: '你收到了一条名片消息'),
        );
  }
}

//发送图片消息
sendImgMessage({
  required int userStatus,
  required BuildContext context,
  required String path,
  required String userId,
}) async {
  if (sendMessageCheckStatus(userStatus, context)) {
    await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendImageMessage(
          imagePath: path,
          receiver: userId,
          groupID: "",
          priority: 0,
          onlineUserOnly: false,
          isExcludedFromUnreadCount: false,
        );
  }
}

//发送二维码消息
sendQrMessage({required String userId, required String url}) async {
  await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendCustomMessage(
        receiver: userId,
        groupID: "",
        priority: 0,
        desc: MessageTypeEnum.QR.toString(),
        data: json.encode({
          "url": url,
        }),
        offlinePushInfo: OfflinePushInfo(title: '你收到了一条二维码消息'),
      );
}

//发送同意消息
sendAgreeMessage(
    {required String userId,
    String? wxUrl,
    String? qqUrl,
    bool isApplicant = false}) async {
  String text = "${isApplicant ? "谢谢你😄" : "我同意你的好友申请啦😊️"}，"
      "这是我的${(wxUrl != null && wxUrl.isNotEmpty) ? ((qqUrl != null && qqUrl.isNotEmpty) ? "微信&QQ" : "微信") : "QQ"}二维码 (在「我的-通讯录」里也有哦～";
  if (isApplicant) {
    await TencentImSDKPlugin.v2TIMManager.sendC2CTextMessage(
      text: text,
      userID: userId,
    );
  } else {
    await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendCustomMessage(
          receiver: userId,
          groupID: "",
          desc: isApplicant
              ? MessageTypeEnum.NORMAL.toString()
              : MessageTypeEnum.AGREE.toString(),
          data: json.encode({
            "text": text,
          }),
          offlinePushInfo: OfflinePushInfo(title: '你收到了一条同意交友申请消息～'),
        );
  }
  //发送二维码消息
  if (wxUrl != null && wxUrl.isNotEmpty) {
    await sendQrMessage(userId: userId, url: wxUrl);
  }
  if (qqUrl != null && qqUrl.isNotEmpty) {
    await sendQrMessage(userId: userId, url: qqUrl);
  }
}

//发送拒绝消息
sendRefuseMessage({
  required String userId,
}) async {
  await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendCustomMessage(
        receiver: userId,
        groupID: "",
        priority: 0,
        desc: MessageTypeEnum.REFUSE.toString(),
        data: '{}',
      );
}

String prefixWrapper(String str) =>
    Platform.isIOS ? "Tag_SNS_Custom_$str" : str;

Future<bool> noConnect() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult == ConnectivityResult.none;
}

//定时更新最后登录时间和面板数据
timerUpdate(BuildContext context) async {
  if (StorageManager.isLogin) {
    UserService.setUserInfo({
      "last_login_time": DateTime.now().toString(),
    });
    UserService.getMineBoardData().then((boardDataResp) {
      print('set boardData');
      var boardDataEntity =
          mineBoardEntityFromJson(MineBoardEntity(), boardDataResp.data);
      var model = Provider.of<UserModel>(context, listen: false);
      model.setMineBoard(boardDataEntity);
    });
  }
}
