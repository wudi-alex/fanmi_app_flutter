import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  /// app全局配置
  static late SharedPreferences sp;

  /// 必备数据的初始化操作
  static init() async {
    sp = await SharedPreferences.getInstance();
  }

  static clear() async {
    await sp.clear();
  }
}
