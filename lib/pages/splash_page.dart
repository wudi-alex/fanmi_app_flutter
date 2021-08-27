import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/config/tim_config.dart';
import 'package:fanmi/enums/message_type_enum.dart';
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
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
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
            //接受到新消息
            onRecvNewMessage: (data) async {
              print('收到新消息');
              var messageModel =
                  Provider.of<MessageListModel>(context, listen: false);
              var conversionModel =
                  Provider.of<ConversionListModel>(context, listen: false);
              //假如有消息过来，则补充查询关系
              if (!conversionModel.relationInfoMap.containsKey(data.userID)) {
                conversionModel.pullRelationData([data.userID!]);
              }
              try {
                String userId = data.userID!;
                if (data.elemType == MessageElemType.V2TIM_ELEM_TYPE_CUSTOM) {
                  switch (int.parse(data.customElem!.desc!)) {
                    case MessageTypeEnum.AGREE:
                      var relationMap = conversionModel.relationInfoMap;
                      if (userId != StorageManager.uid.toString()) {
                        sendAgreeMessage(
                            userId: userId,
                            wxUrl: relationMap[userId]!.uWx,
                            qqUrl: relationMap[userId]!.uQq,
                            isApplicant: true);
                      }
                      break;
                    case MessageTypeEnum.REFUSE:
                      if (messageModel.nowTalkingUserId == userId) {
                        //停留当前聊天页面，直接退出
                        var res = await showOkAlertDialog(
                          barrierDismissible: false,
                          context: context,
                          title: "拒绝消息",
                          message: "很遗憾，对方拒绝了你的申请，对话关闭",
                        );
                        if (res == OkCancelResult.ok) {
                          Navigator.of(context).pop();
                          conversionModel.deleteConversion(userId);
                          messageModel.clearMessage(userId);
                        }
                      } else {
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

    //会话监听
    timManager.getConversationManager().setConversationListener(
          listener: V2TimConversationListener(
            onNewConversation: (data) {
              var conversionModel =
                  Provider.of<ConversionListModel>(context, listen: false);
              conversionModel.updateConversionInfoMap(data);
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
