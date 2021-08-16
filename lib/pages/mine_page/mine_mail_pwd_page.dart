import 'package:fanmi/net/user_service.dart';
import 'package:fanmi/utils/common_methods.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

class MineMailPasswordPage extends StatefulWidget {
  @override
  _MineMailPasswordPageState createState() => _MineMailPasswordPageState();
}

class _MineMailPasswordPageState extends State<MineMailPasswordPage> {
  FocusNode _passwordFocusNode = FocusNode();
  TextEditingController _passwordEditingController = TextEditingController();
  final passwordRegExp =
      RegExp(r"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z\\W]{6,18}$");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _passwordFocusNode.dispose();
    _passwordEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userModel = Provider.of<UserModel>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: Text(
          "修改账号密码",
          style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.clear),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) {
                setState(() {});
              }
              if (passwordRegExp.hasMatch(_passwordEditingController.text)) {
                var pwd = _passwordEditingController.text;
                EasyLoading.show(status: "修改邮箱密码中");
                UserService.setUserInfo({"email_password": pwd}).then((v) {
                  userModel.userInfo.emailPassword = pwd;
                  userModel.setUserInfo(userModel.userInfo);
                  EasyLoading.showSuccess("修改成功");
                }).onError((e, s) {
                  catchError(e, "修改邮箱密码失败");
                }).whenComplete(() {
                  EasyLoading.dismiss();
                });
              } else {
                SmartDialog.showToast('密码必须包含字母和数字，且长度为6-18位');
              }
            },
            child: Text(
              "编辑完成",
              style: TextStyle(fontSize: 17.sp, color: Colors.blue),
            ),
          )
        ],
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.r, horizontal: 20.r),
              child: Container(
                child: TextField(
                  maxLength: 18,
                  controller: _passwordEditingController,
                  focusNode: _passwordFocusNode,
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: '邮箱登录用户在此修改账号密码',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.sp,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                    counterText: "",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
