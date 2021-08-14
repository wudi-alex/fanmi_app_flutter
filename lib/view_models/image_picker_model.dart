import 'package:fanmi/net/common_service.dart';
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
    var isSuccess = true;
    var res = await Future.wait(
        List.generate(assets.length, (index) => upLoadImg(assets[index])));
    for (bool e in res) {
      isSuccess = isSuccess && e;
    }
    return isSuccess;
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
    try {
      var resp = await storage.putFile(file!, tokenMap["token"],
          options: PutOptions(controller: putController, key: key));
      print("上传成功，resp:${resp.key}");
      if (isOnePic) {
        imgUrls.clear();
      }
      imgUrls.add(urlHead + resp.key!);
      return true;
    } catch (error) {
      if (error is StorageError) {
        switch (error.type) {
          case StorageErrorType.CONNECT_TIMEOUT:
            print('发生错误: 连接超时');
            break;
          case StorageErrorType.SEND_TIMEOUT:
            print('发生错误: 发送数据超时');
            break;
          case StorageErrorType.RECEIVE_TIMEOUT:
            print('发生错误: 响应数据超时');
            break;
          case StorageErrorType.RESPONSE:
            print('发生错误: ${error.message}');
            break;
          case StorageErrorType.CANCEL:
            print('发生错误: 请求取消');
            break;
          case StorageErrorType.UNKNOWN:
            print('发生错误: 未知错误');
            break;
          case StorageErrorType.NO_AVAILABLE_HOST:
            print('发生错误: 无可用 Host');
            break;
          case StorageErrorType.IN_PROGRESS:
            print('发生错误: 已在队列中');
            break;
        }
      } else {
        print('发生错误: ${error.toString()}');
      }
      return false;
    }
  }
}
