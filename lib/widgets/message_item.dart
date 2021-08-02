import 'package:fanmi/enums/message_type_enum.dart';
import 'package:fanmi/utils/time_utils.dart';
import 'package:fanmi/widgets/common_image.dart';
import 'package:flutter/cupertino.dart';
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

  get avatarSize => 43.r;

  get avatarPad => 5.r;

  const MessageItem(
      {Key? key,
      required this.messageType,
      this.msgTimestamp,
      required this.isPeerRead,
      this.msgText,
      this.imgUrl,
      required this.avatarUrl,
      required this.isSelf,
      this.cardId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var contentMaxSize =
        MediaQuery.of(context).size.width - 4 * avatarSize - 2 * avatarPad;
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          msgTimestamp != null
              ? Text(
                  messageItemTime(msgTimestamp!),
                  style: TextStyle(fontSize: 10.r, color: Colors.grey),
                )
              : SizedBox.shrink(),
          isSelf
              ? selfMsgWrapper(content(), contentMaxSize)
              : msgWrapper(content(), contentMaxSize),
        ],
      ),
    );
  }

  Widget selfMsgWrapper(Widget content, double maxWidth) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Spacer(),
              Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: content,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: avatarPad),
                child: CommonImage.avatar(
                  height: avatarSize,
                  radius: 5.r,
                  imgUrl: avatarUrl,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.r),
            child: Text(
              isPeerRead ? "已读" : "未读",
              style: TextStyle(
                  fontSize: 10.r,
                  color: isPeerRead ? Colors.grey : Colors.blue),
            ),
          ),
        ],
      );

  Widget msgWrapper(Widget content, double maxWidth) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: avatarPad),
            child: CommonImage.avatar(
              height: avatarSize,
              radius: 5.r,
              imgUrl: avatarUrl,
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: content,
          ),
          Spacer(),
        ],
      );

  Widget content() {
    switch (messageType) {
      case MessageTypeEnum.NORMAL:
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.r)),
          ),
          elevation: 1.0,
          color: isSelf ? Colors.blue : Colors.white,
          child: Container(
            padding: EdgeInsets.all(10.r),
            child: Text(
              msgText!,
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400),
            ),
          ),
        );
      case MessageTypeEnum.IMG:
        return CommonImage.photo(
          width: 180.r,
          height: 150.r,
          imgUrl: imgUrl,
        );
      //todo:名片邮件
      // case MessageTypeEnum.CARD:
      //   int cardId = isSelf ? selfCardId! : sendCardId!;
      //   CardService.getCardPreview(cardId: cardId).then(
      //       (v){
      //         return CardPreviewWidget(data: v);
      //       }
      //   ).onError((error, stackTrace){
      //     print(error);
      //     return Container();
      //   });
      default:
        return Container();
    }
  }
}
