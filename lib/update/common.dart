import 'dart:io';

import 'package:app_installer/app_installer.dart';
import 'package:fanmi/config/appstore_config.dart';
import 'package:fanmi/update/entity/update_entity.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

class CommonUtils {
  CommonUtils._internal();

  static String getTargetSize(double kbSize) {
    if (kbSize <= 0) {
      return "";
    } else if (kbSize < 1024) {
      return "${kbSize.toStringAsFixed(1)}KB";
    } else if (kbSize < 1048576) {
      return "${(kbSize / 1024).toStringAsFixed(1)}MB";
    } else {
      return "${(kbSize / 1048576).toStringAsFixed(1)}GB";
    }
  }

  ///获取下载缓存路径
  static Future<String> getDownloadDirPath() async {
    Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }

  ///根据更新信息获取apk安装文件
  static Future<File> getApkFileByUpdateEntity(
      UpdateEntity updateEntity) async {
    String appName = getApkNameByDownloadUrl(updateEntity.downloadUrl);
    String dirPath = await getDownloadDirPath();
    return File("$dirPath/${updateEntity.versionName}/$appName");
  }

  ///根据下载地址获取文件名
  static String getApkNameByDownloadUrl(String downloadUrl) {
    if (downloadUrl.isEmpty) {
      return "temp_${currentTimeMillis()}.apk";
    } else {
      String appName = downloadUrl.substring(downloadUrl.lastIndexOf("/") + 1);
      if (!appName.endsWith(".apk")) {
        appName = "temp_${currentTimeMillis()}.apk";
      }
      return appName;
    }
  }

  static int currentTimeMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  ///获取应用包信息
  static Future<PackageInfo> getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  ///获取应用版本号
  static Future<String> getVersionCode() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  ///获取应用包名
  static Future<String> getPackageName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.packageName;
  }

  /// 安装apk
  static void installAPP(String uri) async {
    if (Platform.isAndroid) {
      // String packageName = await CommonUtils.getPackageName();
      // InstallPlugin.installApk(uri, packageName);
      AppInstaller.installApk(uri);
    } else {
      AppInstaller.goStore("", AppStoreConfig.APPSTORE_ID);
    }
  }
}
