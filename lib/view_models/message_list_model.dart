import 'package:fanmi/config/page_size_config.dart';
import 'package:fanmi/view_models/view_state_model.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MessageListModel extends ViewStateModel {
  String nowTalkingUserId = "";
  Map<String, List<V2TimMessage>> messageMap = Map();
  List<String> initUserList = [];

  get pullCnt => PageSizeConfig.MESSAGE_PAGE_SIZE;

  initData(String userId) async {
    setBusy();
    await pullHistoryMessage(userId);
    setIdle();
  }

  pullHistoryMessage(String userId) async {
    if (!initUserList.contains(userId)) {
      initUserList.add(userId);
      for (int i = 0; i < 5; i++) {
        var lastMsgID = i > 0 ? messageMap[userId]!.first.msgID : null;
        var res = await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .getC2CHistoryMessageList(
                userID: userId, count: pullCnt, lastMsgID: lastMsgID);
        if (res.data!=null && res.data!.isNotEmpty) {
          updateMessage(userId, res.data!);
        } else {
          break;
        }
      }
    }
  }

  updateMessage(String userId, List<V2TimMessage> value) {
    if (messageMap.containsKey(userId)) {
      messageMap[userId]!.addAll(value);
    } else {
      List<V2TimMessage> messageList = [];
      messageList.addAll(value);
      messageMap[userId] = messageList;
    }
    //去重
    Map<String, V2TimMessage> rebuildMap = new Map<String, V2TimMessage>();
    messageMap[userId]!.forEach((element) {
      rebuildMap[element.msgID!] = element;
    });
    messageMap[userId] = rebuildMap.values.toList();
    rebuildMap.clear();
    messageMap[userId]!
        .sort((left, right) => left.timestamp!.compareTo(right.timestamp!));
  }

  addOneMessageIfNotExits(String key, V2TimMessage message) {
    print("======1111111>>${key} ${message.status} ${message.progress}");
    if (messageMap.containsKey(key)) {
      bool hasMessage =
          messageMap[key]!.any((element) => element.msgID == message.msgID);
      if (hasMessage) {
        int idx = messageMap[key]!
            .indexWhere((element) => element.msgID == message.msgID);
        messageMap[key]![idx] = message;
      } else {
        messageMap[key]!.add(message);
      }
    } else {
      List<V2TimMessage> messageList = [];
      messageList.add(message);
      messageMap[key] = messageList;
    }
    print("======1111111>>2222${key} ${message.status} ${message.progress}");
    notifyListeners();
  }

  updateReadReceiptByUserId(String userId) {
    String key = userId;
    if (messageMap.containsKey(key)) {
      List<V2TimMessage> msgList = messageMap[key]!;
      msgList.forEach((element) {
        element.isPeerRead = true;
      });
      messageMap[key] = msgList;
      notifyListeners();
    } else {
      print("会话列表不存在$userId key");
    }
  }

  clearMessage(String userId){
    messageMap.remove(userId);
    notifyListeners();
  }

  clear() {
    messageMap = new Map();
    notifyListeners();
  }

}
