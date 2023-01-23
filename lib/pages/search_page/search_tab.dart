import 'package:fanmi/enums/gender_type_enum.dart';
import 'package:fanmi/enums/search_enum.dart';
import 'package:fanmi/view_models/search_list_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab>
    with AutomaticKeepAliveClientMixin {
  int rankTypeSelectedIndex = 0;
  int genderTypeSelectedIndex = 0;
  List<String> rankTypeList = ['智能排序', '同城优先', '在线优先'];
  List<String> genderTypeList = ['不限性别', '只看男生', '只看女生'];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var model = Provider.of<SearchListViewModel>(context);
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          tabItem(true, model, context),
          tabItem(false, model, context),
        ],
      ),
    );
  }

  Widget tabItem(
          bool isRankType, SearchListViewModel model, BuildContext context) =>
      InkWell(
          child: Container(
            width: 100.r,
            padding: EdgeInsets.symmetric(vertical: 5.r),
            child: Center(
              child: Text(
                isRankType
                    ? rankTypeList[rankTypeSelectedIndex]
                    : genderTypeList[genderTypeSelectedIndex],
                style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          onTap: () {
            showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                      height: 170.r,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(
                          vertical: 20.r, horizontal: 10.r),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.r),
                              topRight: Radius.circular(15.r)),
                          color: Colors.white),
                      child: ListView(
                          children: isRankType
                              ? mapIndexed(
                                  rankTypeList,
                                  (index, desc) => selectItem(
                                      model,
                                      desc as String,
                                      index,
                                      isRankType,
                                      context)).toList()
                              : mapIndexed(
                                  genderTypeList,
                                  (index, desc) => selectItem(
                                      model,
                                      desc as String,
                                      index,
                                      isRankType,
                                      context)).toList()),
                    ));
          });

  Widget selectItem(SearchListViewModel model, String desc, int index,
      bool isRankType, BuildContext context) {
    bool isSelected = isRankType
        ? index == rankTypeSelectedIndex
        : index == genderTypeSelectedIndex;
    return GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.r, horizontal: 10.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                desc,
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.blue : Colors.black),
              ),
              SizedBox(
                width: 10.r,
              ),
              isSelected
                  ? Icon(
                      Icons.done,
                      color: Colors.blue,
                      size: 20.r,
                    )
                  : SizedBox(
                      width: 20.r,
                    ),
            ],
          ),
        ),
        onTap: () {
          if (isRankType) {
            setState(() {
              rankTypeSelectedIndex = index;
            });
            switch (index) {
              case 0:
                model.setRankType(SearchRankTypeEnum.DEFAULT);
                break;
              case 1:
                model.setRankType(SearchRankTypeEnum.SAME_CITY_PREFER);
                break;
              case 2:
                model.setRankType(SearchRankTypeEnum.ONLINE_PREFER);
                break;
            }
          } else {
            setState(() {
              genderTypeSelectedIndex = index;
            });
            switch (index) {
              case 0:
                model.setGenderFilter(null);
                break;
              case 1:
                model.setGenderFilter(GenderTypeEnum.Male.value);
                break;
              case 2:
                model.setGenderFilter(GenderTypeEnum.Female.value);
                break;
            }
          }
          Navigator.of(context).pop();
        });
  }

  @override
  bool get wantKeepAlive => true;
}

Iterable<E> mapIndexed<E, T>(
    Iterable<T> items, E Function(int index, T item) f) sync* {
  var index = 0;

  for (final item in items) {
    yield f(index, item);
    index = index + 1;
  }
}
