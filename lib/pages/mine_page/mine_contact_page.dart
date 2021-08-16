import 'package:fanmi/net/status_code.dart';
import 'package:fanmi/net/user_service.dart';
import 'package:fanmi/pages/qr_page/qr_listtile.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:fanmi/widgets/appbars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MineContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var userModel = Provider.of<UserModel>(context);
    return Scaffold(
      appBar: SubtitleAppBar(
        title: '二维码',
      ),
      body: Container(
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.r, horizontal: 20.r),
              child: Text(
                "任选一种或者多种二维码上传就可以哦～",
                style: TextStyle(fontSize: 15.sp),
              ),
            ),
            QrListTile(
                qrType: "微信",
                qrUrl: userModel.userInfo.wxQrUrl,
                callBack: (String? url) async {
                  var resp =
                      await UserService.setUserInfo({"wx_qr_url": url ?? ""});
                  if (resp.statusCode == StatusCode.SUCCESS) {
                    userModel.userInfo.wxQrUrl = url;
                    userModel.setUserInfo(userModel.userInfo);
                  }
                }),
            divider(),
            QrListTile(
                qrType: "QQ",
                qrUrl: userModel.userInfo.qqQrUrl,
                callBack: (String? url) async {
                  var resp =
                      await UserService.setUserInfo({"qq_qr_url": url ?? ""});
                  if (resp.statusCode == StatusCode.SUCCESS) {
                    userModel.userInfo.qqQrUrl = url;
                    userModel.setUserInfo(userModel.userInfo);
                  }
                }),
          ],
        ),
      ),
    );
  }

  Widget divider() => Padding(
        padding: EdgeInsets.only(left: 10.r),
        child: Divider(
          height: 2,
        ),
      );
}
