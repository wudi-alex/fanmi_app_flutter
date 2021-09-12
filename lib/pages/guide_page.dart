import 'dart:ui';

import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/config/asset_constants.dart';
import 'package:fanmi/config/color_constants.dart';
import 'package:fanmi/enums/gender_type_enum.dart';
import 'package:fanmi/enums/qr_type_enum.dart';
import 'package:fanmi/generated/json/user_info_entity_helper.dart';
import 'package:fanmi/net/user_service.dart';
import 'package:fanmi/utils/common_methods.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:fanmi/widgets/city_picker/city_picker.dart';
import 'package:fanmi/widgets/common_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/scrollbar_behavior_enum.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:provider/provider.dart';

class GuidePageModal extends StatelessWidget {
  final VoidCallback callback;
  final Positioned child;
  final bool canBack;

  const GuidePageModal(
      {Key? key,
      required this.callback,
      required this.child,
      this.canBack = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Stack(
          children: [
            child,
            Positioned(
              child: FloatingActionButton(
                heroTag: "forward",
                backgroundColor: ColorConstants.mi_color,
                onPressed: callback,
                child: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.black,
                  size: 20.r,
                ),
                elevation: 0.5,
                highlightElevation: 0.0,
              ),
              bottom: 200.r,
              right: 20.r,
            ),
            canBack
                ? Positioned(
                    child: FloatingActionButton(
                      heroTag: "back",
                      backgroundColor: ColorConstants.mi_color,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 20.r,
                      ),
                      elevation: 0.5,
                      highlightElevation: 0.0,
                    ),
                    bottom: 200.r,
                    left: 20.r,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class GenderGuidePage extends StatefulWidget {
  @override
  _GenderGuidePageState createState() => _GenderGuidePageState();
}

class _GenderGuidePageState extends State<GenderGuidePage>
    with AutomaticKeepAliveClientMixin {
  GenderTypeEnum selectedGender = GenderTypeEnum.Male;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var userModel = Provider.of<UserModel>(context);
    return GuidePageModal(
        canBack: true,
        callback: () {
          userModel.userInfo.gender = selectedGender.value;
          Navigator.of(context).pushNamed(AppRouter.BirthDateGuidePageRoute);
        },
        child: Positioned(
          top: 150.r,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Text(
                  "填写你的性别",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 25.sp),
                ),
                SizedBox(
                  height: 10.r,
                ),
                Text(
                  "建议选择真实性别:)",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      color: Colors.grey),
                ),
                SizedBox(
                  height: 10.r,
                ),
                Wrap(
                  children: [
                    genderButton(GenderTypeEnum.Male),
                    genderButton(GenderTypeEnum.Female),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Widget genderButton(GenderTypeEnum gender) {
    bool isSelected = gender == selectedGender;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.r, horizontal: 10.r),
        decoration: BoxDecoration(
          color: ColorConstants.mi_color,
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
        ),
        child: SvgPicture.asset(
          gender.svgPath,
          width: 110.r,
          color: isSelected ? gender.color : Colors.grey,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BirthDateGuidePage extends StatefulWidget {
  @override
  _BirthDateGuidePageState createState() => _BirthDateGuidePageState();
}

class _BirthDateGuidePageState extends State<BirthDateGuidePage>
    with AutomaticKeepAliveClientMixin {
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var userModel = Provider.of<UserModel>(context);
    return GuidePageModal(
      callback: () {
        if (userModel.userInfo.birthDate == null) {
          SmartDialog.showToast("你还没有选择出生日期哦～");
          return;
        }
        Navigator.of(context).pushNamed(AppRouter.CityGuidePageRoute);
      },
      child: Positioned(
        top: 150.r,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Text(
                "填写你的出生日期",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.sp),
              ),
              SizedBox(
                height: 10.r,
              ),
              Text(
                "建议选择你的真实年龄哦^-^",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    color: Colors.grey),
              ),
              SizedBox(
                height: 10.r,
              ),
              GestureDetector(
                onTap: () {
                  DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    minTime: DateTime(1900, 1, 1),
                    maxTime: DateTime.now(),
                    onConfirm: (date) {
                      userModel.userInfo.birthDate = date.toString();
                      userModel.notifyListeners();
                    },
                    currentTime: userModel.userInfo.birthDate != null
                        ? DateTime.parse(userModel.userInfo.birthDate!)
                        : DateTime.now(),
                    locale: LocaleType.zh,
                  );
                },
                child: Text(
                  userModel.userInfo.birthDate != null
                      ? userModel.userInfo.birthDate!.split(' ')[0]
                      : "选择出生日期",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                      color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CityGuidePage extends StatefulWidget {
  @override
  _CityGuidePageState createState() => _CityGuidePageState();
}

class _CityGuidePageState extends State<CityGuidePage> {
  @override
  Widget build(BuildContext context) {
    var userModel = Provider.of<UserModel>(context);
    return GuidePageModal(
      callback: () {
        if (userModel.userInfo.city == null) {
          SmartDialog.showToast("你还没有选择所在城市哦～");
          return;
        }
        Navigator.of(context).pushNamed(AppRouter.QrGuidePageRoute);
      },
      child: Positioned(
        top: 150.r,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Text(
                "选择你所在的城市",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.sp),
              ),
              SizedBox(
                height: 10.r,
              ),
              Text(
                "获取同城名片更方便哦^-^",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    color: Colors.grey),
              ),
              SizedBox(
                height: 10.r,
              ),
              TextButton(
                onPressed: () async {
                  final res = await CustomCityPicker.showPicker(context);
                  if (res.city != null) {
                    userModel.userInfo.city = res.city!;
                    userModel.notifyListeners();
                  }
                },
                child: Text(
                  userModel.userInfo.city ?? "选择城市",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                      color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QrGuidePage extends StatefulWidget {
  @override
  _QrGuidePageState createState() => _QrGuidePageState();
}

class _QrGuidePageState extends State<QrGuidePage> {
  @override
  Widget build(BuildContext context) {
    var userModel = Provider.of<UserModel>(context);
    return GuidePageModal(
      callback: () {
        UserService.regUserInfo(userInfoEntityToJson(userModel.userInfo))
            .then((v) {
          initData(context);
          Navigator.of(context)
              .pushNamed(AppRouter.MainPageRoute, arguments: 0);
        }).onError((error, stackTrace) {
          SmartDialog.showToast("注册失败");
          StorageManager.sp.remove(StorageManager.uidKey);
          StorageManager.sp.remove(StorageManager.userKey);
          Navigator.of(context).pushNamed(AppRouter.LoginPageRoute);
        });
      },
      child: Positioned(
        top: 150.r,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Text(
                "选择需要上传的二维码",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.sp,
                ),
              ),
              SizedBox(
                height: 10.r,
              ),
              Text(
                "你需要先上传二维码才能和对方交换哦^-^",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    color: Colors.grey),
              ),
              Text(
                "（可跳过，想认识ta时要记得上传哦～）",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    color: Colors.grey),
              ),
              SizedBox(
                height: 10.r,
              ),
              TextButton(
                  onPressed: () async {
                    var res = await Navigator.of(context).pushNamed(
                        AppRouter.QrUploadPageRoute,
                        arguments: [QrTypeEnum.WEIXIN, null]) as String?;
                    if (res != null) {
                      userModel.userInfo.wxQrUrl = res;
                      userModel.notifyListeners();
                    }
                  },
                  child: Text(
                    userModel.userInfo.wxQrUrl != null ? "微信（已上传）" : "微信",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                        color: Colors.blue),
                  )),
              TextButton(
                  onPressed: () async {
                    var res = await Navigator.of(context).pushNamed(
                        AppRouter.QrUploadPageRoute,
                        arguments: [QrTypeEnum.QQ, null]) as String?;
                    if (res != null) {
                      userModel.userInfo.qqQrUrl = res;
                      userModel.notifyListeners();
                    }
                  },
                  child: Text(
                    userModel.userInfo.qqQrUrl != null ? "QQ（已上传）" : "QQ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                        color: Colors.blue),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeGuidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var userModel = Provider.of<UserModel>(context);
    return GuidePageModal(
      canBack: false,
      callback: () {
        Navigator.of(context).pushNamed(AppRouter.GenderGuidePageRoute);
      },
      child: Positioned(
        top: 150.r,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 20.r),
          child: Column(
            children: [
              Text(
                "欢迎来到凡觅",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.sp),
              ),
              SizedBox(
                height: 10.r,
              ),
              Text(
                "应用内可以修改你的头像和昵称^-^",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    color: Colors.grey),
              ),
              SizedBox(
                height: 10.r,
              ),
              CommonImage(
                imgUrl: userModel.userInfo.avatarUrl,
                height: 120.r,
                width: 120.r,
                radius: 20.r,
                callback: () {},
              ),
              SizedBox(
                height: 10.r,
              ),
              Text(
                userModel.userInfo.name ?? "凡觅用户",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GuidePage extends StatefulWidget {
  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroSlider(
        slides: [
          Slide(
            pathImage: AssetConstants.guide_background1,
            widthImage: 280.r,
            heightImage: 450.r,
            foregroundImageFit: BoxFit.contain,
            backgroundColor: Colors.white,
          ),
          Slide(
            pathImage: AssetConstants.guide_background2,
            widthImage: 280.r,
            heightImage: 450.r,
            foregroundImageFit: BoxFit.contain,
            backgroundColor: Colors.white,
          ),
          Slide(
            pathImage: AssetConstants.guide_background3,
            widthImage: 280.r,
            heightImage: 450.r,
            foregroundImageFit: BoxFit.contain,
            backgroundColor: Colors.white,
          ),
        ],
        renderNextBtn: Container(),
        renderSkipBtn: Container(),
        renderDoneBtn: Text(
          '完成',
          style: TextStyle(color: Colors.lightBlueAccent, fontSize: 17.sp),
        ),
        colorActiveDot: Colors.lightBlueAccent,
        colorDot: Colors.grey,
        onDonePress: () {
          Navigator.of(context)
              .pushNamed(AppRouter.MainPageRoute, arguments: 0);
        },
      ),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 667),
      builder: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.generateRoute,
        home: Builder(
          builder: (context) => GenderGuidePage(),
        ),
      ),
    );
  }
}
