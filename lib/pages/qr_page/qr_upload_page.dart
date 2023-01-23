import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fanmi/config/asset_constants.dart';
import 'package:fanmi/config/color_constants.dart';
import 'package:fanmi/enums/qr_type_enum.dart';
import 'package:fanmi/view_models/image_picker_model.dart';
import 'package:fanmi/view_models/qr_upload_viewmodel.dart';
import 'package:fanmi/widgets/provider_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../widgets/common_image.dart';

class QrUploadPage extends StatelessWidget {
  final String qrType;
  final String? qrUrl;

  const QrUploadPage({Key? key, required this.qrType, this.qrUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderWidget2(
      model1: QrUploadViewModel(qrType: qrType, qrUrl: qrUrl),
      model2: ImagePickerModel(
          maxAssetsCount: 1, imgUrls: qrUrl != null ? [qrUrl!] : []),
      builder: (context, model1, model2, child) {
        return ProviderWidget2(
          model1: QrUploadViewModel(qrUrl: qrUrl, qrType: qrType),
          model2: ImagePickerModel(
              maxAssetsCount: 1, imgUrls: qrUrl != null ? [qrUrl!] : []),
          builder: (context, QrUploadViewModel model1, ImagePickerModel model2,
              child) {
            return Scaffold(
                appBar: appBar(model1, model2, context),
                body: Container(
                  color: Colors.white,
                  child: ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.r, horizontal: 20.r),
                        child: Text(
                          desc,
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.r, horizontal: 20.r),
                        child: qrImage(model1, model2, context),
                      ),
                    ],
                  ),
                ));
          },
        );
      },
    );
  }

  PreferredSizeWidget appBar(QrUploadViewModel model1, ImagePickerModel model2,
          BuildContext context) =>
      AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: Text(
          "上传$qrType二维码",
          style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500),
        ),
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (model2.assets.length != 0) {
                EasyLoading.show(status: "二维码上传中");
                var isSuccess = await model2.uploadImgList();
                if (isSuccess) {
                  var canUp = await model1.uploadQr(model2.imgUrls[0]);
                  if (canUp) {
                    EasyLoading.showSuccess("上传成功");
                    EasyLoading.dismiss();
                    Navigator.of(context).pop(model1.qrUrl);
                  } else {
                    EasyLoading.showError("请上传正确的$qrType二维码");
                  }
                } else {
                  EasyLoading.showError("上传失败，请稍后再试");
                }
                EasyLoading.dismiss();
              } else if (model2.assets.length == 0) {
                if (model1.qrUrl != null) {
                  SmartDialog.showToast('这个二维码已经上传过了哦～');
                  return;
                } else if (!model1.isDelete) {
                  SmartDialog.showToast('还没有选择二维码呢～');
                  return;
                } else {
                  final res = await showOkCancelAlertDialog(
                    context: context,
                    title: "删除二维码",
                    message: "是否删除该名片已上传的$qrType二维码？",
                    okLabel: "删除",
                    cancelLabel: "取消",
                  );
                  if (res == OkCancelResult.ok) {
                    EasyLoading.show(status: "删除中");
                    Future.delayed(Duration(milliseconds: 10), () {
                      EasyLoading.showSuccess("删除成功");
                      EasyLoading.dismiss();
                      return;
                    });
                  } else {
                    return;
                  }
                }
              }
            },
            child: Text(
              "上传",
              style: TextStyle(fontSize: 17.sp, color: Colors.blue),
            ),
          )
        ],
      );

  Widget qrImage(
      QrUploadViewModel model1, ImagePickerModel model2, BuildContext context) {
    if (model2.assets.length != 0) {
      var asset = model2.assets[0];
      Widget toUpLoadImg = Image(
        image: AssetEntityImageProvider(asset, isOriginal: true),
        fit: BoxFit.cover,
        width: 250.r,
        height: 450.r,
      );
      return _selectedAssetWidget(toUpLoadImg, () {
        model2.removeAsset(index: 0);
      });
    } else if (model1.qrUrl != null) {
      Widget uploadedImg = CommonImage(
        imgUrl: model1.qrUrl,
        callback: () {},
        radius: 8.r,
        width: 250.r,
        height: 450.r,
        defaultUrl: AssetConstants.loading_failure,
        errorImageUrl: AssetConstants.loading_failure,
        placeHolderUrl: AssetConstants.loading,
      );
      return _selectedAssetWidget(uploadedImg, () {
        model1.removeImgUploaded();
      });
    }
    return GestureDetector(
      onTap: () {
        model2.loadAssets(context);
      },
      child: Container(
        width: 250.r,
        height: 450.r,
        decoration: BoxDecoration(
          color: ColorConstants.mi_color,
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
        ),
        child: Icon(
          Icons.add_sharp,
          color: Colors.grey,
          size: 38.r,
        ),
      ),
    );
  }

  Widget _selectedAssetWidget(Widget img, VoidCallback callback) {
    return Container(
      width: 250.r,
      height: 450.r,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0.r),
                child: img,
              ),
            ),
          ),
          Positioned(
            top: 6.0.r,
            right: 6.0.r,
            child: GestureDetector(
              onTap: callback,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0.r),
                  color: Colors.grey.withOpacity(0.5),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 18.0.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  get desc {
    switch (qrType) {
      case QrTypeEnum.WEIXIN:
        return '1. 点击微信「我」页面上方的头像框\n2. 点击进入「我的二维码」页面\n3. 点击右上角选择「保存图片」选项，或者手机截屏保存到相册\n4. 点击下方按钮从相册上传凡觅';
      case QrTypeEnum.QQ:
        return '1. 点击QQ左上角头像框进入设置页面\n2. 点击右上角二维码标识进入二维码页面\n3. 点击左下角「分享」选项后选择「保存到手机」，或者手机截屏保存到相册\n4. 点击下方按钮从相册上传凡觅';
      case QrTypeEnum.WEIXIN_GROUP:
        return '(微信群二维码限制有效期7天，请及时更新哦)\n1. 点击微信群聊天页面右上角进入设置页面\n2. 点击「群二维码」选项进入二维码页面\n3. 点击右上角选择「保存图片」选项，或者手机截屏保存到相册\n4. 点击下方按钮从相册上传凡觅';
      case QrTypeEnum.QQ_GROUP:
        return '1. 点击QQ群聊天页面右上角进入设置页面\n2. 点击「群号和二维码」选项进入二维码页面\n3. 点击「保存」选项，或者手机截屏保存到相册\n4. 点击下方按钮从相册上传凡觅';
    }
  }
}
