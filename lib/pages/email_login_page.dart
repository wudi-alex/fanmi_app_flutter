import 'package:dio/dio.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/config/asset_constants.dart';
import 'package:fanmi/entity/user_info_entity.dart';
import 'package:fanmi/generated/json/user_info_entity_helper.dart';
import 'package:fanmi/net/login_service.dart';
import 'package:fanmi/net/status_code.dart';
import 'package:fanmi/utils/common_methods.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class EmailLoginPage extends StatefulWidget {
  @override
  _EmailLoginPageState createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  final passwordRegExp =
      RegExp(r"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z\\W]{6,18}$");
  String email = "";
  String password = "";
  bool loginSuccess = false;
  bool registerSuccess = false;

  @override
  Widget build(BuildContext context) {
    var userModel = Provider.of<UserModel>(context);
    return Scaffold(
      floatingActionButton: BackButton(
        color: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: FlutterLogin(
        title: '凡觅',
        logo: AssetConstants.fanmi_logo_white,
        onLogin: (_) async {
          try {
            var resp = await LoginService.emailLogin(
                email: email, emailPassword: password);
            UserInfoEntity userInfo = userInfoEntityFromJson(
                UserInfoEntity(), resp.data["user_info"]);
            StorageManager.setUid(userInfo.uid!);
            //更新im签名
            StorageManager.setTimUserSig(resp.data['tim_sig']);
            initData(context);
            loginSuccess = true;
            return null;
          } catch (e, s) {
            e as DioError;
            if (e.error.code == StatusCode.EMAIL_NOT_REGISTERED) {
              return "该邮箱尚未注册";
            }
            return "用户名或密码错误";
          }
        },
        onSignup: (_) async {
          try {
            var resp = await LoginService.emailRegister(
              email: email,
              emailPassword: password,
            );
            UserInfoEntity userInfo = userInfoEntityFromJson(
                UserInfoEntity(), resp.data["user_info"]);
            StorageManager.setUid(userInfo.uid!);
            //更新im签名
            StorageManager.setTimUserSig(resp.data['tim_sig']);
            userModel.setUserInfo(userInfo);
            registerSuccess = true;
            // Navigator.of(context)
            //     .pushNamed(AppRouter.MainPageRoute, arguments: 0);
            return null;
          } catch (e, s) {
            e as DioError;
            if (e.error.code == StatusCode.EMAIL_ALREADY_REGISTERED) {
              return "该邮箱已被注册，请直接登录";
            }
            return "注册失败，请检查网络或稍后重试";
          }
        },
        onSubmitAnimationCompleted: () {
          if (registerSuccess) {
            Navigator.of(context).pushNamed(AppRouter.PolicyPageRoute);
            return;
          }
          Navigator.of(context)
              .pushNamed(AppRouter.MainPageRoute, arguments: 0);
        },
        userValidator: (value) {
          if (value!.isEmpty || !emailRegExp.hasMatch(value)) {
            return '请输入有效的邮箱地址';
          }
          email = value;
          return null;
        },
        passwordValidator: (value) {
          if (value!.isEmpty || !passwordRegExp.hasMatch(value)) {
            return '密码必须包含字母和数字，且长度为6-18位';
          }
          password = value;
          return null;
        },
        onRecoverPassword: (_) async {
          try {
            var resp = await LoginService.emailPasswordRecover(email: email);
          } catch (e, s) {
            e as DioError;
            if (e.error.code == StatusCode.EMAIL_NOT_REGISTERED) {
              return "该邮箱尚未注册";
            }
            return "重置失败，请检查网络或稍后重试";
          }
        },
        messages: LoginMessages(
          userHint: '邮箱',
          passwordHint: '请输入密码',
          confirmPasswordHint: '请确认密码',
          loginButton: '登 录',
          signupButton: '注 册',
          forgotPasswordButton: '忘记密码?',
          recoverPasswordButton: '确认',
          goBackButton: '返回',
          confirmPasswordError: '两次输入的密码不匹配',
          recoverPasswordIntro: '重置账号密码',
          recoverPasswordDescription: '系统会重置您的密码并发送至您的邮箱中',
          recoverPasswordSuccess: '重置密码的邮件已发送至您的邮箱中',
        ),
        theme: LoginTheme(
          titleStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 30.sp),
        ),
      ),
    );
  }
}
