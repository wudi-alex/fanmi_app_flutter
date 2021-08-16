
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
