import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/config/hippo_icon.dart';
import 'package:fanmi/enums/action_type_enum.dart';
import 'package:fanmi/enums/qr_type_enum.dart';
import 'package:fanmi/enums/relation_type_enum.dart';
import 'package:fanmi/enums/user_status_enum.dart';
import 'package:fanmi/net/action_service.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:fanmi/widgets/album.dart';
import 'package:fanmi/view_models/card_info_view_model.dart';
import 'package:fanmi/widgets/common_image.dart';
import 'package:fanmi/widgets/provider_widget.dart';
import 'package:fanmi/widgets/view_state_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

import 'custom_card_bar.dart';

class CardInfoPage extends StatelessWidget {
  final int cardId;

  const CardInfoPage({Key? key, required this.cardId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userModel = Provider.of<UserModel>(context);
    return ProviderWidget(
      model: CardInfoViewModel(cardId),
      onModelReady: (model) => (model! as CardInfoViewModel).initData(),
      builder: (context, model, child) {
        model as CardInfoViewModel;
        if (model.isBusy) {
          return customScaffold(ViewStateBusyWidget());
        } else if (model.isError) {
          return customScaffold(ViewStateErrorWidget(
              error: model.viewStateError!, onPressed: model.initData));
        } else if (model.isEmpty) {
          return customScaffold(
              ViewStateEmptyWidget(onPressed: model.initData));
        }
        return Scaffold(
          body: CustomCardBar(
            data: model.cardInfoEntity,
            body: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(10.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    model.cardInfoEntity.isExposureData == 1
                        ? Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                cardData(
                                    iconData: Icons.remove_red_eye_outlined,
                                    num: model.cardInfoEntity.exposureNum!
                                        .toInt()
                                        .toString()),
                                cardData(
                                    iconData: Icons.search,
                                    num: model.cardInfoEntity.searchNum!
                                        .toInt()
                                        .toString()),
                                cardData(
                                    iconData: HippoIcon.operation,
                                    num: model.cardInfoEntity.clickNum!
                                        .toInt()
                                        .toString()),
                                cardData(
                                    iconData: Icons.star_border_outlined,
                                    num: model.cardInfoEntity.cardFavorNum!
                                        .toInt()
                                        .toString()),
                              ],
                            ),
                            padding: EdgeInsets.only(
                                left: 2.r, right: 27.r, bottom: 20.r, top: 5.r),
                          )
                        : SizedBox.shrink(),
                    subtitleText("描述:"),
                    contentText(model.cardInfoEntity.selfDesc!),
                    model.cardInfoEntity.album != null &&
                            model.cardInfoEntity.album != ""
                        ? subtitleText("相册:")
                        : SizedBox.shrink(),
                    Container(
                      margin: EdgeInsets.fromLTRB(17.r, 13.r, 17.r, 13.r),
                      child: Album(
                        imgUrlOrigin: model.cardInfoEntity.album,
                      ),
                    ),
                    model.cardInfoEntity.isExposureContact == 1
                        ? subtitleText("二维码:")
                        : SizedBox.shrink(),
                    model.cardInfoEntity.isExposureContact == 1
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(9.r, 0.r, 17.r, 0.r),
                            child: Row(
                              children: [
                                model.cardInfoEntity.wxQrUrl != null
                                    ? qrWidget(model.cardInfoEntity.wxQrUrl!,
                                        QrTypeEnum.WEIXIN)
                                    : SizedBox.shrink(),
                                model.cardInfoEntity.qqQrUrl != null
                                    ? qrWidget(model.cardInfoEntity.qqQrUrl!,
                                        QrTypeEnum.QQ)
                                    : SizedBox.shrink(),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Material(
            elevation: 0.5,
            color: Colors.white,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50.r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  shareButton(model, context),
                  recognizeButton(context, model, userModel),
                  favorButton(model, context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget subtitleText(String subtitle) => Text(
        subtitle,
        style: TextStyle(
            color: Colors.black, fontSize: 22.sp, fontWeight: FontWeight.w600),
      );

  Widget contentText(String content) => Container(
        margin: EdgeInsets.fromLTRB(20.r, 13.r, 20.r, 20.r),
        child: Text(
          content,
          style: TextStyle(
              color: Colors.black,
              fontSize: 17.sp,
              fontWeight: FontWeight.w400),
        ),
      );

  Widget customScaffold(Widget body) {
    var appBar = AppBar(
      leading: BackButton(
        color: Colors.black,
      ),
      title: Text(
        "卡片详情",
        style: TextStyle(
            fontSize: 18.sp, color: Colors.black, fontWeight: FontWeight.w500),
      ),
      backgroundColor: Colors.white,
    );
    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }

  Widget cardData({required IconData iconData, required String num}) =>
      Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              color: Colors.grey,
              size: 24.r,
            ),
            SizedBox(
              width: 2.r,
            ),
            Text(
              num,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );

  Widget qrWidget(String qrUrl, String qrType) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0.r),
        child: Container(
          width: width,
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: CommonImage(
                  imgUrl: qrUrl,
                  height: height,
                  width: width,
                  radius: 0,
                ),
              ),
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
    );
  }

  Widget recognizeButton(
          BuildContext context, CardInfoViewModel model, UserModel userModel) =>
      InkWell(
        onTap: () async {
          var card = model.cardInfoEntity;
          if (!StorageManager.isLogin) {
            SmartDialog.showToast("请先登录哦～");
            return;
          } else if (card.uid == StorageManager.uid) {
            SmartDialog.showToast("我想和自己做个朋友～");
            return;
          } else if (userModel.userInfo.userStatus ==
              UserStatusEnum.USER_STATUS_FREEZE) {
            SmartDialog.showToast("冻结期间无法认识别人哦～");
            return;
          }
          if (card.relationIsApplicant == 1 &&
              card.relationStatus == RelationTypeEnum.REFUSED) {
            SmartDialog.showToast("真不巧。。对方已经拒绝过你");
            return;
          } else if (card.relationIsApplicant == 0 &&
              card.relationStatus == RelationTypeEnum.REFUSED) {
            SmartDialog.showToast("真不巧。。你已经拒绝过对方");
            return;
          }
          Navigator.of(context)
              .pushNamed(AppRouter.RecognizePageRoute, arguments: card);
        },
        child: Container(
            child: Row(
          children: [
            Icon(
              Icons.send_rounded,
              color: Colors.blue,
              size: 21.5.r,
            ),
            SizedBox(
              width: 2.5.r,
            ),
            Text(
              '想认识',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500),
            ),
          ],
        )),
      );

  Widget favorButton(CardInfoViewModel model, BuildContext context) => Container(
        child: Row(
          children: [
            LikeButton(
              isLiked: model.cardInfoEntity.isFavored == 1,
              size: 24.r,
              circleColor:
                  CircleColor(start: Color(0xff00ddff), end: Colors.orange),
              bubblesColor: BubblesColor(
                dotPrimaryColor: Colors.yellow,
                dotSecondaryColor: Colors.orange,
              ),
              likeBuilder: (bool isLiked) {
                return Icon(
                  Icons.star_rounded,
                  color: isLiked ? Colors.orange : Colors.grey,
                  size: 24.r,
                );
              },
              onTap: (bool isFavored) async {
                if (!StorageManager.isLogin) {
                  SmartDialog.showToast("请先登录哦～");
                  return false;
                }
                if (isFavored) {
                  model.cancelFavor();
                } else {
                  model.addFavor();
                }
                return !isFavored;
              },
            ),
            Text(
              "收藏",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );

  Widget shareButton(CardInfoViewModel model, BuildContext context) =>
      GestureDetector(
        onTap: () {
          if (!StorageManager.isLogin) {
            SmartDialog.showToast("请先登录哦～");
            return;
          }
          //添加点击事件
          ActionService.addAction(
              cardId: model.cardInfoEntity.id!,
              cardType: model.cardInfoEntity.type!,
              targetUid: model.cardInfoEntity.uid!,
              actionType: ActionTypeEnum.ACTION_SHARE);
          Navigator.of(context).pushNamed(AppRouter.SharePageRoute,
              arguments: model.cardInfoEntity);
        },
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.ios_share,
                color: Colors.grey,
                size: 21.5.r,
              ),
              SizedBox(
                width: 2.5.r,
              ),
              Text(
                "分享",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
}
