import 'package:fanmi/config/hippo_icon.dart';
import 'package:fanmi/widgets/album.dart';
import 'package:fanmi/view_models/card_info_view_model.dart';
import 'package:fanmi/widgets/provider_widget.dart';
import 'package:fanmi/widgets/view_state_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_card_bar.dart';

class CardInfoPage extends StatelessWidget {
  final int cardId;

  const CardInfoPage({Key? key, required this.cardId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              controller: ScrollController(),
              physics: NeverScrollableScrollPhysics(),
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
                    subtitleText("It's me:"),
                    contentText(model.cardInfoEntity.selfDesc!),
                    model.cardInfoEntity.album != null &&
                            model.cardInfoEntity.album != ""
                        ? subtitleText("Album:")
                        : SizedBox.shrink(),
                    Container(
                      margin: EdgeInsets.fromLTRB(17.r, 13.r, 17.r, 0.r),
                      child: Album(
                        imgUrlOrigin: model.cardInfoEntity.album,
                      ),
                    ),
                  ],
                ),
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
              fontSize: 18.sp,
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
}
