import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomListTile extends StatelessWidget {
  final Widget child;
  final String headerText;
  final VoidCallback onTap;

  CustomListTile(
      {required this.child, required this.headerText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 15.r),
        color: Colors.white,
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 10.r,
                  ),
                  Text(
                    headerText,
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 8.r),
                    child: child,
                  ),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.grey,
                    size: 17.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
