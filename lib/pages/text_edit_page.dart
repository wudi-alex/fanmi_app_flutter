import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class TextEditPage extends StatefulWidget {
  final String? initText;
  final String appbarName;
  final int maxLength;

  const TextEditPage(
      {Key? key,
      required this.initText,
      required this.maxLength,
      required this.appbarName})
      : super(key: key);

  @override
  _TextEditPageState createState() => _TextEditPageState();
}

class _TextEditPageState extends State<TextEditPage> {
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
      body: Container(
        child: Column(
          children: [
            textField(),
          ],
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

  Widget textField() => Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20.r,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 300.r),
              child: TextField(
                maxLength: widget.maxLength,
                controller: _controller,
                focusNode: _focusNode,
                maxLines: 1,
                textInputAction: TextInputAction.done,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  counterText: "",
                ),
              ),
            ),
          ],
        ),
      );
}
