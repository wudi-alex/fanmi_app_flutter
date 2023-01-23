import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/config/color_constants.dart';
import 'package:fanmi/config/text_constants.dart';
import 'package:fanmi/entity/card_info_entity.dart';
import 'package:fanmi/entity/card_preview_entity.dart';
import 'package:fanmi/entity/relation_entity.dart';
import 'package:fanmi/enums/action_type_enum.dart';
import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/generated/json/relation_entity_helper.dart';
import 'package:fanmi/net/action_service.dart';
import 'package:fanmi/net/relation_service.dart';
import 'package:fanmi/utils/common_methods.dart';
import 'package:fanmi/view_models/card_list_model.dart';
import 'package:fanmi/view_models/conversion_list_model.dart';
import 'package:fanmi/view_models/user_model.dart';
import 'package:fanmi/widgets/appbars.dart';
import 'package:fanmi/widgets/svg_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

class RecognizePage extends StatefulWidget {
  final CardInfoEntity card;

  const RecognizePage({
    Key? key,
    required this.card,
  }) : super(key: key);

  @override
  _RecognizePageState createState() => _RecognizePageState();
}

class _RecognizePageState extends State<RecognizePage> {
  FocusNode _focusNode = FocusNode();
  TextEditingController _editingController = TextEditingController();

  //已选择名片
  CardInfoEntity? selectCard;

  //选择名片字体颜色
  Color selectColor = ColorConstants.mi_color;

  //选择名片描述
  String selectText = TextConstants.RECOGNIZE_CARD_TEXT;

  late UserModel userModel;
  late CardListModel cardListModel;
  late ConversionListModel conversionListModel;

  get cardInfo => widget.card;

  get userId => cardInfo.uid.toString();

  get cardList => cardListModel.cardList;

  get userStatus => int.parse(userModel.userStatus);

  get text => _editingController.text;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _editingController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cardListModel = Provider.of<CardListModel>(context);
    userModel = Provider.of<UserModel>(context);
    conversionListModel = Provider.of<ConversionListModel>(context);
    return Scaffold(
      appBar: PopUpAppBar(
        title: "发送申请消息",
        actions: [
          TextButton(
            onPressed: () {
              if (selectCard == null &&
                  userModel.userInfo.wxQrUrl == null &&
                  userModel.userInfo.qqQrUrl == null) {
                showOkAlertDialog(
                    context: context,
                    title: "发送申请消息",
                    message: "你还没上传过二维码哦～可以在「我的-二维码」那里上传，或者添加你创建好的名片吧～");
                return;
              }
              send();
            },
            child: Text(
              "发送",
              style: TextStyle(fontSize: 17.sp, color: Colors.blue),
            ),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.r),
        child: Column(
          children: [
            selectCardBar(),
            Divider(
              height: 0,
              thickness: 0.5,
            ),
            contentTextField(),
          ],
        ),
      ),
    );
  }

