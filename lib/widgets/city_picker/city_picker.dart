import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'city_result.dart';

typedef ResultBlock = void Function(CityResult result);

class CityPickerView extends StatefulWidget {
  // json数据可以从外部传入，如果外部有值，取外部值
  final List? params;

  // 结果返回
  final ResultBlock onResult;

  CityPickerView({
    key,
    required this.onResult,
    required this.params,
  }) : super(key: key);

  @override
  _CityPickerViewState createState() => _CityPickerViewState();
}

class _CityPickerViewState extends State<CityPickerView> {
  List datas = [];
  int provinceIndex = 0;
  int cityIndex = 0;

  late FixedExtentScrollController provinceScrollController;
  late FixedExtentScrollController cityScrollController;

  CityResult result = CityResult();

  bool isShow = false;

  List get provinces {
    if (datas.length > 0) {
      return datas;
    }
    return [];
  }

  List get citys {
    if (provinces.length > 0) {
      return provinces[provinceIndex]['children'] ?? [];
    }
    return [];
  }

  // 保存选择结果
  _saveInfoData() {
    var prs = provinces;
    var cts = citys;
    if (provinceIndex != null && prs.length > 0) {
      result.province = prs[provinceIndex]['label'];
      result.provinceCode = prs[provinceIndex]['value'].toString();
    } else {
      result.province = '';
      result.provinceCode = '';
    }

    if (cityIndex != null && cts.length > 0) {
      result.city = cts[cityIndex]['label'];
      result.cityCode = cts[cityIndex]['value'].toString();
    } else {
      result.city = '';
      result.cityCode = '';
    }
  }

  @override
  void dispose() {
    provinceScrollController.dispose();
    cityScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //初始化控制器
    provinceScrollController = FixedExtentScrollController();
    cityScrollController = FixedExtentScrollController();

    //读取city.json数据
    if (widget.params == null) {
      _loadCitys().then((value) {
        setState(() {
          isShow = true;
        });
        _saveInfoData();
      });
    } else {
      datas = widget.params!;
      assert(datas.length != 0);
      setState(() {
        isShow = true;
      });
      _saveInfoData();
    }
  }

  Future _loadCitys() async {
    var cityStr = await rootBundle.loadString('assets/city.json');
    datas = json.decode(cityStr) as List;
    //result默认取第一组值
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _firstView(),
            _contentView(),
          ],
        ),
      ),
    );
  }

  Widget _firstView() {
    return Container(
      height: 44.r,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              child: Text(
                '取消',
                style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.w400),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            // TextButton(
            //   child: Text(
            //     '清空',
            //     style: TextStyle(fontSize: 16.sp, color: Colors.grey,  fontWeight: FontWeight.w400),
            //   ),
            //   onPressed: () {
            //     widget.onResult(CityResult());
            //     Navigator.pop(context);
            //   },
            // ),
            TextButton(
              child: Text(
                '确定',
                style: TextStyle(fontSize: 16.sp, color: Colors.blue,  fontWeight: FontWeight.w400),
              ),
              onPressed: () {
                if (widget.onResult != null) {
                  widget.onResult(result);
                }
                Navigator.pop(context);
              },
            ),
          ]),
      decoration: BoxDecoration(
        border: Border(
            bottom:
                BorderSide(color: Colors.grey.withOpacity(0.1), width: 1.r)),
      ),
    );
  }

  Widget _contentView() {
    return Container(
      // color: Colors.orange,
      height: 200.r,
      child: isShow
          ? Row(
              children: <Widget>[
                Expanded(child: _provincePickerView()),
                Expanded(child: _cityPickerView()),
                // Expanded(child: _areaPickerView()),
              ],
            )
          : Center(
              child: CupertinoActivityIndicator(
                animating: true,
              ),
            ),
    );
  }

  Widget _provincePickerView() {
    return Container(
      child: CupertinoPicker(
        scrollController: provinceScrollController,
        children: provinces.map((item) {
          return Center(
            child: Text(
              item['label'],
              style: TextStyle(color: Colors.black87, fontSize: 17.sp, fontWeight: FontWeight.w400),
              maxLines: 1,
            ),
          );
        }).toList(),
        onSelectedItemChanged: (index) {
          provinceIndex = index;
          if (cityIndex != null) {
            cityIndex = 0;
            if (cityScrollController.positions.length > 0) {
              cityScrollController.jumpTo(0);
            }
          }
          _saveInfoData();
          setState(() {});
        },
        itemExtent: 36.r,
      ),
    );
  }

  Widget _cityPickerView() {
    return Container(
      child: citys.length == 0
          ? Container()
          : CupertinoPicker(
              scrollController: cityScrollController,
              children: citys.map((item) {
                return Center(
                  child: Text(
                    item['label'],
                    style: TextStyle(color: Colors.black87, fontSize: 17.sp, fontWeight: FontWeight.w400),
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onSelectedItemChanged: (index) {
                cityIndex = index;
                _saveInfoData();
                setState(() {});
              },
              itemExtent: 36.r,
            ),
    );
  }
}

class CustomCityPicker {
  static Future<CityResult> showPicker(BuildContext context, {List? datas}) {
    Completer<CityResult> completer = Completer();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return CityPickerView(
          key: Key('pickerkey'),
          params: datas,
          onResult: (res) {
            completer.complete(res);
          },
        );
      },
    );
    return completer.future;
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? citySelect;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 667),
      builder: () => Scaffold(
        body: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(citySelect ?? '地址'),
            FloatingActionButton(
              onPressed: _example1,
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
          ],
        )),
      ),
    );
  }

  /// 使用默认地址
  void _example1() async {
    final res = await CustomCityPicker.showPicker(context);
    setState(() {
      citySelect = res.city??"未填写";
    });
  }
}
