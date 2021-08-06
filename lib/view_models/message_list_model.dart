import 'package:fanmi/utils/storage_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MessageListModel extends ChangeNotifier {
  Map<String, List<V2TimMessage>> messageMap = Map();

  get pullCnt => 20;

  Future<bool> pullHistoryMessage(String userId, String? lastMsgID) async {
    var res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .getC2CHistoryMessageList(
            userID: userId, count: pullCnt, lastMsgID: lastMsgID);
    if (res.code == 0) {
      updateMessage(userId, res.data!);
      notifyListeners();
      return res.data!.length > pullCnt;
    } else {
      SmartDialog.showToast("获取历史消息失败");
      return false;
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
    messageMap[key]!
        .sort((left, right) => left.timestamp!.compareTo(right.timestamp!));
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

  clear() {
    messageMap = new Map();
    notifyListeners();
  }

  //todo:发送消息，有文字消息/图片消息/名片消息/同意拒绝消息
  sendMessage() {}
}
