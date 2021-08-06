import 'package:fanmi/pages/message_list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';

class AppRouter {
  static const String MainPageRoute = '/main_page_route';
  static const String LoginPageRoute = '/login_page_route';
  static const String MessageListPageRoute = '/message_list_page_route';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MessageListPageRoute:
        return PageTransition(
            child: MessageListPage(
              userId: settings.arguments as String,
            ),
            type: PageTransitionType.rightToLeft,
            settings: settings);
    }
  }
}
