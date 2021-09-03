import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:fanmi/config/app_router.dart';
import 'package:fanmi/config/asset_constants.dart';
import 'package:fanmi/config/text_constants.dart';
import 'package:fanmi/entity/card_info_entity.dart';
import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/utils/storage_manager.dart';
import 'package:fanmi/widgets/common_image.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCardBar extends StatefulWidget {
  final CardInfoEntity data;
  final Widget body;
  final VoidCallback? callback;

  const CustomCardBar(
      {Key? key, required this.data, required this.body, this.callback})
      : super(key: key);

  @override
  _CustomCardBarState createState() => _CustomCardBarState();
}

class _CustomCardBarState extends State<CustomCardBar>
    with SingleTickerProviderStateMixin {
  List<Color> _backButtonColors = [Colors.white, Colors.black];
  double _height = 350.r;
  double _appBarHeight = 40.r;
  double _avatarHeight = 70.r;

  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animatable<Color?> _animatedBackButtonColors;

  double _scale = 0.0;

  //gets
  get _body => widget.body;

  get _coverUrl => widget.data.coverUrl;

  get _avatarUrl => widget.data.avatarUrl;

  get _name => widget.data.name;

  get _sign => widget.data.sign ?? TextConstants.DEFAULT_CARD_SIGN;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_scrollController.hasClients) {
      _scale = _scrollController.offset / (_height - _appBarHeight);
      if (_scale > 1) {
        _scale = 1.0;
      }
    }
    _animationController.value = _scale;
    _scale = 1.0 - _scale;

    _animatedBackButtonColors = TweenSequence<Color?>([
      TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: _backButtonColors[0],
            end: _backButtonColors[1],
          ))
    ]);

    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          ExtendedSliverAppbar(
            toolBarColor: Colors.white,
            title: Text(
              _name,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500),
            ),
            leading: BackButton(
              color: _animatedBackButtonColors
                  .evaluate(AlwaysStoppedAnimation(_animationController.value)),
            ),
            background: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CachedNetworkImage(
                      height: _height - 20.r,
                      width: MediaQuery.of(context).size.width,
                      imageUrl: _coverUrl,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 27.r, right: 17.r),
                      child: Text(
                        _sign,
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
                Positioned(
                    top: 280.r,
                    right: 17.r,
                    child: Container(
                      child: Row(
                        children: [
                          Text(
                            _name,
                            style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(
                            width: 10.r,
                          ),
                          CommonImage(
                            imgUrl: _avatarUrl,
                            width: _avatarHeight,
                            height: _avatarHeight,
                            defaultUrl: AssetConstants.default_avatar,
                            errorImageUrl: AssetConstants.default_avatar,
                            placeHolderUrl: AssetConstants.default_avatar,
                            radius: 5.r,
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            actions: Padding(
              padding: EdgeInsets.all(10.0.r),
              child: GestureDetector(
                onTap: actionCallback,
                child: Icon(
                  Icons.more_horiz,
                  color: _animatedBackButtonColors.evaluate(
                      AlwaysStoppedAnimation(_animationController.value)),
                ),
              ),
            ),
          ),
        ];
      },
      body: _body,
    );
  }

  actionCallback() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
              height: 70.r,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r)),
                  color: Colors.white),
              child: widget.data.uid == StorageManager.uid
                  ? GestureDetector(
                      child: Center(
                        child: Text(
                          "编辑",
                          style: TextStyle(
                              fontSize: 20.sp, fontWeight: FontWeight.w500),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            AppRouter.CardEditPageRoute,
                            arguments:
                                CardTypeEnum.getCardType(widget.data.type!));
                      },
                    )
                  : GestureDetector(
                      child: Center(
                        child: Text(
                          "举报",
                          style: TextStyle(
                              fontSize: 20.sp, fontWeight: FontWeight.w500),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            AppRouter.ReportMailPageRoute,
                            arguments: widget.data);
                      },
                    ));
        });
  }
}
