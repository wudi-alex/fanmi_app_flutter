import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/pages/card_edit_page.dart';
import 'package:fanmi/pages/card_info_page/card_info_page.dart';
import 'package:fanmi/pages/guide_page.dart';
import 'package:fanmi/pages/login_page.dart';
import 'package:fanmi/pages/long_text_edit_page.dart';
import 'package:fanmi/pages/main_page.dart';
import 'package:fanmi/pages/message_list_page.dart';
import 'package:fanmi/pages/mine_page/mine_about_page.dart';
import 'package:fanmi/pages/mine_page/mine_contact_page.dart';
import 'package:fanmi/pages/mine_page/mine_mail_pwd_page.dart';
import 'package:fanmi/pages/policy_page.dart';
import 'package:fanmi/pages/search_page/search_page.dart';
import 'package:fanmi/pages/text_edit_page.dart';
import 'package:fanmi/pages/qr_page/qr_upload_page.dart';
import 'package:fanmi/widgets/web_view_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';

class AppRouter {
  static const String MainPageRoute = '/main_page';
  static const String CardInfoPageRoute = '/card_info_page_route';
  static const String LoginPageRoute = '/login';
  static const String SearchPageRoute = '/search';
  static const String MailPageRoute = '/mail';
  static const String RecognizePageRoute = '/recognize_mail';
  static const String CardEditPageRoute = '/card_edit_page';
  static const String GenderGuidePageRoute = '/gender_guide_page';
  static const String BirthDateGuidePageRoute = '/birth_date_guide_page';
  static const String CityGuidePageRoute = '/city_guide_page';
  static const String MailMessagePageRoute = '/mail_message_page';
  static const String MailSystemMessagePageRoute = '/mail_system_message_page';
  static const String SendResponseMailPageRoute =
      '/send_response_mail_page_route';
  static const String ReportMailPageRoute = '/send_report_mail_page_route';
  static const String MineBoardDetailPageRoute =
      '/mine_board_detail_page_route';
  static const String MineContactListPageRoute =
      '/mine_contact_list_page_route';
  static const String MineFavorCardPageRoute = '/mine_favor_card_page_route';
  static const String MineNamePageRoute = '/mine_name_page_route';
  static const String MineContactPageRoute = '/mine_contact_page_route';
  static const String MineCityPageRoute = '/mine_city_page_route';
  static const String MineBirthPageRoute = '/mine_birth_page_route';
  static const String MineMailPasswordPageRoute =
      '/mine_mail_password_page_route';
  static const String MineContactUsPageRoute = '/mine_contact_us_page_route';
  static const String MineUserPolicyPageRoute = '/mine_user_policy_page_route';
  static const String MinePrivacyPolicyPageRoute =
      '/mine_privacy_policy_page_route';
  static const String MineAboutPageRoute = '/mine_about_page_route';
  static const String QrUploadPageRoute = '/qr_upload_page_route';
  static const String MineContactDetailPageRoute =
      '/mine_contact_detail_page_route';

  static const String EmailLoginPageRoute = '/email_login_page_route';
  static const String PolicyPageRoute = '/policy_page_route';

  static const String WelcomeGuidePageRoute = '/welcome_guide_page';
  static const String WelcomeGuidePageRoute1 = '/welcome_guide_page1';
  static const String WelcomeGuidePageRoute2 = '/welcome_guide_page2';
  static const String WelcomeGuidePageRoute3 = '/welcome_guide_page3';
  static const String WelcomeGuidePageRoute4 = '/welcome_guide_page4';

  static const String MessageListPageRoute = '/message_list_page_route';