  Widget selectCardBar() => Container(
        padding: EdgeInsets.symmetric(vertical: 12.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              child: Row(
                children: [
                  Icon(
                    Icons.web_outlined,
                    color: Colors.black,
                    size: 19.r,
                  ),
                  SizedBox(
                    width: 2.r,
                  ),
                  Text(
                    "选择名片",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 2.r,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12.r)),
                        color: selectColor),
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.r, vertical: 1.5.r),
                    child: Text(
                      selectText,
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: selectColor == ColorConstants.mi_color
                              ? Colors.grey
                              : Colors.white),
                    ),
                  ),
                  selectCard != null
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              selectCard = null;
                              selectColor = ColorConstants.mi_color;
                              selectText = TextConstants.RECOGNIZE_CARD_TEXT;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 3.r),
                            child: Icon(
                              Icons.cancel,
                              color: Colors.grey,
                              size: 18.r,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
              onTap: () async {
                if (cardList.isEmpty) {
                  await showOkAlertDialog(
                      context: context,
                      title: "选择附加名片",
                      message: "你还没有创建过名片哦，点击右侧按钮去创建一个吧～");
                  return;
                }
                //显示可发送名片
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: 40.r * cardList.length + 50.r,
                    width: MediaQuery.of(context).size.width,
                    padding:
                        EdgeInsets.symmetric(vertical: 20.r, horizontal: 10.r),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.r),
                            topRight: Radius.circular(15.r)),
                        color: Colors.white),
                    child: ListView(
                      children: cardList.map<Widget>((v) {
                        CardTypeEnum cardType =
                            CardTypeEnum.getCardType(v.type!);
                        return sheetItem(
                          CardTypeEnum.getCardType(v.type!),
                          () async {
                            setState(() {
                              selectCard = v;
                              selectColor = cardType.color;
                              selectText = "你选择附加${cardType.desc}名片";
                            });
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            Spacer(),
            GestureDetector(
              child: Text(
                "创建/编辑",
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500),
              ),
              onTap: () {
                //显示创建名片列表
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: 270.r,
                    width: MediaQuery.of(context).size.width,
                    padding:
                        EdgeInsets.symmetric(vertical: 20.r, horizontal: 10.r),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.r),
                            topRight: Radius.circular(15.r)),
                        color: Colors.white),
                    child: ListView(
                        children: [
                      CardTypeEnum.LOVE,
                      CardTypeEnum.SKILL,
                      CardTypeEnum.FRIEND,
                      CardTypeEnum.HELP,
                      CardTypeEnum.GROUP
                    ]
                            .map((type) => sheetItem(type, () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushNamed(
                                      AppRouter.CardEditPageRoute,
                                      arguments: type);
                                }))
                            .toList()),
                  ),
                );
              },
            ),
          ],
        ),
      );

  Widget contentTextField() => Container(
        padding: EdgeInsets.symmetric(vertical: 12.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "消息:",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(
              width: 8.r,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 300.r),
              child: TextField(
                maxLength: 500,
                controller: _editingController,
                focusNode: _focusNode,
                minLines: 7,
                maxLines: 15,
                textInputAction: TextInputAction.done,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(5.r),
                  border: OutlineInputBorder(),
                  hintText: TextConstants.RECOGNIZE_HINT,
                  hintStyle: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey),
                  isCollapsed: true,
                ),
              ),
            ),
          ],
        ),
      );

  Widget sheetItem(CardTypeEnum cardType, VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.r),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(
              svgPath: cardType.svgPath,
              width: 26.r,
            ),
            SizedBox(
              width: 10.r,
            ),
            Text(
              cardType.desc,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future send() async {
    if (text == null || text.length == 0) {
      SmartDialog.showToast("你还没有写消息内容哦～");
      return;
    }
    String uName =
        selectCard != null ? selectCard!.name! : userModel.userInfo.name!;
    String uAvatar = selectCard != null
        ? selectCard!.avatarUrl!
        : userModel.userInfo.avatarUrl!;
    String tAvatar = cardInfo.avatarUrl;
    String tName = cardInfo.name;
    String? uWx =
        selectCard != null ? selectCard!.wxQrUrl : userModel.userInfo.wxQrUrl;
    String? uQq =
        selectCard != null ? selectCard!.qqQrUrl : userModel.userInfo.qqQrUrl;
    String? tWx = cardInfo.wxQrUrl;
    String? tQq = cardInfo.qqQrUrl;

    //添加点击事件
    ActionService.addAction(
        cardId: widget.card.id!,
        cardType: widget.card.type!,
        targetUid: widget.card.uid!,
        actionType: ActionTypeEnum.ACTION_RECOGNIZE);

    EasyLoading.show(status: "发送中");
    Future.wait([
      Future(() {
        //设置Relation表关系
        RelationService.addRelation(
          targetUid: cardInfo.uid,
          targetCardId: cardInfo.id,
          targetCardType: cardInfo.type,
          uAvatar: uAvatar,
          uName: uName,
          tAvatar: tAvatar,
          tName: tName,
          uWx: uWx,
          uQq: uQq,
          tWx: tWx,
          tQq: tQq,
          addCardId: selectCard != null ? selectCard!.id : null,
          addCardType: selectCard != null ? selectCard!.type : null,
        );
        //添加RelationMap
        conversionListModel.relationInfoMap[cardInfo.uid.toString()] =
            relationEntityFromJson(RelationEntity(), {
          "target_uid": cardInfo.uid,
          "target_card_id": cardInfo.id,
          "target_card_type": cardInfo.type,
          "u_avatar": uAvatar,
          "u_name": uName,
          "t_avatar": tAvatar,
          "t_name": tName,
          "u_wx": uWx,
          "u_qq": uQq,
          "t_wx": tWx,
          "t_qq": tQq,
          "add_card_id": selectCard != null ? selectCard!.id : null,
          "add_card_type": selectCard != null ? selectCard!.type : null,
          "gender": cardInfo.gender,
          "birth_date": cardInfo.birthDate,
          "city": cardInfo.city,
          "is_applicant": 1,
        });
      }),
      //发送文字消息
      Future(() {
        sendTextMessage(
            userId: userId,
            text: text,
            context: context,
            userStatus: userStatus);
      }),
      //发送名片消息
      Future(() {
        if (selectCard != null) {
          sendCardMessage(
              cardId: selectCard!.id!,
              cardType: selectCard!.type!,
              userId: cardInfo.uid.toString(),
              context: context,
              userStatus: userStatus);
        }
      }),
    ]).whenComplete(() {
      EasyLoading.showSuccess("发送成功");
      Navigator.of(context).pop();
    });
  }
}
