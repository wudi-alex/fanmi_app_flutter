import 'package:fanmi/config/qq_config.dart';
import 'package:fanmi/pages/splash_page.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/view_models/card_list_model.dart';
import 'package:fanmi/view_models/conversion_list_model.dart';
import 'package:fanmi/view_models/message_list_model.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tencent_kit/tencent_kit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/app_router.dart';

void main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  Tencent.instance.registerApp(appId: QQConfig.appId);
  await StorageManager.init();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(FanmiApp());
  });
  configLoading();
}

class FanmiApp extends StatefulWidget {
  @override
  _FanmiAppState createState() => _FanmiAppState();
}

class _FanmiAppState extends State<FanmiApp> {
  final JPush jpush = new JPush();

  @override
  void initState() {
    super.initState();
    jPushInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  jPushInit() async {
    try {
      jpush.addEventHandler(
        onReceiveNotification: (Map<String, dynamic> message) async {
          print("flutter onReceiveNotification: $message");
        },
      );
    } on PlatformException {
      print('Failed to get platform version.');
    }
    jpush.setup(
      appKey: "", //你自己应用的 AppKey
      channel: "theChannel",
      production: false,
      debug: true,
    );
    jpush.applyPushAuthority(
        NotificationSettingsIOS(sound: true, alert: true, badge: true));
    jpush.setBadge(0);

    jpush.getRegistrationID().then((v) {
      StorageManager.regId = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => UserModel(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => CardListModel(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => ConversionListModel(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => MessageListModel(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: Size(375, 667),
        builder: () => RefreshConfiguration(
          hideFooterWhenNotFull: true,
          child: MaterialApp(
            onGenerateRoute: AppRouter.generateRoute,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: Locale('zh', 'CH'),
            builder: EasyLoading.init(
                builder: (BuildContext context, Widget? child) {
              EasyLoading.init();
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
            }),
            home: SplashPage(),
          ),
        ),
      ),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.light
    ..fontSize = 15.0
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.blue
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.blue
    ..textColor = Colors.black
    ..maskColor = Colors.grey.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = true;
}
