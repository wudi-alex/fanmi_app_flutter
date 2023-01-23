import 'package:fanmi/net/common_service.dart';
import 'package:fanmi/net/status_code.dart';
import 'package:fanmi/view_models/view_state_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ImagePickerModel extends ViewStateModel {
  List<String> imgUrls = [];
  List<AssetEntity> assets = [];

  final Storage storage = Storage();

  int maxAssetsCount;

  get isOnePic => maxAssetsCount == 1;

  get limitCount => maxAssetsCount - imgUrls.length - assets.length;

  ImagePickerModel({
    required this.maxAssetsCount,
    required this.imgUrls,
  });

  Future loadAssets(BuildContext context) async {
    assets = await AssetPicker.pickAssets(
          context,
          pageSize: 400,
          maxAssets: isOnePic ? 1 : limitCount,
          selectedAssets: assets,
          themeColor: Colors.blue,
          requestType: RequestType.image,
          previewThumbSize: const <int>[500, 800],
          gridThumbSize: 400,
        ) ??
        [];
    notifyListeners();
  }

  Future uploadImgList() async {
    bool isImgSuccess = true;
    var res = await Future.wait(
        List.generate(assets.length, (index) => upLoadImg(assets[index])));
    for (bool e in res) {
      isImgSuccess = isImgSuccess && e;
    }
    return isImgSuccess;
  }

  void removeAsset({required int index}) {
    assets.removeAt(index);
    notifyListeners();
  }

  void removeUrl({required int index}) {
    imgUrls.removeAt(index);
    notifyListeners();
  }

  Future upLoadImg(AssetEntity? asset) async {
    if (asset == null) {
      return true;
    }
    var tokenMap = await CommonService.getQiniuToken();
    var key = tokenMap["key"];
    String urlHead = tokenMap["url_head"];
    PutController putController = PutController();
    var file = await asset.originFile;
    var resp = await storage.putFile(file!, tokenMap["token"],
        options: PutOptions(controller: putController, key: key));
    print("上传成功，resp:${resp.key}");
    if (isOnePic) {
      imgUrls.clear();
    }
    var imgUrl = urlHead + resp.key!;
    var verifyResp = await CommonService.verifyImg(imgUrl: imgUrl);
    if (verifyResp.statusCode == StatusCode.SUCCESS) {
      imgUrls.add(imgUrl);
      return true;
    }
  }
}
