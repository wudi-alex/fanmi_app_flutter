import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/enums/gender_type_enum.dart';
import 'package:fanmi/net/http_client.dart';
import 'package:fanmi/net/status_code.dart';
import 'package:fanmi/net/user_service.dart';
import 'package:fanmi/pages/mine_page/mine_board_widget.dart';
import 'package:fanmi/utils/common_methods.dart';
import 'package:fanmi/view_models/image_picker_model.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:fanmi/widgets/appbars.dart';
import 'package:fanmi/widgets/city_picker/city_picker.dart';
import 'package:fanmi/widgets/common_image.dart';
import 'package:fanmi/widgets/provider_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'custom_listtile.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  late ImagePickerModel avatarModel;
  late UserModel userModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    avatarModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userModel = Provider.of<UserModel>(context);
    avatarModel = ImagePickerModel(
        maxAssetsCount: 1, imgUrls: [userModel.userInfo.avatarUrl??""]);
    return Scaffold(
      appBar: TitleAppBar(
        title: "我的",
      ),
      body: ListView(
        children: [
          GestureDetector(
            child: MineBoard(
                exposureNum: userModel.boardEntity.exposureNum ?? 0,
                exposureAddNum: userModel.boardEntity.exposureAddNum ?? 0,
                searchNum: userModel.boardEntity.searchNum ?? 0,
                searchAddNum: userModel.boardEntity.searchAddNum ?? 0,
                clickNum: userModel.boardEntity.clickNum ?? 0,
                clickAddNum: userModel.boardEntity.clickAddNum ?? 0,
                favorNum: userModel.boardEntity.favorNum ?? 0,
                favorAddNum: userModel.boardEntity.favorAddNum ?? 0),
            onTap: () {
              // todo:访客面板页
              // Navigator.of(context)
              //     .pushNamed(AppRouter.MineBoardDetailPageRoute);
            },
          ),
          block,
          CustomListTile(
            headerText: '通讯录',
            onTap: () {
              //todo:通讯录页
              Navigator.of(context)
                  .pushNamed(AppRouter.MineContactListPageRoute);
            },
            child: Container(),
          ),
          divider,
          CustomListTile(
            headerText: '收藏夹',
            onTap: () {
              //todo:收藏夹页
              Navigator.of(context).pushNamed(AppRouter.MineFavorCardPageRoute);
            },
            child: Container(),
          ),
          block,
          CustomListTile(
            headerText: '头像',
            onTap: () {},
            child: ProviderWidget(
              autoDispose: false,
              model: avatarModel,
              builder: (context, model, child) {
                model as ImagePickerModel;
                return CommonImage.photo(
                  imgUrl: model.imgUrls[0],
                  height: 70.r,
                  width: 70.r,
                  callback: () {
                    model.loadAssets(context).then((v) async {
                      if (model.assets.isEmpty) return;
                      try {
                        EasyLoading.show(status: "上传头像中");
                        var isUpSuccess = await model.uploadImgList();
                        if (isUpSuccess) {
                          var resp = await UserService.setUserInfo(
                              {"avatar_url": model.imgUrls[0]});
                          if (resp.statusCode == StatusCode.SUCCESS) {
                            model.notifyListeners();
                            userModel.userInfo.avatarUrl = model.imgUrls[0];
                            userModel.setUserInfo(userModel.userInfo);
                            EasyLoading.showSuccess("修改头像成功");
                          }
                        }
                      } catch (e, s) {
                        if (e is DioError) {
                          EasyLoading.showError(e.error.message);
                        } else {
                          EasyLoading.showError("修改头像失败");
                        }
                      } finally {
                        EasyLoading.dismiss();
                      }
                    });
                  },
                );
              },
            ),
          ),
          divider,
          CustomListTile(
            headerText: '二维码',
            onTap: () async {
              Navigator.of(context).pushNamed(AppRouter.MineContactPageRoute);
            },
            child: Container(),
          ),
          divider,
          CustomListTile(
            headerText: '名字',
            onTap: () async {
              var editName = await Navigator.of(context).pushNamed(
                  AppRouter.TextEditPageRoute,
                  arguments: [userModel.userInfo.name, "编辑名字", 20]) as String?;
              if (editName != null) {
                EasyLoading.show(status: "保存名字中");
                UserService.setUserInfo({"name": editName}).then((v) {
                  userModel.userInfo.name = editName;
                  userModel.setUserInfo(userModel.userInfo);
                }).onError((e, s) {
                  catchError(e, "修改名字失败");
                }).whenComplete(() {
                  EasyLoading.dismiss();
                });
              }
            },
            child: Text(
              userModel.userInfo.name??"凡觅用户",
              style: TextStyle(color: Colors.grey, fontSize: 17.sp),
            ),
          ),
          divider,
          CustomListTile(
            headerText: '性别',
            onTap: () async {
              final res = await showOkCancelAlertDialog(
                context: context,
                title: "修改性别",
                message:
                    "确认将性别修改为${userModel.userInfo.gender == GenderTypeEnum.Female.value ? "男" : "女"}吗？名片展示性别将随之修改",
                okLabel: "修改",
                cancelLabel: "取消",
              );
              if (res == OkCancelResult.ok) {
                EasyLoading.show(status: "修改性别中");
                int gender =
                    userModel.userInfo.gender == GenderTypeEnum.Female.value
                        ? 1
                        : 0;
                UserService.setUserInfo({"gender": gender}).then((v) {
                  userModel.userInfo.gender = gender;
                  userModel.setUserInfo(userModel.userInfo);
                }).onError((e, s) {
                  catchError(e, "修改性别失败");
                }).whenComplete(() {
                  EasyLoading.dismiss();
                });
              }
            },
            child: Text(
              userModel.userInfo.gender == GenderTypeEnum.Female.value
                  ? "女"
                  : "男",
              style: TextStyle(color: Colors.grey, fontSize: 17.sp),
            ),
          ),
          divider,
          CustomListTile(
            headerText: '城市',
            onTap: () async {
              final res = await CustomCityPicker.showPicker(context);
              EasyLoading.show(status: "修改城市中");
              UserService.setUserInfo(
                  {"city": res.city, "province": res.province}).then((v) {
                userModel.userInfo.city = res.city;
                userModel.userInfo.province = res.province;
                userModel.setUserInfo(userModel.userInfo);
                EasyLoading.showSuccess("修改城市成功");
              }).onError((e, s) {
                catchError(e, "修改城市失败");
              }).whenComplete(() {
                EasyLoading.dismiss();
              });
            },
            child: Text(
              userModel.userInfo.city??"未知城市",
              style: TextStyle(color: Colors.grey, fontSize: 17.sp),
            ),
          ),
          divider,
          CustomListTile(
            headerText: '出生日期',
            onTap: () async {
              DatePicker.showDatePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(1900, 1, 1),
                maxTime: DateTime.now(),
                onConfirm: (date) {
                  EasyLoading.show(status: "修改出生日期中");
                  UserService.setUserInfo({"birth_date": date.toString()})
                      .then((v) {
                    userModel.userInfo.birthDate = date.toString();
                    userModel.setUserInfo(userModel.userInfo);
                    EasyLoading.showSuccess("修改成功");
                  }).onError((e, s) {
                    catchError(e, "修改出生日期失败");
                  }).whenComplete(() {
                    EasyLoading.dismiss();
                  });
                },
                currentTime: DateTime.parse(userModel.userInfo.birthDate!),
                locale: LocaleType.zh,
              );
            },
            child: Text(
              userModel.userInfo.birthDate!.split(' ')[0],
              style: TextStyle(color: Colors.grey, fontSize: 17.sp),
            ),
          ),
          userModel.userInfo.loginPlatform == "email"
              ? divider()
              : SizedBox.shrink(),
          userModel.userInfo.loginPlatform == "email"
              ? CustomListTile(
                  headerText: '修改账号密码',
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(AppRouter.MineMailPasswordPageRoute);
                  },
                  child: Container(),
                )
              : SizedBox.shrink(),
          block,
          CustomListTile(
            headerText: '隐私政策',
            onTap: () {
              Navigator.of(context)
                  .pushNamed(AppRouter.MinePrivacyPolicyPageRoute);
            },
            child: Container(),
          ),
          divider,
          CustomListTile(
            headerText: '用户协议',
            onTap: () {
              Navigator.of(context)
                  .pushNamed(AppRouter.MineUserPolicyPageRoute);
            },
            child: Container(),
          ),
          divider,
          CustomListTile(
            headerText: '联系我们',
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.MineContactUsPageRoute);
            },
            child: Container(),
          ),
          divider,
          CustomListTile(
            headerText: '关于',
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.MineAboutPageRoute);
            },
            child: Container(),
          ),
          block,
          GestureDetector(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10.r),
              child: Center(
                child: Text(
                  "退出登录",
                  style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            onTap: () async {
              final res = await showOkCancelAlertDialog(
                context: context,
                title: "退出登录",
                message: "确认退出当前账号的登录吗？",
                okLabel: "退出",
                cancelLabel: "取消",
              );
              if (res == OkCancelResult.ok) {
                EasyLoading.show(status: "退出登录中");
                logout(context).then((v) {
                  EasyLoading.dismiss();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.LoginPageRoute,
                      (Route<dynamic> route) => false);
                });
              }
            },
          ),
          block,
          GestureDetector(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10.r),
              child: Center(
                child: Text(
                  "注销账号",
                  style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            onTap: () async {
              final res = await showOkCancelAlertDialog(
                context: context,
                title: "注销账号",
                message:
                    "确认注销账号吗？注销后所有账号信息都会被删除",
                okLabel: "注销",
                cancelLabel: "取消",
              );
            },
          ),
          block,
        ],
      ),
    );
  }

  get block => Container(
        height: 10.r,
      );

  get divider => Padding(
        padding: EdgeInsets.only(left: 10.r),
        child: Divider(
          height: 2,
        ),
      );
}
