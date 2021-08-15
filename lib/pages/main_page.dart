import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/pages/search_page/search_page.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'card_list_page/card_list_page.dart';
import 'conservation_list_page.dart';
import 'mine_page.dart';

List<Widget> pages = <Widget>[
  SearchPage(),
  CardListPage(),
  ConversionListPage(),
  MinePage()
];

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _pageController = PageController();
  int _selectedIndex = 0;

  get isLogin => StorageManager.isLogin;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemBuilder: (ctx, index) => pages[index],
        itemCount: pages.length,
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLogin
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "登录凡觅，开始相识相遇之旅",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(AppRouter.LoginPageRoute);
                        },
                        child: Text(
                          "立即登录",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp),
                        ),
                      )
                    ],
                  ),
                ),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '主页'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.web_outlined), label: '名片'),
              BottomNavigationBarItem(icon: Icon(Icons.email), label: '消息'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle), label: '我的'),
            ],
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index != 0 && !isLogin) {
                Navigator.of(context).pushNamed(AppRouter.LoginPageRoute);
              } else {
                _pageController.jumpToPage(index);
              }
            },
          ),
        ],
      ),
    );
  }
}
