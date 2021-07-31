
import 'package:fanmi/view_models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

///todo: 微信/qq/苹果/邮箱登录
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _init() async {}

  @override
  Widget build(BuildContext context) {
    var userModel = Provider.of<UserModel>(context);
    return Container();
  }

  timLogin() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.login(
      userID: '',
      userSig: '',
    );
  }
}
