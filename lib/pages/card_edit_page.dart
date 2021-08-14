import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/config/color_constants.dart';
import 'package:fanmi/config/text_constants.dart';
import 'package:fanmi/entity/card_info_entity.dart';
import 'package:fanmi/enums/card_status_enum.dart';
import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/enums/qr_type_enum.dart';
import 'package:fanmi/generated/json/card_info_entity_helper.dart';
import 'package:fanmi/net/card_service.dart';
import 'package:fanmi/net/status_code.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/view_models/card_list_model.dart';
import 'package:fanmi/view_models/image_picker_model.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:fanmi/widgets/image_picker.dart';
import 'package:fanmi/widgets/provider_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bounce/flutter_bounce.dart';

class CardEditPage extends StatefulWidget {
  final CardTypeEnum cardType;

  const CardEditPage({Key? key, required this.cardType}) : super(key: key);

  @override
  _CardEditPageState createState() => _CardEditPageState();
}

class _CardEditPageState extends State<CardEditPage> {
  late CardInfoEntity card;
  late CardListModel cardListModel;
  late UserModel userModel;

  late ImagePickerModel avatarModel;
  late ImagePickerModel coverModel;
  late ImagePickerModel albumModel;

  get cardType => widget.cardType;

  get isCreateMode => card.id == null;

  get actionDesc => isCreateMode ? "创建" : "编辑";

  @override
  void initState() {
    super.initState();
    cardListModel = Provider.of<CardListModel>(context, listen: false);
    userModel = Provider.of<UserModel>(context, listen: false);
    if (cardListModel.cardMap.containsKey(cardType.value)) {
      var cardOrigin = cardListModel.cardMap[cardType.value]!;
      card = cardInfoEntityFromJson(
          CardInfoEntity(), cardInfoEntityToJson(cardOrigin));
    } else {
      card = CardInfoEntity();
      card.avatarUrl = userModel.userInfo.avatarUrl!;
      card.name = userModel.userInfo.name!;
      card.sign = TextConstants.DEFAULT_CARD_SIGN;
      card.coverUrl = cardType.coverUrl;
      if (cardType != CardTypeEnum.GROUP) {
        card.wxQrUrl = userModel.userInfo.wxQrUrl;
        card.qqQrUrl = userModel.userInfo.qqQrUrl;
      }
    }
    avatarModel =
        ImagePickerModel(maxAssetsCount: 1, imgUrls: [card.avatarUrl!]);
    coverModel = ImagePickerModel(maxAssetsCount: 1, imgUrls: [card.coverUrl!]);
    albumModel = ImagePickerModel(
      maxAssetsCount: 9,
      imgUrls: card.album != null ? card.album!.split(",") : [],
    );
  }

