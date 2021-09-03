import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/enums/message_type_enum.dart';
import 'package:fanmi/utils/time_utils.dart';
import 'package:fanmi/widgets/common_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageItem extends StatelessWidget {
  final int messageType;
  final int? msgTimestamp;
  final bool isPeerRead;
  final String? msgText;
  final String? imgUrl;
  final String avatarUrl;
  final bool isSelf;
  final int? cardId;
  final int? cardType;
  final int? selfAvatarCardId;
  final int? otherAvatarCardId;


  get avatarSize => 43.r;

  get avatarPad => 6.r;

  const MessageItem(
      {Key? key,
      required this.messageType,
      this.msgTimestamp,
      required this.isPeerRead,
      this.msgText,
      this.imgUrl,
      required this.avatarUrl,
      required this.isSelf,
      this.cardId,
      this.cardType,
      this.selfAvatarCardId,
      this.otherAvatarCardId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var contentMaxSize =
        MediaQuery.of(context).size.width - 2 * avatarSize - 10.r;
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          msgTimestamp != null
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.r),
                  child: Text(
                    messageItemTime(msgTimestamp!),
                    style: TextStyle(fontSize: 12.r, color: Colors.grey),
                  ),
                )
              : SizedBox.shrink(),
          isSelf
              ? selfMsgWrapper(content(context), contentMaxSize, context)
              : msgWrapper(content(context), contentMaxSize, context),
        ],
      ),
    );
  }

  Widget selfMsgWrapper(
          Widget content, double maxWidth, BuildContext context) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          Row(
            children: [
              Text(
                isPeerRead ? "已读" : "未读",
                style: TextStyle(
                    fontSize: 11.r,
                    color: isPeerRead ? Colors.grey : Colors.lightBlueAccent),
              ),
              Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: content,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: avatarPad, vertical: avatarPad),
            child: CommonImage.avatar(
              height: avatarSize,
              radius: 5.r,
              imgUrl: avatarUrl,
              callback: selfAvatarCardId != null
                  ? () {
                      Navigator.of(context).pushNamed(
                          AppRouter.CardInfoPageRoute,
                          arguments: selfAvatarCardId);
                    }
                  : null,
            ),
          ),
        ],
      );

  Widget msgWrapper(Widget content, double maxWidth, BuildContext context) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: avatarPad, vertical: avatarPad),
            child: CommonImage.avatar(
              height: avatarSize,
              radius: 5.r,
              imgUrl: avatarUrl,
              callback: otherAvatarCardId != null
                  ? () {
                      Navigator.of(context).pushNamed(
                          AppRouter.CardInfoPageRoute,
                          arguments: otherAvatarCardId);
                    }
                  : null,
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: content,
          ),
          Spacer(),
        ],
      );

  Widget content(BuildContext context) {
    switch (messageType) {
      case MessageTypeEnum.NORMAL:
        return Container(
          padding: EdgeInsets.only(top: 3.r),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.r)),
            ),
            elevation: 1.0,
            color: isSelf ? Colors.lightBlueAccent : Colors.white,
            child: Container(
              padding: EdgeInsets.all(8.r),
              child: Text(
                msgText!,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        );
      case MessageTypeEnum.IMG:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8.r, horizontal: 3.r),
          child: CommonImage.photo(
            width: 180.r,
            height: 150.r,
            imgUrl: imgUrl,
          ),
        );
      //名片邮件
      case MessageTypeEnum.CARD:
        CardTypeEnum cardTypeEnum = CardTypeEnum.getCardType(cardType!);
        return Container(
          padding: EdgeInsets.only(top: 3.r),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.r)),
            ),
            elevation: 1.0,
            color: isSelf ? Colors.lightBlueAccent : Colors.white,
            child: Container(
              padding: EdgeInsets.all(8.r),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '我给你发送了我的${cardTypeEnum.desc}名片，',
                      style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                    TextSpan(
                        text: '点击这里来看看吧～',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w400,
                          color: cardTypeEnum.color,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.of(context).pushNamed(
                              AppRouter.CardInfoPageRoute,
                              arguments: cardId!)),
                  ],
                ),
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }
}
