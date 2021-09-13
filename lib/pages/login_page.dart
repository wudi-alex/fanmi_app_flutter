import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/config/asset_constants.dart';
import 'package:fanmi/config/qq_config.dart';
import 'package:fanmi/entity/user_info_entity.dart';
import 'package:fanmi/net/login_service.dart';
import 'package:fanmi/utils/common_methods.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluwx/fluwx.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tencent_kit/tencent_kit.dart';
import 'package:fanmi/generated/json/user_info_entity_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  late UserModel userModel;
  bool agree = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: IconButton(
        icon: Icon(
          Icons.clear,
          color: Colors.black,
        ),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.MainPageRoute, ModalRoute.withName('/'),
              arguments: 0);
        },
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AssetConstants.fanmi_logo,
                width: 150.r,
                height: 150.r,
              ),
              SizedBox(
                height: 100.r,
              ),
              isWeixinInstalled
                  ? GestureDetector(
                      child: customButton(
                          "assets/svg/weixin.svg", "微信登录", Colors.green),
                      onTap: () async {
                        bool res = await sendWeChatAuth(
                            scope: "snsapi_userinfo",
                            state: "wechat_sdk_demo_test");
                      })
                  : SizedBox.shrink(),
              isQQInstalled
                  ? GestureDetector(
                      child: customButton(
                        "assets/svg/QQ.svg",
                        "QQ登录",
                        Colors.blue,
                      ),
                      onTap: () async {
                        Tencent.instance.login(
                          scope: <String>[TencentScope.GET_SIMPLE_USERINFO],
                        );
                      },
                    )
                  : SizedBox.shrink(),
              GestureDetector(
                child:
                    customButton("assets/svg/email.svg", "邮箱登录", Colors.cyan),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(AppRouter.EmailLoginPageRoute);
                },
              ),
              SizedBox(
                height: 7.r,
              ),
              Platform.isIOS ? appleButton() : SizedBox.shrink(),
              SizedBox(
                height: 14.r,
              ),
              RichText(
                text: TextSpan(
                    text: "登录即代表同意",
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.black),
                    children: [
                      TextSpan(
                        text: "《隐私政策》",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.of(context)
                              .pushNamed(AppRouter.MinePrivacyPolicyPageRoute),
                      ),
                      TextSpan(
                        text: "及",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.black),
                      ),
                      TextSpan(
                        text: "《用户协议》",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.of(context)
                              .pushNamed(AppRouter.MineUserPolicyPageRoute),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  init() async {
    ///检测是否安装微信
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
            print(e);
            EasyLoading.showError("微信登录失败");
            EasyLoading.dismiss();
          });
        }
      }
    });

    Tencent.instance.isQQInstalled().then((v) {
      setState(() {
        isQQInstalled = v;
      });
    });

    Tencent.instance.loginResp().listen((resp) async {
      EasyLoading.show(status: '登录中');
      setState(() {
        _qqLoginResp = resp;
        final String content = 'login: ${resp.openid} - ${resp.accessToken}';
        print(content);
      });
      TencentUserInfoResp userInfo = await Tencent.instance.getUserInfo(
        appId: QQConfig.appId,
        openid: _qqLoginResp!.openid!,
        accessToken: _qqLoginResp!.accessToken!,
      );
      LoginService.qqLogin(
        openId: _qqLoginResp!.openid!,
        name: userInfo.nickname!,
        avatarUrl: userInfo.figureurlQq!,
      ).then((resp) => next(resp)).onError((e, s) {
        EasyLoading.showError("QQ登录失败");
        EasyLoading.dismiss();
      });
    });

    userModel = Provider.of<UserModel>(context, listen: false);

    if (!mounted) return;
  }

  next(Response resp) {
    int isNew = resp.data["is_new"];
    UserInfoEntity userInfo =
        userInfoEntityFromJson(UserInfoEntity(), resp.data["user_info"]);
    StorageManager.setUid(userInfo.uid!);
    //更新im签名
    StorageManager.setTimUserSig(resp.data['tim_sig']);
    EasyLoading.showSuccess("登录成功");
    EasyLoading.dismiss();
    if (isNew == 1) {
      userModel.setUserInfo(userInfo);
      Navigator.of(context).pushNamed(AppRouter.PolicyPageRoute);
    } else {
      initData(context);
      Navigator.of(context).pushNamed(AppRouter.MainPageRoute, arguments: 0);
    }
  }

  Widget customButton(String svgPath, String desc, Color backgroundColor) =>
      Container(
        padding: EdgeInsets.all(10.r),
        margin: EdgeInsets.only(top: 7.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.r)),
          color: backgroundColor,
        ),
        width: 250.r,
        height: 45.r,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              color: Colors.white,
              width: 20.r,
              height: 20.r,
            ),
            SizedBox(
              width: 5.r,
            ),
            Text(
              desc,
              style: TextStyle(color: Colors.white, fontSize: 20.sp),
            ),
          ],
        ),
      );

  Widget appleButton() => Container(
        width: 250.r,
        child: SignInWithAppleButton(
          borderRadius: BorderRadius.all(Radius.circular(20.r)),
          height: 45.r,
          style: SignInWithAppleButtonStyle.whiteOutlined,
          text: 'Apple登录',
          onPressed: () async {
            final credential = await SignInWithApple.getAppleIDCredential(
              scopes: [
                AppleIDAuthorizationScopes.email,
                AppleIDAuthorizationScopes.fullName,
              ],
              webAuthenticationOptions: WebAuthenticationOptions(
                clientId: 'com.fanminet.fanmi.sign',
                redirectUri: Uri.parse(
                  'https://fanminet.com/callbacks/sign_in_with_apple',
                ),
              ),
            );
            EasyLoading.show(status: "登录中");
            LoginService.appleLogin(
              userIdentifier: credential.userIdentifier!,
              name: credential.familyName != null
                  ? "${credential.familyName} ${credential.givenName}"
                  : "苹果用户",
              mail: credential.email,
            ).then((resp) => next(resp)).onError((e, s) {
              print(e);
              EasyLoading.showError("苹果登录失败");
              EasyLoading.dismiss();
            });
          },
        ),
      );
}