  @override
  void dispose() {
    super.dispose();
    avatarModel.dispose();
    coverModel.dispose();
    albumModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            header(),
            subtitleText("自我描述:"),
            descWidget(),
            subtitleText("相册:"),
            Padding(
              padding: EdgeInsets.only(left: 8.r, right: 8.r, top: 10.r),
              child: ProviderWidget(
                  autoDispose: false,
                  model: ImagePickerModel(
                    maxAssetsCount: 9,
                    imgUrls: card.album != null ? card.album!.split(",") : [],
                  ),
                  builder: (context, ImagePickerModel model, child) {
                    return AlbumPicker();
                  }),
            ),
            subtitleText("二维码:"),
            Row(
              children: [
                qrWidget(
                    card.wxQrUrl,
                    cardType != CardTypeEnum.GROUP
                        ? QrTypeEnum.WEIXIN
                        : QrTypeEnum.WEIXIN_GROUP),
                qrWidget(
                    card.qqQrUrl,
                    cardType != CardTypeEnum.GROUP
                        ? QrTypeEnum.QQ
                        : QrTypeEnum.QQ_GROUP),
              ],
            ),
            SizedBox(
              height: 8.r,
            ),
            subtitleText("名片设置:"),
            SizedBox(
              height: 8.r,
            ),
            cardSwitch("展示名片曝光数点击数等数据", card.isExposureData == 1, (value) {
              setState(() {
                card.isExposureData = value ? 1 : 0;
              });
            }),
            cardSwitch("禁止名片对外展示",
                card.cardStatus == CardStatusEnum.CARD_STATUS_NO_SHOW, (value) {
              setState(() {
                card.cardStatus = value
                    ? CardStatusEnum.CARD_STATUS_NO_SHOW
                    : CardStatusEnum.CARD_STATUS_NORMAL;
              });
            }),
            cardSwitch("可被直接查看二维码", card.isExposureContact == 1, (value) {
              setState(() {
                card.isExposureContact = value ? 1 : 0;
              });
            }),
            cardSwitch("需要对方发送申请消息时附加名片", card.isNeedCard == 1, (value) {
              setState(() {
                card.isNeedCard = value ? 1 : 0;
              });
            }),
            SizedBox(
              height: 10.r,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      title: Text(
        "$actionDesc${widget.cardType.desc}名片",
        style: TextStyle(
            color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w500),
      ),
      leading: IconButton(
        color: Colors.black,
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () async {
          if (isCreateMode) {
            if (card.selfDesc != null || card.album != null) {
              final res = await showOkCancelAlertDialog(
                context: context,
                title: "创建名片",
                message: "是否创建该名片？取消后系统将临时保存草稿",
                okLabel: "创建",
                cancelLabel: "取消",
              );
              if (res == OkCancelResult.ok) {
                await setCardInfo();
              } else {
                cardListModel.cardMap[cardType.value] = card;
                Navigator.of(context).pop();
              }
            } else {
              Navigator.of(context).pop();
            }
          } else if (!card.equal(cardListModel.cardMap[cardType.value]!)) {
            final res = await showOkCancelAlertDialog(
              context: context,
              title: "保存编辑",
              message: "是否取消这次编辑？取消后系统不会保存修改的内容",
              okLabel: "保存",
              cancelLabel: "取消",
            );
            if (res == OkCancelResult.ok) {
              await setCardInfo();
            } else {
              Navigator.of(context).pop();
            }
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await setCardInfo();
          },
          child: Text(
            "$actionDesc完成",
            style: TextStyle(fontSize: 17.sp, color: Colors.blue),
          ),
        )
      ],
    );
  }