  static const String TextEditPageRoute = '/text_edit_page_route';
  static const String LongTextEditPageRoute = '/long_text_edit_page_route';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MessageListPageRoute:
        return PageTransition(
            child: MessageListPage(
              userId: settings.arguments as String,
            ),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case LoginPageRoute:
        return PageTransition(
            child: LoginPage(),
            type: PageTransitionType.bottomToTop,
            settings: settings);
      case PolicyPageRoute:
        return PageTransition(
            child: PolicyPage(),
            type: PageTransitionType.fade,
            settings: settings);
      case CityGuidePageRoute:
        return PageTransition(
            child: CityGuidePage(),
            type: PageTransitionType.fade,
            settings: settings);
      case GenderGuidePageRoute:
        return PageTransition(
            child: GenderGuidePage(),
            type: PageTransitionType.fade,
            settings: settings);
      case BirthDateGuidePageRoute:
        return PageTransition(
            child: BirthDateGuidePage(),
            type: PageTransitionType.fade,
            settings: settings);
      case WelcomeGuidePageRoute:
        return PageTransition(
            child: WelcomeGuidePage(),
            type: PageTransitionType.fade,
            settings: settings);
      case WelcomeGuidePageRoute1:
        return PageTransition(
            child: WelcomeGuidePage1(),
            type: PageTransitionType.fade,
            settings: settings);
      case WelcomeGuidePageRoute2:
        return PageTransition(
            child: WelcomeGuidePage2(),
            type: PageTransitionType.fade,
            settings: settings);
      case WelcomeGuidePageRoute3:
        return PageTransition(
            child: WelcomeGuidePage3(),
            type: PageTransitionType.fade,
            settings: settings);
      case WelcomeGuidePageRoute4:
        return PageTransition(
            child: WelcomeGuidePage4(),
            type: PageTransitionType.fade,
            settings: settings);

      case SearchPageRoute:
        return PageTransition(
            child: SearchPage(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case MainPageRoute:
        return PageTransition(
            child: MainPage(),
            type: PageTransitionType.fade,
            settings: settings);

      case CardInfoPageRoute:
        return PageTransition(
            child: CardInfoPage(cardId: settings.arguments as int),
            type: PageTransitionType.rightToLeft,
            settings: settings);

      case TextEditPageRoute:
        var args = settings.arguments as List;
        return PageTransition(
            child: TextEditPage(
              initText: args[0] as String?,
              appbarName: args[1] as String,
              maxLength: args[2] as int,
            ),
            type: PageTransitionType.bottomToTop,
            settings: settings);
      case LongTextEditPageRoute:
        var args = settings.arguments as List;
        return PageTransition(
            child: LongTextEditPage(
              initText: args[0] as String?,
              appbarName: args[1] as String,
              maxLength: args[2] as int,
            ),
            type: PageTransitionType.bottomToTop,
            settings: settings);

      case CardEditPageRoute:
        return PageTransition(
            child: CardEditPage(
              cardType: settings.arguments as CardTypeEnum,
            ),
            type: PageTransitionType.rightToLeft,
            settings: settings);

      case QrUploadPageRoute:
        return PageTransition(
            child: QrUploadPage(
              qrType: (settings.arguments as List)[0] as String,
              qrUrl: (settings.arguments as List)[1] as String?,
            ),
            type: PageTransitionType.rightToLeft,
            settings: settings);

      case MineContactPageRoute:
        return PageTransition(
            child: MineContactPage(),
            type: PageTransitionType.rightToLeft,
            settings: settings);

      case MineMailPasswordPageRoute:
        return PageTransition(
            child: MineMailPasswordPage(),
            type: PageTransitionType.rightToLeft,
            settings: settings);

      case MineUserPolicyPageRoute:
        return PageTransition(
            child: WebViewPage(
              title: '用户协议',
              url: "https://fanminet.com/user_license_agreement",
            ),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case MinePrivacyPolicyPageRoute:
        return PageTransition(
            child: WebViewPage(
              title: '隐私协议',
              url: "https://fanminet.com/privacy_policy",
            ),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case MineContactUsPageRoute:
        return PageTransition(
            child: WebViewPage(
              title: '联系我们',
              url: "https://fanminet.com/contact_us",
            ),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case MineAboutPageRoute:
        return PageTransition(
            child: MineAboutPage(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
    }
  }
}
