
import 'package:fanmi/view_models/message_list_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MessageListPage extends StatefulWidget {
  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  @override
  Widget build(BuildContext context) {
    MessageListModel messageListModel = Provider.of<MessageListModel>(context);
    return SmartRefresher(
      enablePullUp: true,
      enablePullDown: false,
      controller: RefreshController(),
    );
  }
}
