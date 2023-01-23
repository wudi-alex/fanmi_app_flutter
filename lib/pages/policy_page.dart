import 'dart:io';

import 'package:fanmi/config/app_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PolicyPage extends StatefulWidget {
  @override
  _PolicyPageState createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage>
    with SingleTickerProviderStateMixin {
  final tabs = ['隐私政策', '用户协议'];
  late TabController _tabController;
  double lineProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: TabBar(
          isScrollable: true,
          labelStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          labelColor: Colors.black,
          controller: _tabController,
          tabs: List.generate(
              tabs.length,
              (index) => Tab(
                    text: tabs[index],
                  )),
        ),
        bottom: PreferredSize(
          child: _progressBar(lineProgress, context),
          preferredSize: Size.fromHeight(3.0),
        ),
      ),
      body: Container(
        child: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: tabs.map((e) {
            switch (e) {
              case '隐私政策':
                return webView('https://fanminet.com/privacy_policy');
              case '用户协议':
                return webView('https://fanminet.com/user_license_agreement');
            }
            return Container();
          }).toList(),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 0.r, horizontal: 10.r),
        height: 80.r,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5.r,),
            Text(
              '请您认真阅读凡觅《隐私政策》及《用户协议》',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () {
                      exit(0);
                    },
                    child: Text(
                      '不同意并退出',
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500),
                    )),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRouter.WelcomeGuidePageRoute);
                  },
                  child: Text(
                    '已阅读并同意',
                    style:
                        TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget webView(String url) => WebView(
    initialUrl: url,
    javascriptMode: JavascriptMode.unrestricted,
    onProgress: (v) {
      setState(() {
        lineProgress = v / 100;
      });
    },
  );

  _progressBar(double progress, BuildContext context) {
    return LinearProgressIndicator(
      backgroundColor: Colors.white70.withOpacity(0),
      value: progress == 1.0 ? 0 : progress,
      valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 667),
      builder: () => RefreshConfiguration(
        hideFooterWhenNotFull: true,
        child: MaterialApp(
          onGenerateRoute: AppRouter.generateRoute,
          debugShowCheckedModeBanner: false,
          builder: (BuildContext context, Widget? child) {
            return GestureDetector(
              child: FlutterSmartDialog(child: child),
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null) {
                  FocusManager.instance.primaryFocus!.unfocus();
                }
              },
            );
          },
          home: PolicyPage(),
        ),
      ),
    );
  }
}
