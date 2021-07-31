import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class MessageListModel extends ChangeNotifier {
  Map<String, List<V2TimMessage>> _messageMap = new Map();

  get messageMap => _messageMap;

  init() {}

  addOneMessageIfNotExits(String key, V2TimMessage message) {
    print("======1111111>>${key} ${message.status} ${message.progress}");
    if (_messageMap.containsKey(key)) {
      bool hasMessage =
          _messageMap[key]!.any((element) => element.msgID == message.msgID);
      if (hasMessage) {
        int idx = _messageMap[key]!
            .indexWhere((element) => element.msgID == message.msgID);
        _messageMap[key]![idx] = message;
      } else {
        _messageMap[key]!.add(message);
      }
    } else {
      List<V2TimMessage> messageList = [];
      messageList.add(message);
      _messageMap[key] = messageList;
    }
    _messageMap[key]!
        .sort((left, right) => left.timestamp!.compareTo(right.timestamp!));
    print("======1111111>>2222${key} ${message.status} ${message.progress}");
    notifyListeners();
  }

  updateC2CMessageByUserId(String userid) {
    String key = userid;
    if (_messageMap.containsKey(key)) {
      List<V2TimMessage> msgList = _messageMap[key]!;
      msgList.forEach((element) {
        element.isPeerRead = true;
      });
      _messageMap[key] = msgList;
      notifyListeners();
    } else {
      print("会话列表不存在这个userid key");
    }
  }

  clear() {
    _messageMap = new Map();
    notifyListeners();
  }

  //todo:发送消息，有文字消息/图片消息/名片消息
  sendMessage() {}
}
