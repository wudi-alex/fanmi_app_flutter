import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TitleAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: SizedBox.shrink(),
      title: Text(
        title,
        style: TextStyle(
            fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      centerTitle: true,
      elevation: 0.5,
      backgroundColor: Colors.white,
      titleSpacing: 0,
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class SubtitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SubtitleAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: TextStyle(
            color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w500),
      ),
      leading: BackButton(
        color: Colors.black,
      ),
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
