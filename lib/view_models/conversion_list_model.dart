import 'package:fanmi/enums/is_applicant_enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tuple/tuple.dart';

class ConversionListModel extends ChangeNotifier {
  String nextSeq = '0';

  Map<String, V2TimConversation> conversionMap = {};
  Map<String, V2TimUserFullInfo> userInfoMap = {};
  Map<String, V2TimFriendInfo> friendInfoMap = {};

  get pullCnt => 100;

  get conversionPageList {
    List<Tuple3<V2TimConversation, V2TimUserFullInfo?, V2TimFriendInfo?>> res =
        [];
    conversionMap.forEach((userId, conversionInfo) {
      List list = [];
      list.add(conversionInfo);
      if (userInfoMap.containsKey(userId)) {
        list.add(userInfoMap[userId]);
      } else {
        list.add(null);
      }
      if (friendInfoMap.containsKey(userId)) {
        list.add(friendInfoMap[userId]);
      } else {
        list.add(null);
      }
      res.add(Tuple3.fromList(list));
    });
    res.sort((v1, v2) => v2.item1.lastMessage!.timestamp!
        .compareTo(v1.item1.lastMessage!.timestamp!));
    return res;
  }

  pullData() async {
    var userList = await pullConversionData(nextSeq);
    await pullFriendInfoData(userList);
    await pullUserInfoData(userList);
    return userList.length > pullCnt;
  }

  Future<List<String>> pullConversionData(String nextSeq) async {
    V2TimValueCallback<V2TimConversationResult> response =
        await TencentImSDKPlugin.v2TIMManager
            .getConversationManager()
            .getConversationList(nextSeq: nextSeq, count: pullCnt);
    if (response.code == 0) {
      List<V2TimConversation?> res = response.data!.conversationList!;
      nextSeq = response.data!.nextSeq!;
      updateConversionInfoMap(res);
      return response.data!.conversationList!.map((e) => e!.userID!).toList();
    } else {
      SmartDialog.showToast("获取聊天对象信息错误");
      return [];
    }
  }

  pullFriendInfoData(List<String> users) async {
    if (users.isEmpty) {
      return;
    }
    V2TimValueCallback<List<V2TimFriendInfoResult>> response =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendsInfo(
              userIDList: users,
            );
    if (response.code == 0) {
      List<V2TimFriendInfoResult> res = response.data!;
      updateFriendInfoMap(res.map((v) => v.friendInfo!).toList());
    } else {
      SmartDialog.showToast("获取聊天对象信息错误");
    }
  }

  pullUserInfoData(List<String> users) async {
    if (users.isEmpty) {
      return;
    }
    V2TimValueCallback<List<V2TimUserFullInfo>> response =
        await TencentImSDKPlugin.v2TIMManager.getUsersInfo(
      userIDList: users,
    );
    if (response.code == 0) {
      List<V2TimUserFullInfo> res = response.data!;
      updateUserInfoMap(res);
    } else {
      SmartDialog.showToast("获取聊天对象信息错误");
    }
  }

  updateConversionInfoMap(List<V2TimConversation?> newList,
      {bool isDelete = false}) {
    Map<String, V2TimConversation> newMap = {};
    newList.forEach((element) {
      newMap[element!.userID!] = element;
    });
    updateMap(newMap: newMap, originalMap: conversionMap, isDelete: isDelete);
  }

  updateFriendInfoMap(List<V2TimFriendInfo> newList, {bool isDelete = false}) {
    Map<String, V2TimFriendInfo> newMap = {};
    newList.forEach((element) {
      newMap[element.userID] = element;
    });
    updateMap(newMap: newMap, originalMap: friendInfoMap, isDelete: isDelete);
  }

  updateUserInfoMap(List<V2TimUserFullInfo> newList, {bool isDelete = false}) {
    Map<String, V2TimUserFullInfo> newMap = {};
    newList.forEach((element) {
      newMap[element.userID!] = element;
    });
    updateMap(newMap: newMap, originalMap: userInfoMap, isDelete: isDelete);
  }

  clear() {
    conversionMap = {};
    userInfoMap = {};
    friendInfoMap = {};
    notifyListeners();
  }

  //删除对话。若对方为申请状态is_applicant=1，则等同于拒绝，删除好友
  Future<bool> deleteConversion(String userId) async {
    try {
      var conversionId = conversionMap[userId]!.conversationID;
      V2TimCallback delConRes = await TencentImSDKPlugin.v2TIMManager
          .getConversationManager()
          .deleteConversation(
            conversationID: conversionId,
          );
      bool delFriendResCode = true;
      if (friendInfoMap[userId]!.friendCustomInfo!["is_applicant"] ==
          IsApplicantEnum.YES.toString()) {
        V2TimValueCallback<List<V2TimFriendOperationResult>> res =
            await TencentImSDKPlugin.v2TIMManager
                .getFriendshipManager()
                .deleteFromFriendList(
          userIDList: [userId],
          deleteType: FriendType.V2TIM_FRIEND_TYPE_BOTH,
        );
        delFriendResCode = res.code == 0;
      }
      return delConRes.code == 0 && delFriendResCode;
    } catch (e, s) {
      print(e);
      return false;
    }
  }

  //发送申请消息（自定义消息），添加双向好友,把对方名片里的名字&头像设置friendInfo, 把自己的名字和头像放进消息里，等对方收到消息，设置名字和头像
  Future<bool> sendApplicantMessage(
      String userId, String selfName, String selfAvatarUrl) async {
    try {
      V2TimValueCallback<V2TimFriendOperationResult> addFriendRes =
          await TencentImSDKPlugin.v2TIMManager
              .getFriendshipManager()
              .addFriend(
                userID: userId,
                addType: FriendType.V2TIM_FRIEND_TYPE_BOTH,
              );
      if (addFriendRes.code == 0) {
        V2TimCallback setFriendRes = await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .setFriendInfo(
                friendRemark: selfName,
                userID: userId,
                friendCustomInfo: {"avatar_url": selfAvatarUrl});
        return setFriendRes.code == 0;
      } else {
        return false;
      }
    } catch (e, s) {
      print(e);
      return false;
    }
  }

  updateMap<T>(
      {required Map<String, T> newMap,
      required Map<String, T> originalMap,
      required bool isDelete}) {
    newMap.forEach((key, value) {
      if (isDelete) {
        if (originalMap.containsKey(key)) {
          originalMap.remove(key);
        }
      } else {
        originalMap[key] = value;
      }
    });
    notifyListeners();
  }
}
