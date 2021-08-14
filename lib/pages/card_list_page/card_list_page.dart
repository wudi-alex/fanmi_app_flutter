import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/widgets/appbars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'card_list_board.dart';

class CardListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(title: "名片"),
      body: Container(
        child: ListView(
          children: [
            CardListBoard(
                type: CardTypeEnum.LOVE, upColor: Colors.purpleAccent),
            CardListBoard(
                type: CardTypeEnum.SKILL, upColor: Colors.lightBlueAccent),
            CardListBoard(
                type: CardTypeEnum.FRIEND, upColor: Colors.greenAccent),
            CardListBoard(type: CardTypeEnum.HELP, upColor: Colors.yellow),
            CardListBoard(
                type: CardTypeEnum.GROUP, upColor: Colors.greenAccent),
          ],
        ),
      ),
    );
  }
}
