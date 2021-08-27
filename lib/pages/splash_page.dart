import 'dart:async';
import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/config/tim_config.dart';
import 'package:fanmi/enums/message_type_enum.dart';
import 'package:fanmi/net/relation_service.dart';
import 'package:fanmi/utils/common_methods.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/view_models/conversion_list_model.dart';
import 'package:fanmi/view_models/message_list_model.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late Timer _timer;
  int count = 3;

  @override
  void initState() {
    initSDK();
    if (StorageManager.isLogin) {
      initData(context);
    }
    startTime();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Image.asset(
            "assets/images/logo_trans_blue.png",
            width: 200.r,
            height: 200.r,
          ),
        ),
      ),
    );
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
            // onSendMessageProgress: (message, progress) {
            //   //消息进度
            //   String key = message.userID!;
            //   try {
            //     Provider.of<MessageListModel>(
            //       context,
            //       listen: false,
            //     ).addOneMessageIfNotExits(key, message);
            //   } catch (err) {
            //     print("error $err");
            //   }
            //   print(
            //       "消息发送进度 $progress ${message.timestamp} ${message.msgID} ${message.timestamp} ${message.status}");
            // },
            //接受到新消息
            onRecvNewMessage: (data) async {
              print('收到新消息');
              var messageModel =
                  Provider.of<MessageListModel>(context, listen: false);
              var conversionModel =
                  Provider.of<ConversionListModel>(context, listen: false);
              if (!conversionModel.friendInfoMap.containsKey(data.userID)) {
                conversionModel.pullFriendInfoData([data.userID!]);
              }
              try {
                String userId = data.userID!;
                if (data.elemType == MessageElemType.V2TIM_ELEM_TYPE_CUSTOM) {
                  switch (int.parse(data.customElem!.desc!)) {
                    //接收到好友申请消息，需要把消息里带过来的 名字/头像/是申请者/申请的名片id & type 更新好友信息
                    case MessageTypeEnum.APPLICATION:
                      Map<String, String> customDataMap =
                          Map<String, String>.from(
                              json.decode(data.customElem!.data!));
                      TencentImSDKPlugin.v2TIMManager
                          .getFriendshipManager()
                          .addFriend(
                            userID: userId,
                            addType: FriendType.V2TIM_FRIEND_TYPE_SINGLE,
                          )
                          .then((v) async {
                        V2TimCallback res = await TencentImSDKPlugin
                            .v2TIMManager
                            .getFriendshipManager()
                            .setFriendInfo(
                          friendRemark: customDataMap['name'],
                          userID: data.userID!,
                          friendCustomInfo: {
                            "Avatar": customDataMap['Avatar']!,
                            "IsApply": customDataMap['IsApply']!,
                            "cid": customDataMap['cid']!,
                            "ctype": customDataMap['ctype']!,
                            "WX": customDataMap["WX"]!,
                            "QQ": customDataMap["QQ"]!,
                          },
                        );
                        if (res.code == 0) {
                          V2TimValueCallback<List<V2TimFriendInfoResult>>
                              response = await TencentImSDKPlugin.v2TIMManager
                                  .getFriendshipManager()
                                  .getFriendsInfo(
                            userIDList: [userId],
                          );
                          Provider.of<ConversionListModel>(context,
                                  listen: false)
                              .updateFriendInfoMap(response.data!
                                  .map((e) => e.friendInfo!)
                                  .toList());
                        }
                      });
                      break;
                    case MessageTypeEnum.AGREE:
                      if (userId != StorageManager.uid.toString()) {
                        V2TimValueCallback<List<V2TimFriendInfoResult>>
                            response = await TencentImSDKPlugin.v2TIMManager
                                .getFriendshipManager()
                                .getFriendsInfo(
                          userIDList: [userId],
                        );
                        if (response.code == 0) {
                          var friendInfo = response.data![0].friendInfo;
                          sendAgreeMessage(
                              userId: userId,
                              wxUrl: friendInfo!
                                  .friendCustomInfo![prefixWrapper("WX")],
                              qqUrl: friendInfo
                                  .friendCustomInfo![prefixWrapper("QQ")],
                              isApplicant: true);
                        }
                      }
                      break;
                    case MessageTypeEnum.REFUSE:
                      if (messageModel.nowTalkingUserId == userId) {
                        //停留当前聊天页面，直接退出
                        var res = await showOkAlertDialog(
                          barrierDismissible: false,
                          context: context,
                          title: "拒绝消息",
                          message:
                              "很遗憾，${conversionModel.friendInfoMap[userId]!.friendRemark ?? "对方"}拒绝了你的申请，对话关闭",
                        );
                        if (res == OkCancelResult.ok) {
                          Navigator.of(context).pop();
                          conversionModel.deleteConversion(userId);
                          messageModel.clearMessage(userId);

                          Future.delayed(Duration(milliseconds: 100), () {
                            deleteFriend(userId: userId);
                          });
                        }
                      } else {
                        deleteFriend(userId: userId);
                        conversionModel.deleteConversion(userId);
                        messageModel.clearMessage(userId);
                      }
                  }
                }

                //假如不是拒绝消息, 则添加聊天记录
                if (data.elemType != MessageElemType.V2TIM_ELEM_TYPE_CUSTOM ||
                    data.customElem!.desc !=
                        MessageTypeEnum.REFUSE.toString()) {
                  messageModel.addOneMessageIfNotExits(userId, data);
                  if (messageModel.nowTalkingUserId == userId) {
                    //停留当前聊天页面，设置已读
                    setRead(userId);
                  }
                }
              } catch (err) {
                print(err);
              }
            },
          ),
        );

    //关系链监听
    timManager.getFriendshipManager().setFriendListener(
          listener: V2TimFriendshipListener(
              onFriendListAdded: (data) async {
                V2TimValueCallback<List<V2TimFriendInfoResult>> response =
                    await TencentImSDKPlugin.v2TIMManager
                        .getFriendshipManager()
                        .getFriendsInfo(
                          userIDList: data.map((e) => e.userID).toList(),
                        );
                Provider.of<ConversionListModel>(context, listen: false)
                    .updateFriendInfoMap(
                        response.data!.map((e) => e.friendInfo!).toList());
              },
              onFriendListDeleted: (data) {
                Provider.of<ConversionListModel>(context, listen: false)
                    .updateFriendInfoMap(
                        data.map((v) => V2TimFriendInfo(userID: v)).toList(),
                        isDelete: true);
              },
              onFriendInfoChanged: (data) async {
                V2TimValueCallback<List<V2TimFriendInfoResult>> response =
                    await TencentImSDKPlugin.v2TIMManager
                        .getFriendshipManager()
                        .getFriendsInfo(
                          userIDList: data.map((e) => e.userID).toList(),
                        );
                Provider.of<ConversionListModel>(context, listen: false)
                    .updateFriendInfoMap(
                        response.data!.map((e) => e.friendInfo!).toList());
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
              //假如是拒绝信息，不处理
              if (data.last.lastMessage!.elemType ==
                      MessageElemType.V2TIM_ELEM_TYPE_CUSTOM &&
                  data.last.lastMessage!.customElem!.desc ==
                      MessageTypeEnum.REFUSE.toString()) {
                return;
              }
              Provider.of<ConversionListModel>(context, listen: false)
                  .updateConversionInfoMap(data);

              Provider.of<MessageListModel>(
                context,
                listen: false,
              ).addOneMessageIfNotExits(data[0].userID!, data[0].lastMessage!);
            },
          ),
        );
  }

  startTime() async {
    //设置启动图生效时间
    var _duration = new Duration(seconds: 1);
    new Timer(_duration, () {
      // 空等1秒之后再计时
      _timer = new Timer.periodic(const Duration(milliseconds: 1000), (v) {
        count--;
        if (count == 0) {
          Navigator.of(context)
              .pushNamed(AppRouter.MainPageRoute, arguments: 0);
        } else {
          setState(() {});
        }
      });
    });
  }
}
