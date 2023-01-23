import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/net/http_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef QrUrlCallBack = Future Function(String? qrUrl);

class QrListTile extends StatefulWidget {
  final String? qrUrl;
  final String qrType;
  final QrUrlCallBack callBack;

  QrListTile(
      {Key? key, this.qrUrl, required this.qrType, required this.callBack})
      : super(key: key);

  @override
  _QrListTileState createState() => _QrListTileState();
}

class _QrListTileState extends State<QrListTile> {
  String? qrUrl;

  @override
  void initState() {
    super.initState();
    qrUrl = widget.qrUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        title: Text(
          '${widget.qrType}二维码',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              qrUrl != null && qrUrl != "" ? "已上传" : "",
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue),
            ),
            SizedBox(
              width: 5.r,
            ),
            Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.grey,
              size: 20.sp,
            ),
          ],
        ),
        onTap: () async {
          var res = await Navigator.of(context).pushNamed(
              AppRouter.QrUploadPageRoute,
              arguments: [widget.qrType, qrUrl]) as String?;
          if (res != null) {
            EasyLoading.show(status: "保存二维码中");
            widget.callBack(res).then((v) {
              setState(() {
                qrUrl = res;
              });
              EasyLoading.showSuccess("修改成功");
            }).onError((error, stackTrace) {
              if (error is DioError) {
                EasyLoading.showError(error.error.message);
              } else {
                EasyLoading.showError("修改二维码失败");
              }
            }).whenComplete(() {
              EasyLoading.dismiss();
            });
          }
        },
      ),
    );
  }
}
