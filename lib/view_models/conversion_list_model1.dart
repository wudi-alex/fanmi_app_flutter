import 'package:fanmi/config/page_size_config.dart';
import 'package:fanmi/enums/relation_entity.dart';
import 'package:fanmi/generated/json/relation_entity_helper.dart';
import 'package:fanmi/net/relation_service.dart';
import 'package:fanmi/net/status_code.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class ConversionListModel extends ChangeNotifier {
  String nextSeq = '0';

  Map<String, V2TimConversation> conversionMap = {};
  Map<String, RelationEntity> relationInfoMap = {};

  get pullCnt => PageSizeConfig.CONVERSION_PAGE_SIZE;

  get unreadCntTotal {
    int cnt = 0;
    conversionMap.forEach((userId, conversionInfo) {
      cnt += conversionInfo.unreadCount ?? 0;
    });
    return cnt;
  }

  init() async {
    while (true) {
      bool allLoad = await pullData();
      if (allLoad) {
        break;
      }
    }
  }

  pullData() async {
    var userList = await pullConversionData(nextSeq);
    await pullRelationData(userList);
    return userList.length < pullCnt;
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

  pullRelationData(List<String> users) async {
    if (users.isEmpty) {
      return;
    }
    try {
      var resp = await RelationService.queryRelation(targetUidList: users);
      if (resp.code == StatusCode.SUCCESS) {
        List<RelationEntity> relationList = resp.data
            .map<RelationEntity>((item) =>
                relationEntityFromJson(RelationEntity(), item)
                    as RelationEntity)
            .toList();
        relationList.forEach((relation) {
          relationInfoMap[relation.uid.toString()] = relation;
        });
        await StorageManager.setRelationList(relationInfoMap.values.toList());
      }
    } catch (e, s) {
      SmartDialog.showToast("获取对话用户信息失败");
    }
  }

  updateConversionInfoMap(List<V2TimConversation?> newList,
      {bool isDelete = false}) {
    Map<String, V2TimConversation> newMap = {};
    newList.forEach((element) {
      if (element!.lastMessage == null) {
        return;
      }
      newMap[element.userID!] = element;
    });
    updateMap(newMap: newMap, originalMap: conversionMap, isDelete: isDelete);
  }

  //删除对话
  Future deleteConversion(String userId) async {
    var conversionId = conversionMap[userId]!.conversationID;
    try {
      await TencentImSDKPlugin.v2TIMManager
          .getConversationManager()
          .deleteConversation(
            conversationID: conversionId,
          );
    } catch (e, s) {}
    updateConversionInfoMap([conversionMap[userId]], isDelete: true);
  }

  clear() {
    conversionMap = {};
    relationInfoMap = {};
    notifyListeners();
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
