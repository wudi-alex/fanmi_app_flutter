import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanmi/config/asset_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonImage extends StatefulWidget {
  final String? imgUrl;
  final VoidCallback? callback;
  final double height;
  final double width;
  final double radius;
  final String? defaultUrl;

  final String errorImageUrl;
  final String placeHolderUrl;

  CommonImage(
      {this.imgUrl,
      this.callback,
      required this.width,
      required this.radius,
      this.defaultUrl,
      this.errorImageUrl = AssetConstants.loading_failure,
      this.placeHolderUrl = AssetConstants.loading,
      required this.height});

  CommonImage.avatar(
      {this.imgUrl, this.callback, required this.height, required this.radius})
      : this.width = height,
        this.defaultUrl = AssetConstants.default_avatar,
        this.errorImageUrl = AssetConstants.default_avatar,
        this.placeHolderUrl = AssetConstants.loading;

  CommonImage.photo(
      {this.imgUrl, this.callback, required this.width, required this.height})
      : this.radius = 5.r,
        this.defaultUrl = AssetConstants.loading,
        this.errorImageUrl = AssetConstants.loading_failure,
        this.placeHolderUrl = AssetConstants.loading;

  @override
  _CommonImageState createState() => _CommonImageState();
}

class _CommonImageState extends State<CommonImage> {
  bool isError = false;

  @override
  Widget build(BuildContext context) {
    bool isNotDefault = widget.imgUrl != null && widget.imgUrl != "";
    Widget image;
    if (isNotDefault) {
      image = CachedNetworkImage(
        imageUrl: widget.imgUrl!,
        imageBuilder: (context, imageProvider) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => insideImage(widget.placeHolderUrl),
        errorWidget: (context, url, error) {
          isError = true;
          return insideImage(widget.errorImageUrl);
        },
      );
    } else {
      image = insideImage(widget.defaultUrl!);
    }

    return widget.callback != null
        ? GestureDetector(
            child: image,
            onTap: widget.callback,
          )
        : OpenContainer(
            closedColor: Colors.transparent,
            openColor: Colors.transparent,
            closedElevation: 0.0,
            transitionType: ContainerTransitionType.fade,
            openElevation: 0.0,
            transitionDuration: const Duration(milliseconds: 100),
            closedBuilder: (context, action) => image,
            openBuilder: (context, action) => !isError
                ? ShowLargeImage(
                    image: isNotDefault
                        ? CachedNetworkImageProvider(widget.imgUrl!)
                        : AssetImage(widget.defaultUrl!) as ImageProvider)
                : ShowLargeImage(image: AssetImage(widget.errorImageUrl)),
          );
  }

  Widget insideImage(String imgUrl) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
        ),
        child: Image.asset(
          imgUrl,
          fit: BoxFit.cover,
        ),
      );
}

class ShowLargeImage extends StatefulWidget {
  ShowLargeImage({required this.image});

  final ImageProvider image;

  @override
  _ShowLargeImageState createState() => _ShowLargeImageState();
}

class _ShowLargeImageState extends State<ShowLargeImage> {
  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) {
              return _bottomSheet(context);
            });
      },
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
              child: Image(
            image: widget.image,
          )),
        ),
      ),
    );
  }

  _bottomSheet(BuildContext context) => Container(
        height: 130.r,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r)),
            color: Colors.white),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            TextButton(
                onPressed: () {
                  _saveImage();
                  Navigator.of(context).pop();
                },
                child: Text(
                  '保存图片',
                  style: TextStyle(fontSize: 20.sp, color: Colors.black),
                )),
            Divider(),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  '取消保存',
                  style: TextStyle(fontSize: 20.sp, color: Colors.black),
                ))
          ],
        ),
      );

  _saveImage() async {
    await _permission((hasPermission) async {
      if (hasPermission) {
        // SmartDialog.showLoading(msg: '存储中');
        ui.Image img = await _loadImageByProvider(widget.image);
        ByteData? byteData = await img.toByteData(
          format: ui.ImageByteFormat.png,
        );
        final result = await ImageGallerySaver.saveImage(
          byteData!.buffer.asUint8List(),
        );
        SmartDialog.dismiss();
        if (result['isSuccess'] == true) {
          SmartDialog.showToast('存储成功');
        } else {
          SmartDialog.showToast('存储失败');
        }
      } else {
        SmartDialog.showToast('没有权限');
      }
    });
  }

  _permission(callback(bool hasPermission)) async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        callback(true);
      } else {
        callback(false);
      }
    } else {
      if (await Permission.storage.request().isGranted) {
        callback(true);
      } else {
        callback(false);
      }
    }
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
  }

  Future<ui.Image> _loadImageByProvider(
    ImageProvider provider, {
    ImageConfiguration config = ImageConfiguration.empty,
  }) async {
    Completer<ui.Image> completer = Completer<ui.Image>();
    late ImageStreamListener listener;
    ImageStream stream = provider.resolve(config);
    listener = ImageStreamListener((ImageInfo frame, bool sync) {
      final ui.Image image = frame.image;
      completer.complete(image);
      stream.removeListener(listener);
    });
    stream.addListener(listener); //添加监听
    return completer.future; //返回
  }
}
