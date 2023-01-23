import 'package:fanmi/config/text_constants.dart';
import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/view_models/search_list_view_model.dart';
import 'package:fanmi/widgets/svg_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

class SearchBoard extends StatefulWidget {
  @override
  _SearchBoardState createState() => _SearchBoardState();
}

class _SearchBoardState extends State<SearchBoard> {
  //textField
  TextEditingController _textEditingController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  CardTypeEnum cardType = CardTypeEnum.ALL;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SearchListViewModel model = Provider.of<SearchListViewModel>(context);
    CardTypeEnum cardType = model.cardTypeEnum;
    return searchBoard(cardType, model);
  }

  Widget searchBoard(CardTypeEnum cardType, SearchListViewModel model) =>
      Container(
          margin: EdgeInsets.symmetric(vertical: 5.r, horizontal: 12.r),
          padding: EdgeInsets.symmetric(vertical: 5.r, horizontal: 14.r),
          height: 48.r,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(23.0.r)),
            border: Border.all(width: 2.r, color: cardType.color),
          ),
          child: Row(
            children: [
              cardIcon(cardType, model),
              SizedBox(
                width: 10.r,
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 220.r),
                child: TextField(
                  controller: _textEditingController,
                  focusNode: _focusNode,
                  maxLines: 1,
                  textInputAction: TextInputAction.search,
                  style:
                      TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintStyle:
                        TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: TextConstants.SEARCH_HINT_TEXT,
                  ),
                  onChanged: (word) => model.setSearchWord(word),
                  onSubmitted: (word) async {
                    if (word.length == 1) {
                      SmartDialog.showToast("暂时不支持单字搜索哦～");
                    } else {
                      await model.initData();
                    }
                  },
                ),
              ),
              Spacer(),
              searchIcon(model),
            ],
          ));

  Widget searchIcon(SearchListViewModel model) => InkWell(
      child: Icon(
        Icons.search,
        color: Colors.grey,
        size: 30.r,
      ),
      onTap: () async {
        if (model.searchWord != null && model.searchWord!.length == 1) {
          SmartDialog.showToast("暂时不支持单字搜索哦～");
        } else {
          await model.initData();
        }
      });

  Widget cardIcon(CardTypeEnum cardType, SearchListViewModel model) =>
      GestureDetector(
        onTap: () {
          _focusNode.unfocus();
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                    height: 250.r,
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
                        sheetItem(CardTypeEnum.ALL, model),
                        sheetItem(CardTypeEnum.LOVE, model),
                        sheetItem(CardTypeEnum.FRIEND, model),
                        sheetItem(CardTypeEnum.SKILL, model),
                        sheetItem(CardTypeEnum.HELP, model),
                        sheetItem(CardTypeEnum.GROUP, model),
                      ],
                    ),
                  ));
        },
        child: SvgIcon(
          svgPath: cardType.svgPath,
          width: 30.r,
        ),
      );

  Widget sheetItem(CardTypeEnum cardType, SearchListViewModel model) =>
      GestureDetector(
        onTap: () {
          model.setCardType(cardType);
          Navigator.of(context).pop();
        },
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

  Widget customDivider() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 80.r),
        child: Divider(
          height: 0.1,
        ),
      );
}
