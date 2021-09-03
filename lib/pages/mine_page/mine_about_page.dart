import 'package:app_installer/app_installer.dart';
import 'package:fanmi/config/appstore_config.dart';
import 'package:fanmi/update/update.dart';
import 'package:fanmi/utils/platform_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineAboutPage extends StatefulWidget {
  @override
  _MineAboutPageState createState() => _MineAboutPageState();
}

class _MineAboutPageState extends State<MineAboutPage> {
  String version = '';

  @override
  void initState() {
    super.initState();
    PlatformUtils.getAppVersion().then((v) => setState(() {
          version = v;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BackButton(
        color: Colors.black,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/logo_trans_blue.png",
                width: 150.r,
                height: 150.r,
                color: Colors.lightBlueAccent,
              ),
              Text(
                "凡觅",
                style: TextStyle(
                    fontSize: 50.r,
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 100.r,
              ),
              Text(
                '版本号 $version',
                style: TextStyle(color: Colors.grey, fontSize: 17.sp),
              ),
              GestureDetector(
                onTap: () {
                  UpdateManager.checkUpdate(
                      context, AppStoreConfig.APK_UPDATE_JSON);
                },
                child: Text(
                  '检查更新',
                  style: TextStyle(color: Colors.blue, fontSize: 17.sp),
                ),
              ),
              GestureDetector(
                onTap: () {
                  AppInstaller.goStore("", AppStoreConfig.APPSTORE_ID, review: true);
                },
                child: Text(
                  '喜欢凡觅吗？去商店评分支持一下我们吧😊',
                  style: TextStyle(color: Colors.blue, fontSize: 17.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