  Widget header() {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            //背景
            ProviderWidget(
              model: coverModel,
              autoDispose: false,
              builder: (context, model, child) => ImagePicker(
                icon: Icons.camera_alt_outlined,
                height: 270.r,
                width: MediaQuery.of(context).size.width,
                rectRadius: 0.r,
                iconSize: 60.r,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 27.r, right: 17.r),
              child: bounceButton(
                  Text(
                    card.sign!,
                    style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ), () async {
                var res = await Navigator.of(context).pushNamed(
                    AppRouter.TextEditPageRoute,
                    arguments: [card.sign!, "名片签名", 20]) as String?;
                if (res != null) {
                  setState(() {
                    card.sign = res;
                  });
                }
              }),
            ),
          ],
        ),
        Positioned(
          top: 220.r,
          right: 17.r,
          child: Container(
            child: Row(
              children: [
                bounceButton(
                    Text(
                      card.name!,
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ), () async {
                  var res = await Navigator.of(context).pushNamed(
                      AppRouter.TextEditPageRoute,
                      arguments: [card.name!, "名片昵称", 20]) as String?;
                  if (res != null) {
                    setState(() {
                      card.name = res;
                    });
                  }
                }),
                SizedBox(
                  width: 17.r,
                ),
                //头像
                ProviderWidget(
                  model: avatarModel,
                  autoDispose: false,
                  builder: (context, model, child) => ImagePicker(
                    height: 70.r,
                    width: 70.r,
                    rectRadius: 5.r,
                    iconSize: 30.r,
                    icon: Icons.camera_alt_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget bounceButton(
    Text text,
    VoidCallback callback,
  ) =>
      Bounce(
        duration: Duration(milliseconds: 100),
        onPressed: callback,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10.r),
            ),
            color: Colors.transparent,
            border: Border.all(width: 2.r, color: Colors.blue),
          ),
          child: text,
        ),
      );

  //副标题
  Widget subtitleText(String subtitle) => Padding(
        padding: EdgeInsets.fromLTRB(10.r, 10.r, 0.r, 0.r),
        child: Text(
          subtitle,
          style: TextStyle(
              color: Colors.black,
              fontSize: 22.sp,
              fontWeight: FontWeight.w600),
        ),
      );

  //卡片开关
  Widget cardSwitch(String title, bool value, void Function(bool)? onChanged) =>
      Container(
        padding: EdgeInsets.symmetric(vertical: 0.r, horizontal: 10.r),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            Spacer(),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.blue,
            )
          ],
        ),
      );

  //二维码组件
  Widget qrWidget(String? qrUrl, String qrType) {
    var width = 150.r;
    var height = 200.r;
    var iconSize = 50.r;
    late String svgPath;
    if (qrType == QrTypeEnum.WEIXIN_GROUP || qrType == QrTypeEnum.WEIXIN) {
      svgPath = "assets/svg/weixin_border.svg";
    } else {
      svgPath = "assets/svg/qq_border.svg";
    }
    return Container(
      padding: EdgeInsets.all(8.0.r),
      child: GestureDetector(
        onTap: () async {
          final res = await Navigator.of(context).pushNamed(
              AppRouter.QrUploadPageRoute,
              arguments: [qrType, qrUrl]) as String?;
          if (res != null) {
            if (qrType == QrTypeEnum.WEIXIN_GROUP ||
                qrType == QrTypeEnum.WEIXIN) {
              setState(() {
                card.wxQrUrl = res;
              });
            } else {
              setState(() {
                card.qqQrUrl = res;
              });
            }
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0.r),
          child: Container(
            width: width,
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                    child: qrUrl != null
                        ? Image.network(
                            qrUrl,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: ColorConstants.mi_color,
                          )),
                Positioned(
                  left: (width - iconSize) / 2,
                  top: (height - iconSize) / 2,
                  child: SvgPicture.asset(
                    svgPath,
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //描述组件
  Widget descWidget() {
    var isFilled = card.selfDesc != null;
    return Bounce(
      duration: Duration(milliseconds: 100),
      onPressed: () {
        final res = Navigator.of(context).pushNamed(
            AppRouter.LongTextEditPageRoute,
            arguments: [card.selfDesc, "自我描述", 1000]) as String?;
        if (res != null) {
          setState(() {
            card.selfDesc = res;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 10.r),
        margin: EdgeInsets.symmetric(horizontal: 10.r, vertical: 10.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10.r),
          ),
          color: Colors.transparent,
          border: Border.all(width: 2.r, color: Colors.blue),
        ),
        constraints: BoxConstraints(minHeight: 150.r),
        width: MediaQuery.of(context).size.width,
        child: Text(
          isFilled ? card.selfDesc! : cardType.hint,
          style: TextStyle(
              color: isFilled ? Colors.black : Colors.grey, fontSize: 16.sp),
        ),
      ),
    );
  }

  //修改后保存名片
  setCardInfo() async {
    EasyLoading.show(status: "保存中");
    try {
      var isImgSuccess = true;
      var imgRes = await Future.wait([
        avatarModel.uploadImgList(),
        coverModel.uploadImgList(),
        albumModel.uploadImgList()
      ]);
      for (bool e in imgRes) {
        isImgSuccess = isImgSuccess && e;
      }
      if (isImgSuccess) {
        card.avatarUrl = avatarModel.imgUrls[0];
        card.coverUrl = coverModel.imgUrls[0];
        card.album = albumModel.imgUrls.join(";");
        card.updateTime = DateTime.now().toString();
        var resp = await CardService.setCardInfo(
            cardId: card.id,
            cardType: cardType.value,
            cardDict: cardInfoEntityToJson(card));
        if (resp.statusCode == StatusCode.SUCCESS) {
          EasyLoading.showSuccess("$actionDesc成功");
          cardListModel.cardMap[cardType.value] = card;
          StorageManager.setCardListInfo(cardListModel.cardList);
          Navigator.of(context).pop();
        }
      }
    } catch (e, s) {
      e as DioError;
      EasyLoading.showError(e.error.message);
    } finally {
      EasyLoading.dismiss();
    }
  }
}
