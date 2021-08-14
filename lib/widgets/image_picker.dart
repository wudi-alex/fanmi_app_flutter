import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanmi/config/asset_constants.dart';
import 'package:fanmi/config/color_constants.dart';
import 'package:fanmi/view_models/image_picker_model.dart';
import 'package:fanmi/widgets/common_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AlbumPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = Provider.of<ImagePickerModel>(context);
    var list = List.generate(
            model.imgUrls.length, (index) => uploadedImg(index, model)) +
        List.generate(model.assets.length, (index) => assetImg(index, model));
    if (list.length < model.maxAssetsCount) {
      list.add(_addIcon(() {
        model.loadAssets(context);
      }));
    }
    return GridView.count(
      controller: ScrollController(),
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: list,
      shrinkWrap: true,
    );
  }

  Widget uploadedImg(int index, ImagePickerModel model) {
    var img = CommonImage(
      imgUrl: model.imgUrls[index],
      callback: () {},
      radius: 8.r,
      width: 100.r,
      height: 100.r,
      defaultUrl: AssetConstants.loading_failure,
      errorImageUrl: AssetConstants.loading_failure,
      placeHolderUrl: AssetConstants.loading,
    );
    return Padding(
      padding: EdgeInsets.all(5.r),
      child: _selectedAssetWidget(img, () {
        model.removeUrl(index: index);
      }),
    );
  }

  Widget assetImg(int index, ImagePickerModel model) {
    var asset = model.assets[index];
    var img = Image(
      image: AssetEntityImageProvider(asset, isOriginal: true),
      width: 100.r,
      height: 100.r,
      fit: BoxFit.cover,
    );
    return Padding(
        padding: EdgeInsets.all(5.r),
        child: _selectedAssetWidget(img, () {
          model.removeAsset(index: index);
        }));
  }

  Widget _selectedAssetWidget(Widget thumb, VoidCallback callback) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0.r),
              child: thumb,
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
    );
  }

  Widget _addIcon(VoidCallback callback) => Padding(
        padding: EdgeInsets.all(5.0.r),
        child: GestureDetector(
          onTap: callback,
          child: Container(
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
        ),
      );
}

class ImagePicker extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final double height;
  final double width;
  final double rectRadius;

  const ImagePicker(
      {Key? key,
      required this.icon,
      required this.iconSize,
      required this.height,
      required this.width,
      required this.rectRadius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<ImagePickerModel>(context);
    var img = model.assets.length > 0
        ? assetImg(model)
        : CachedNetworkImage(
            imageUrl: model.imgUrls[0],
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(rectRadius)),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(child: img),
          Positioned(
            left: (width - iconSize) / 2,
            top: (height - iconSize) / 2,
            child: GestureDetector(
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.blue.withOpacity(0.5),
                  size: iconSize,
                ),
              ),
              onTap: () {
                model.loadAssets(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget assetImg(ImagePickerModel model) {
    var asset = model.assets[0];
    return Container(
      width: 100.r,
      height: 100.r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(rectRadius)),
        image: DecorationImage(
          image: AssetEntityImageProvider(asset, isOriginal: true),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
