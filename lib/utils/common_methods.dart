import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/view_models/card_list_model.dart';
import 'package:fanmi/view_models/conversion_list_model.dart';
import 'package:fanmi/view_models/message_list_model.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

logout(BuildContext context) async {
  await TencentImSDKPlugin.v2TIMManager.logout();

  ///内存清除
  Provider.of<ConversionListModel>(context, listen: false).clear();
  Provider.of<UserModel>(context, listen: false).clear();
  Provider.of<MessageListModel>(context, listen: false).clear();
  Provider.of<CardListModel>(context, listen: false).clear();

  ///本地缓存清除
  StorageManager.clear();
  Navigator.of(context).pushNamed(AppRouter.LoginPageRoute);
}

initData(BuildContext context) async {
  Provider.of<ConversionListModel>(context, listen: false).init();
  var sig = await Provider.of<UserModel>(context, listen: false).init();
  Provider.of<CardListModel>(context, listen: false).init();

  ///tim登录
  await TencentImSDKPlugin.v2TIMManager.login(
    userID: StorageManager.uid.toString(),
    userSig: sig,
  );
}
