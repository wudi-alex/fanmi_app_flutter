import 'package:fanmi/entity/card_info_entity.dart';
import 'package:fanmi/enums/action_type_enum.dart';
import 'package:fanmi/enums/report_type_enum.dart';
import 'package:fanmi/net/action_service.dart';
import 'package:fanmi/net/card_service.dart';
import 'package:fanmi/net/status_code.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/view_models/image_picker_model.dart';
import 'package:fanmi/widgets/image_picker.dart';
import 'package:fanmi/widgets/provider_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class CardReportPage extends StatefulWidget {
  final CardInfoEntity card;

  const CardReportPage({Key? key, required this.card}) : super(key: key);

  @override
  _CardReportPageState createState() => _CardReportPageState();
}

class _CardReportPageState extends State<CardReportPage> {
  ReportTypeEnum? reportType;

  FocusNode _focusNode = FocusNode();
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget(
      model: ImagePickerModel(imgUrls: [], maxAssetsCount: 9),
      builder: (BuildContext context, ImagePickerModel model, Widget? child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: 0.5,
            backgroundColor: Colors.white,
            title: Text(
              "发送举报",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500),
            ),
            leading: IconButton(
              color: Colors.black,
              icon: Icon(Icons.clear),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (mounted) {
                    setState(() {});
                  }
                  if (reportType == null) {
                    SmartDialog.showToast("还没有选择举报类型哦～");
                    return;
                  }
                  EasyLoading.show(status: "发送中");
                  //添加点击事件
                  ActionService.addAction(
                      cardId: widget.card.id!,
                      cardType: widget.card.type!,
                      targetUid: widget.card.uid!,
                      actionType: ActionTypeEnum.ACTION_REPORT);
                  model.uploadImgList().then((v) async {
                    var resp = await CardService.reportCard(
                        cardId: widget.card.id!,
                        reportDict: {
                          "reporter": StorageManager.uid,
                          "reported_uid": widget.card.uid!,
                          "reported_card_id": widget.card.id!,
                          "report_type": reportType!.value,
                          "content": _controller.text,
                          "imgs": model.imgUrls.join(";"),
                        });
                    if (resp.statusCode == StatusCode.SUCCESS) {
                      EasyLoading.showSuccess("发送成功");
                      Navigator.of(context).pop();
                    }
                  }).onError((error, stackTrace) {
                    EasyLoading.showError("发送举报失败，请稍后再试哦～");
                  });
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
                Container(
                  height: 10.r,
                ),
                Wrap(
                  children: [
                    reportSpan(ReportTypeEnum.EROTICA),
                    reportSpan(ReportTypeEnum.ADS),
                    reportSpan(ReportTypeEnum.ATTACK),
                    reportSpan(ReportTypeEnum.ILLEGAL),
                    reportSpan(ReportTypeEnum.TEEN),
                    reportSpan(ReportTypeEnum.FAKE),
                    reportSpan(ReportTypeEnum.OTHER),
                  ],
                ),
                contentTextField(),
                AlbumPicker(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget contentTextField() => Container(
        padding: EdgeInsets.symmetric(vertical: 12.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "内容:",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(
              width: 8.r,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 300.r),
              child: TextField(
                maxLength: 500,
                controller: _controller,
                focusNode: _focusNode,
                minLines: 7,
                maxLines: 15,
                textInputAction: TextInputAction.done,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: "请描述您需要举报该名片/用户的具体信息（可附加图片）",
                  contentPadding: EdgeInsets.all(5.r),
                  border: OutlineInputBorder(),
                  isCollapsed: true,
                ),
              ),
            ),
          ],
        ),
      );

  Widget reportSpan(
    ReportTypeEnum type,
  ) {
    bool isSelected = reportType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          reportType = type;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.r, vertical: 2.r),
        padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(13.r)),
            border: Border.all(
                width: 1.r, color: isSelected ? Colors.blue : Colors.grey),
            color: Colors.white),
        child: Text(
          type.desc,
          style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
