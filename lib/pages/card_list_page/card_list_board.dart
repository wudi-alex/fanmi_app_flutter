import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/enums/card_type_enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardListBoard extends StatelessWidget {
  final CardTypeEnum type;
  final Color upColor;

  CardListBoard({required this.type, required this.upColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(AppRouter.CardEditPageRoute, arguments: type);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.r, horizontal: 20.r),
        padding: EdgeInsets.symmetric(vertical: 30.r, horizontal: 30.r),
        height: 200.r,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(type.backgroundPath), fit: BoxFit.cover),
          borderRadius: BorderRadius.all(Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                offset: Offset(0.5, 0.5), //阴影xy轴偏移量
                blurRadius: 0.0, //阴影模糊程度
                spreadRadius: 1.0 //阴影扩散程度
                )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type.desc,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 21.sp,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10.r,
            ),
            Text(
              type.info,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
              ),
            )
          ],
        ),
      ),
    );
  }
}
