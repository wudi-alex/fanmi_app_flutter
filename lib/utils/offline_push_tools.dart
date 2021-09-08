import 'package:fanmi/utils/platform_utils.dart';
import 'package:flutter_apns/apns.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class OfflinePushTools {
  static final PushConnector connector = createPushConnector();

  static setOfflinePush() async {
    if (Platform.isIOS) {
      // const bool isReleaseMode = bool.fromEnvironment("dart.vm.product");

      final connector = OfflinePushTools.connector;
      connector.configure();
      connector.requestNotificationPermissions();
      connector.token.addListener(() async {
        print('Token ${connector.token.value}');

        V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
            .getOfflinePushManager()
            .setOfflinePushConfig(
                businessID: 29300, token: connector.token.value ?? "");

        if (res.code == 0) {
          print("设置推送成功");
        } else {
          print("设置推送失败${res.desc}");
        }
      });
    } else {}
  }
}
