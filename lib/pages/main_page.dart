import 'package:badges/badges.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/pages/search_page/search_page.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/view_models/conversion_list_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'card_list_page/card_list_page.dart';
import 'conservation_list_page.dart';
import 'mine_page/mine_page.dart';

List<Widget> pages = <Widget>[
  SearchPage(),
  CardListPage(),
  ConversionListPage(),
  MinePage(),
];

class MainPage extends StatefulWidget {
  final int initIndex;

  const MainPage({Key? key, this.initIndex = 0}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _pageController = PageController();
  late int _selectedIndex;

  get isLogin => StorageManager.isLogin;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initIndex;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ConversionListModel conversionListModel =
        Provider.of<ConversionListModel>(context);
    int unreadCnt = conversionListModel.unreadCntTotal;
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
              BottomNavigationBarItem(
                  icon: unreadCnt > 0
                      ? Badge(
                          child: Icon(Icons.email),
                          badgeContent: Text(
                            unreadCnt < 100 ? unreadCnt.toString() : "99+",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      : Icon(Icons.email),
                  label: '消息'),
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
