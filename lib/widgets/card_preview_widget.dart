import 'dart:math';

import 'package:fanmi/config/text_constants.dart';
import 'package:fanmi/entity/card_preview_entity.dart';
import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/enums/gender_type_enum.dart';
import 'package:fanmi/utils/time_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'album.dart';
import 'common_image.dart';

class CardPreviewWidget extends StatelessWidget {
  final CardPreviewEntity data;
  final VoidCallback? callback;
  final double ratio;

  CardPreviewWidget({required this.data, this.callback, this.ratio = 1});

  double ratioWrap(double value) {
    return ratio * value;
  }

  get gender => GenderTypeEnum.getGender(data.gender!);

  get cardTypeEnum => CardTypeEnum.getCardType(data.type!);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        width: ratioWrap(MediaQuery.of(context).size.width),
        child: Card(
          margin: EdgeInsets.fromLTRB(
              ratioWrap(10.r), ratioWrap(5.r), ratioWrap(10.r), ratioWrap(5.r)),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(ratioWrap(20.r))),
          ),
          elevation: 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cardHead(context),
              Container(
                padding: EdgeInsets.fromLTRB(0, ratioWrap(10.r), 0, 0),
                child: Text(
                  data.desc!,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: ratioWrap(16.sp),
                      fontWeight: FontWeight.normal),
                ),
              ),
              data.album != null && data.album!.length > 0
                  ? Padding(
                      padding: EdgeInsets.only(top: ratioWrap(10.r)),
                      child: Album(
                        imgUrlOrigin: data.album,
                        onePicDivide: 1 / ratio,
                        twoPicDivide: 2 / ratio,
                        threePicDivide: 3 / ratio,
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardHead(BuildContext context) => Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonImage.avatar(
              imgUrl: data.avatarUrl!,
              callback: callback,
              radius: ratioWrap(43.r),
              height: ratioWrap(5.r),
            ),
            SizedBox(
              width: ratioWrap(5.r),
            ),
            headBar(gender),
            Spacer(),
            tailBar(cardTypeEnum),
          ],
        ),
      );

  Widget tailBar(CardTypeEnum type) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              type.svgPath,
              width: ratioWrap(26.r),
            ),
            data.city != null && data.city != ""
                ? Text(
                    data.city!,
                    style: TextStyle(
                        fontSize: ratioWrap(13.sp), color: Colors.grey),
                  )
                : SizedBox.shrink()
          ],
        ),
      );

  Widget genderBar(GenderTypeEnum gender) {
    int age = getAge(data.birthDate);
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: ratioWrap(2.r), horizontal: ratioWrap(3.r)),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(ratioWrap(8.r))),
          color: gender.color),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            gender.svgPath,
            width: ratioWrap(10.r),
            color: Colors.white,
          ),
          SizedBox(
            width: ratioWrap(2.r),
          ),
          Text(
            age.toString(),
            style: TextStyle(fontSize: ratioWrap(10.sp), color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget onlineBar() {
    var loginTime = DateTime.parse(data.lastLoginTime!);
    var isOnline = DateTime.now().difference(loginTime).inSeconds < 60;
    return Container(
      child: Row(
        children: [
          CircleAvatar(
            radius: ratioWrap(5.r),
            backgroundColor: isOnline ? Colors.green : Colors.grey,
          ),
          SizedBox(
            width: ratioWrap(1.r),
          ),
          Text(
            isOnline ? "在线" : customTime(data.lastLoginTime!),
            style: TextStyle(
                color: isOnline ? Colors.black : Colors.grey,
                fontSize: ratioWrap(12.sp)),
          )
        ],
      ),
    );
  }

  Widget headBar(GenderTypeEnum gender) => Container(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                data.name!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ratioWrap(16.sp),
                ),
              ),
              SizedBox(
                width: ratioWrap(1.r),
              ),
              genderBar(gender),
              SizedBox(
                width: ratioWrap(4.r),
              ),
              onlineBar()
            ],
          ),
          Container(
            constraints: BoxConstraints(maxWidth: ratioWrap(220.r)),
            child: Text(data.sign ?? TextConstants.DEFAULT_CARD_SIGN,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontSize: ratioWrap(14.sp), color: Colors.grey)),
          ),
        ],
      ));
}
