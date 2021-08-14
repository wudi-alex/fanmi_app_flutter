import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class LongTextEditPage extends StatefulWidget {
  final String? initText;
  final String appbarName;
  final int maxLength;

  const LongTextEditPage(
      {Key? key,
      this.initText,
      required this.appbarName,
      required this.maxLength})
      : super(key: key);

  @override
  _LongTextEditPageState createState() => _LongTextEditPageState();
}

class _LongTextEditPageState extends State<LongTextEditPage> {
  FocusNode _focusNode = FocusNode();
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initText??"";
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              longTextField(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() => AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: Text(
          widget.appbarName,
          style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.clear),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) {
                setState(() {});
              }
              if (_controller.text.length == 0) {
                SmartDialog.showToast("内容不能为空");
              } else {
                Navigator.of(context).pop(_controller.text);
              }
            },
            child: Text(
              "完成",
              style: TextStyle(fontSize: 17.sp, color: Colors.blue),
            ),
          )
        ],
      );

  Widget longTextField() => Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20.r,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width-30.r),
              child: TextField(
                maxLength: widget.maxLength,
                controller: _controller,
                focusNode: _focusNode,
                maxLines: 40,
                minLines: 15,
                textInputAction: TextInputAction.newline,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
          ],
        ),
      );
}
