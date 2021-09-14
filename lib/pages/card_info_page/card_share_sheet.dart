import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanmi/config/appstore_config.dart';
import 'package:fanmi/config/asset_constants.dart';
import 'package:fanmi/entity/card_info_entity.dart';
import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/enums/gender_type_enum.dart';
import 'package:fanmi/utils/time_utils.dart';
import 'package:fanmi/widgets/appbars.dart';
import 'package:fanmi/widgets/common_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluwx/fluwx.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tencent_kit/tencent_kit.dart';

class CardShareSheet extends StatefulWidget {
  final CardInfoEntity card;

  const CardShareSheet({Key? key, required this.card}) : super(key: key);

  @override
  _CardShareSheetState createState() => _CardShareSheetState();
}

class _CardShareSheetState extends State<CardShareSheet> {
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PopUpAppBar(
        title: "分享名片",
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.r),
        child: SingleChildScrollView(
          child: Screenshot(
            controller: screenshotController,
            child: CardShareContent(
              card: widget.card,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Material(
        elevation: 0.5,
        color: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 10.r),
          height: 90.r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 10.r,
                ),
                child: Text(
                  "分享至",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
              ),
              Divider(
                thickness: 0.7,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //微信分享
                  shareButton((file) {
                    shareToWeChat(WeChatShareImageModel(WeChatImage.file(file),
                        scene: WeChatScene.SESSION));
                  }, AssetConstants.weixin_logo),
                  //朋友圈分享
                  shareButton((file) {
                    shareToWeChat(WeChatShareImageModel(WeChatImage.file(file),
                        scene: WeChatScene.TIMELINE));
                  }, AssetConstants.weixin_circle_logo),
                  //QQ分享
                  shareButton((file) {
                    Tencent.instance.shareImage(
                      scene: TencentScene.SCENE_QQ,
                      imageUri: Uri.file(file.path),
                    );
                  }, AssetConstants.qq_logo),
                  //本地下载
                  shareButton((file) async {
                    EasyLoading.show(status: "保存至本地中");
                    final result = await ImageGallerySaver.saveFile(file.path);
                    if (result['isSuccess'] == true) {
                      EasyLoading.showSuccess("保存成功");
                    } else {
                      EasyLoading.showError("保存失败");
                    }
                  }, AssetConstants.local_download_logo),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget shareButton(Function(File file) callback, String imgPath) =>
      GestureDetector(
        child: Row(
          children: [
            SvgPicture.asset(
              imgPath,
              height: 30.r,
              width: 30.r,
            ),
          ],
        ),
        onTap: () {
          try {
            screenshotController.capture().then((image) async {
              //Capture Done
              Directory tempDir = await getTemporaryDirectory();
              String storagePath = tempDir.path;
              File file = new File(
                  '$storagePath/${DateTime.now().microsecondsSinceEpoch}.png');
              if (!file.existsSync()) {
                file.createSync();
              }
              file.writeAsBytesSync(image!);
              callback.call(file);
            });
          } catch (e, s) {
            print(e);
          }
        },
      );
}

class CardShareContent extends StatefulWidget {
  final CardInfoEntity card;

  const CardShareContent({Key? key, required this.card}) : super(key: key);

  @override
  _CardShareContentState createState() => _CardShareContentState();
}

class _CardShareContentState extends State<CardShareContent> {
  get card => widget.card;

  get album => (card.album != null && card.album != "")
      ? ((card.album!.split(";").length > 9)
          ? card.album!.split(";").sublist(0, 9)
          : card.album!.split(";"))
      : null;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CardTypeEnum.getCardType(card.type).color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10.r,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(15.r, 5.r, 0.r, 5.r),
            child: Text(
              "这是ta在凡觅创建的",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.r),
              child: Text(
                "${CardTypeEnum.getCardType(card.type).desc}名片",
                style: TextStyle(
                    fontSize: 25.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          cardWrapper(nameCardContent()),
          cardWrapper(descText()),
          album != null ? cardWrapper(albumWidget()) : SizedBox.shrink(),
          cardWrapper(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "想要认识ta？",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22.sp),
                    ),
                    Text(
                      "来凡觅!直接加ta微信/QQ",
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15.sp),
                    ),
                  ],
                ),
                qrWidget(),
              ],
            ),
          ),
          SizedBox(
            height: 10.r,
          ),
        ],
      ),
    );
  }

  Widget nameCardContent() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CommonImage.avatar(
              height: 60.r,
              radius: 30.r,
              imgUrl: card.avatarUrl,
              callback: () {},
            ),
            SizedBox(
              width: 10.r,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      card.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.sp),
                    ),
                    SizedBox(
                      width: 1.r,
                    ),
                    SvgPicture.asset(
                      GenderTypeEnum.getGender(card.gender).svgPath,
                      color: GenderTypeEnum.getGender(card.gender).color,
                      width: 14.r,
                      height: 14.r,
                    ),
                    Text(
                      getAge(card.birthDate).toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 16.sp),
                    ),
                    SizedBox(
                      width: 5.r,
                    ),
                    Text(
                      card.city,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                Text(
                  card.sign,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17.r),
                ),
              ],
            ),
          ],
        ),
      );

  Widget descText() => Text(
        card.selfDesc,
        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400),
      );

  Widget albumWidget() => Column(
        children: List.generate(
          album.length,
          (index) => Padding(
            padding: EdgeInsets.symmetric(vertical: 1.r),
            child: CachedNetworkImage(
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitWidth,
              imageUrl: album[index],
            ),
          ),
        ),
      );

  Widget qrWidget() => Container(
        color: Colors.white,
        child: PrettyQr(
          image: AssetImage(AssetConstants.fanmi_logo),
          typeNumber: 3,
          size: 100.r,
          data: AppStoreConfig.FANMI_NET,
          errorCorrectLevel: QrErrorCorrectLevel.H,
          roundEdges: true,
        ),
      );

  Widget cardWrapper(Widget child) => Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.r)),
            color: Colors.white),
        margin: EdgeInsets.symmetric(horizontal: 15.r, vertical: 5.r),
        padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 10.r),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: child,
        ),
      );
}
