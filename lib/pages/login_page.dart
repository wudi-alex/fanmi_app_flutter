import 'package:dio/dio.dart';
import 'package:fanmi/config/weixin_config.dart';
import 'package:fanmi/net/login_service.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluwx/fluwx.dart';
import 'package:provider/provider.dart';
import 'package:tencent_kit/tencent_kit.dart';

///微信/qq/苹果/邮箱登录
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isWeixinInstalled = false;
  bool isQQInstalled = false;
  late WeChatAuthResponse weixinAuthResponse;
  TencentLoginResp? _qqLoginResp;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userModel = Provider.of<UserModel>(context);
    return Container();
  }

  init() async {
    ///检测是否安装微信
    await registerWxApi(
        appId: WeixinConfig.APP_ID,
        doOnAndroid: true,
        doOnIOS: true,
        universalLink: WeixinConfig.UNI_LINK);
    isWeChatInstalled.then((v) {
      setState(() {
        isWeixinInstalled = v;
      });
    });
    weChatResponseEventHandler.distinct((a, b) => a == b).listen((res) {
      if (res is WeChatAuthResponse) {
        setState(() {
          weixinAuthResponse = res;
        });
        if (weixinAuthResponse.errCode == 0) {
          print("listen, ${weixinAuthResponse.code}");
          EasyLoading.show(status: '登录中');
          LoginService.weixinLogin(code: weixinAuthResponse.code!)
              .then((resp) => next(resp))
              .onError((e, s) {
            e as DioError;
            EasyLoading.showError(e.error.message);
          });
        }
      }
    });
  }
}
