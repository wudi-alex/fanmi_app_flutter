import 'package:fanmi/update/update_parser.dart';
import 'package:fanmi/update/update_prompter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'common.dart';
import 'http.dart';

/// 版本更新管理
class UpdateManager {
  static String? appUrl;

  ///全局初始化
  static init({String? baseUrl, Map<String, dynamic>? headers}) {
    HttpUtils.init(baseUrl: baseUrl, headers: headers);
  }

  static void checkUpdate(BuildContext context, String url,
      {bool isAuto = true}) {
    HttpUtils.get(url).then((response) {
      UpdateParser.parseJson(Map<String, dynamic>.from(response)).then((value) {
        appUrl = value!.downloadUrl;
        if (!isAuto && !value.hasUpdate) {
          SmartDialog.showToast("已经是最新版本啦～");
        } else {
          UpdatePrompter(
              updateEntity: value,
              onInstall: (String filePath) {
                CommonUtils.installAPP(filePath);
              }).show(context);
        }
      });
    }).catchError((onError) {
      print(onError.toString());
    });
  }
}

typedef InstallCallback = Function(String filePath);
