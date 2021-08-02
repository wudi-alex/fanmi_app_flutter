import 'dart:convert';

import 'package:fanmi/config/tim_config.dart';
import 'package:fanmi/enums/is_applicant_enum.dart';
import 'package:fanmi/enums/message_type_enum.dart';
import 'package:fanmi/utils/common_methods.dart';
import 'package:fanmi/view_models/conversion_list_model.dart';
import 'package:fanmi/view_models/message_list_model.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    initSDK();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  initSDK() async {
    V2TIMManager timManager = TencentImSDKPlugin.v2TIMManager;
    await timManager.initSDK(
      sdkAppID: TimConfig.APP_ID,
      loglevel: LogLevel.V2TIM_LOG_DEBUG,

      ///todo:用户状态监听
      listener: V2TimSDKListener(
        onSelfInfoUpdated: (data) {
          Provider.of<UserModel>(context, listen: false).setUserTimInfo(data);
        },
        onKickedOffline: () {
          SmartDialog.showToast('检测到你的账号在另一设备登录');
          logout(context);
        },
        onUserSigExpired: () {
          SmartDialog.showToast('登录凭证过期，请重新登录');
          logout(context);
        },
      ),
    );

    //高级消息监听
    timManager.getMessageManager().addAdvancedMsgListener(
          listener: V2TimAdvancedMsgListener(
            //已读回执监听
            onRecvC2CReadReceipt: (data) {
              print('收到了新消息 已读回执');
              List<V2TimMessageReceipt> list = data;
              list.forEach((element) {
                print("已读回执${element.userID} ${element.timestamp}");
                Provider.of<MessageListModel>(context, listen: false)
                    .updateReadReceiptByUserId(element.userID);
              });
            },
            //发送消息进度监听
            onSendMessageProgress: (message, progress) {
              //消息进度
              String key = message.userID!;
              try {
                Provider.of<MessageListModel>(
                  context,
                  listen: false,
                ).addOneMessageIfNotExits(key, message);
              } catch (err) {
                print("error $err");
              }
              print(
                  "消息发送进度 $progress ${message.timestamp} ${message.msgID} ${message.timestamp} ${message.status}");
            },
            //接受到新消息
            onRecvNewMessage: (data) {
              try {
                String key = data.userID!;
                //接收到好友申请消息，需要把消息里带过来的 名字/头像/是申请者/申请的名片id & type 更新好友信息
                if (data.customElem != null &&
                    data.customElem!.desc ==
                        MessageTypeEnum.APPLICATION.toString()) {
                  Map<String, String> customDataMap =
                      json.decode(data.customElem!.data!);
                  TencentImSDKPlugin.v2TIMManager
                      .getFriendshipManager()
                      .setFriendInfo(
                    friendRemark: customDataMap['name'],
                    userID: data.userID!,
                    friendCustomInfo: {
                      "avatar_url": customDataMap['avatar_url']!,
                      "is_applicant": IsApplicantEnum.YES.toString(),
                      "applied_card_id": customDataMap['applied_card_id']!,
                      "applied_card_type": customDataMap['applied_card_type']!,
                    },
                  );
                }
                Provider.of<MessageListModel>(context, listen: false)
                    .addOneMessageIfNotExits(key, data);
              } catch (err) {
                print(err);
              }
            },
          ),
        );
    //关系链监听
    timManager.getFriendshipManager().setFriendListener(
          listener: V2TimFriendshipListener(
              onFriendListAdded: (data) {
                Provider.of<ConversionListModel>(context, listen: false)
                    .updateFriendInfoMap(data);
              },
              onFriendListDeleted: (data) {
                Provider.of<ConversionListModel>(context, listen: false)
                    .updateFriendInfoMap(
                        data.map((v) => V2TimFriendInfo(userID: v)).toList(),
                        isDelete: true);
              },
              onFriendInfoChanged: (data) {
                Provider.of<ConversionListModel>(context, listen: false)
                    .updateFriendInfoMap(data);
              },
              onBlackListAdd: (data) {}),
        );
    //会话监听
    timManager.getConversationManager().setConversationListener(
          listener: V2TimConversationListener(
            onNewConversation: (data) {
              Provider.of<ConversionListModel>(context, listen: false)
                  .updateConversionInfoMap(data);
            },
            onConversationChanged: (data) {
              Provider.of<ConversionListModel>(context, listen: false)
                  .updateConversionInfoMap(data);
            },
          ),
        );
  }
}
