import 'package:fanmi/config/hippo_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineBoard extends StatelessWidget {
  final int exposureNum;
  final int exposureAddNum;
  final int searchNum;
  final int searchAddNum;
  final int clickNum;
  final int clickAddNum;
  final int favorNum;
  final int favorAddNum;

  const MineBoard(
      {Key? key,
      required this.exposureNum,
      required this.exposureAddNum,
      required this.searchNum,
      required this.searchAddNum,
      required this.clickNum,
      required this.clickAddNum,
      required this.favorNum,
      required this.favorAddNum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0.r)),
      ),
      elevation: 1.0,
      child: Container(
        margin: EdgeInsets.fromLTRB(10.r, 5.r, 10.r, 5.r),
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(15.r),
        child: Stack(
          children: [
            Column(
              children: [
                MineBoardItem(
                  title: "曝光",
                  titleStyle: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400),
                  num: exposureNum,
                  numStyle: TextStyle(
                      fontSize: 40.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                  addNum: exposureAddNum,
                  icon: Icons.remove_red_eye_outlined,
                  iconSize: 20.sp,
                ),
                SizedBox(
                  height: 20.r,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MineBoardItem(
                      title: "搜索",
                      titleStyle: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400),
                      num: searchNum,
                      numStyle: TextStyle(
                          fontSize: 25.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                      addNum: searchAddNum,
                      icon: Icons.search,
                      iconSize: 20.sp,
                    ),
                    MineBoardItem(
                      title: "点击",
                      titleStyle: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400),
                      num: clickNum,
                      numStyle: TextStyle(
                          fontSize: 25.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                      addNum: clickAddNum,
                      icon: HippoIcon.operation,
                      iconSize: 20.sp,
                    ),
                    MineBoardItem(
                      title: "收藏",
                      titleStyle: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400),
                      num: favorNum,
                      numStyle: TextStyle(
                          fontSize: 25.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                      addNum: favorAddNum,
                      icon: Icons.star_border_outlined,
                      iconSize: 20.sp,
                    ),
                  ],
                )
              ],
            ),
            Positioned(
              child: Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.grey,
                size: 25,
              ),
              right: 0,
              top: 55,
            ),
          ],
        ),
      ),
    );
  }
}

class MineBoardItem extends StatelessWidget {
  final String title;
  final TextStyle titleStyle;
  final int num;
  final TextStyle numStyle;
  final IconData icon;
  final double iconSize;
  final int addNum;

  const MineBoardItem(
      {Key? key,
      required this.title,
      required this.titleStyle,
      required this.num,
      required this.numStyle,
      required this.icon,
      required this.iconSize,
      required this.addNum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: titleStyle,
              ),
              SizedBox(
                width: 5,
              ),
              Icon(
                icon,
                color: Colors.grey,
                size: iconSize,
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                num.toString(),
                style: numStyle,
              ),
              SizedBox(
                width: 5,
              ),
              Text.rich(TextSpan(
                  text: '+',
                  style: TextStyle(color: Colors.grey, fontSize: 17.sp),
                  children: [
                    TextSpan(
                        text: addNum.toString(),
                        style: TextStyle(color: Colors.blue)),
                  ]))
            ],
          ),
        ],
      ),
    );
  }
}
