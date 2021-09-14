import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'common_image.dart';

class Album extends StatelessWidget {
  final String? imgUrlOrigin;
  final double onePicDivide;
  final double twoPicDivide;
  final double threePicDivide;

  const Album({
    Key? key,
    required this.imgUrlOrigin,
    this.twoPicDivide = 2,
    this.threePicDivide = 3,
    this.onePicDivide = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> imgUrls = imgUrlOrigin != null && imgUrlOrigin != ""
        ? imgUrlOrigin!.split(";")
        : [];
    if (imgUrls.length == 1) {
      return Container(
        alignment: Alignment.topLeft,
        child: CommonImage.photo(
          imgUrl: imgUrls[0],
          width: (MediaQuery.of(context).size.width - 100.r) / onePicDivide,
          height: (MediaQuery.of(context).size.width - 130.r) / onePicDivide,
        ),
      );
    } else if (imgUrls.length == 2) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonImage.photo(
              imgUrl: imgUrls[0],
              width: (MediaQuery.of(context).size.width - 70.r) / twoPicDivide,
              height: (MediaQuery.of(context).size.width - 70.r) / twoPicDivide,
            ),
            SizedBox(
              width: 12.r,
            ),
            CommonImage.photo(
              imgUrl: imgUrls[1],
              width: (MediaQuery.of(context).size.width - 70.r) / twoPicDivide,
              height: (MediaQuery.of(context).size.width - 70.r) / twoPicDivide,
            ),
          ],
        ),
      );
    } else if (imgUrls.length == 3) {
      return photoSpan(imgUrls, context);
    } else if (imgUrls.length == 4) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonImage.photo(
                imgUrl: imgUrls[0],
                width:
                    (MediaQuery.of(context).size.width - 70.r) / twoPicDivide,
                height:
                    (MediaQuery.of(context).size.width - 70.r) / twoPicDivide,
              ),
              SizedBox(
                width: 12.r,
              ),
              CommonImage.photo(
                imgUrl: imgUrls[1],
                width:
                    (MediaQuery.of(context).size.width - 70.r) / twoPicDivide,
                height:
                    (MediaQuery.of(context).size.width - 70.r) / twoPicDivide,
              ),
            ],
          ),
          SizedBox(
            height: 12.r,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonImage.photo(
                imgUrl: imgUrls[2],
                width:
                    (MediaQuery.of(context).size.width - 70.r) / twoPicDivide,
                height:
                    (MediaQuery.of(context).size.width - 70.r) / twoPicDivide,
              ),
              SizedBox(
                width: 12.r,
              ),
              CommonImage.photo(
                imgUrl: imgUrls[3],
                width:
                    (MediaQuery.of(context).size.width - 70.r) / twoPicDivide,
                height:
                    (MediaQuery.of(context).size.width - 70.r) / twoPicDivide,
              ),
            ],
          ),
        ],
      );
    } else if (imgUrls.length > 4 && imgUrls.length <= 6) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          photoSpan(imgUrls.sublist(0, 3), context),
          SizedBox(
            height: 8,
          ),
          photoSpan(
              imgUrls.sublist(
                3,
              ),
              context)
        ],
      );
    } else if (imgUrls.length >= 7) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          photoSpan(imgUrls.sublist(0, 3), context),
          SizedBox(
            height: 8,
          ),
          photoSpan(imgUrls.sublist(3, 6), context),
          SizedBox(
            height: 8,
          ),
          photoSpan(
              imgUrls.sublist(
                6,),
              context)
        ],
      );
    }
    return SizedBox.shrink();
  }

  Widget photoSpan(List<String> imgUrls, BuildContext context) {
    var width = (MediaQuery.of(context).size.width - 70.r) / threePicDivide;
    double height = (MediaQuery.of(context).size.width - 70.r) / threePicDivide;
    var spacer = SizedBox(
      width: 8.r,
    );
    if (imgUrls.length == 1) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CommonImage.photo(
              imgUrl: imgUrls[0],
              width: width,
              height: height,
            ),
          ],
        ),
      );
    } else if (imgUrls.length == 2) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CommonImage.photo(
              imgUrl: imgUrls[0],
              width: width,
              height: height,
            ),
            spacer,
            CommonImage.photo(
              imgUrl: imgUrls[1],
              width: width,
              height: height,
            ),
          ],
        ),
      );
    } else if (imgUrls.length >= 3) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CommonImage.photo(
              imgUrl: imgUrls[0],
              width: width,
              height: height,
            ),
            spacer,
            CommonImage.photo(
              imgUrl: imgUrls[1],
              width: width,
              height: height,
            ),
            spacer,
            CommonImage.photo(
              imgUrl: imgUrls[2],
              width: width,
              height: height,
            ),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }
}
