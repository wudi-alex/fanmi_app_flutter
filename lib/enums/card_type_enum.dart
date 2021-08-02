import 'package:flutter/material.dart';

class CardTypeEnum {
  final String desc;
  final String svgPath;
  final String backgroundPath;
  final Color color;
  final String info;
  final int value;
  final String coverUrl;

  const CardTypeEnum(this.desc, this.svgPath, this.color, this.info, this.value,
      this.backgroundPath, this.coverUrl);

  static const CardTypeEnum LOVE = CardTypeEnum(
    "恋爱",
    "assets/svg/love.svg",
    Colors.pinkAccent,
    "描述自己的魅力和理想型，当遇到想认识的对象时可以对他or她进行展示哦",
    1,
    "assets/images/love_background.png",
    "https://cdn.fanminet.com/love_cover.png",
  );

  static const CardTypeEnum FRIEND = CardTypeEnum(
    "交友",
    "assets/svg/clover_leaf.svg",
    Colors.green,
    "想要找有相同兴趣或者志同道合的朋友，总之创建个交友名片肯定没错啦",
    2,
    "assets/images/friend_background.png",
    "https://cdn.fanminet.com/friend_cover.png",
  );

  static const CardTypeEnum SKILL = CardTypeEnum(
    "技能",
    "assets/svg/cert.svg",
    Colors.blue,
    "描述自己的职业或者技能，同行大佬交流或者帮助小白，你就是最棒的！",
    3,
    "assets/images/skill_background.png",
    "https://cdn.fanminet.com/skill_cover.png",
  );

  static const CardTypeEnum HELP = CardTypeEnum(
    "求助",
    "assets/svg/help.svg",
    Colors.orange,
    "遇到自己不能解决需要求助他人的问题，不如在这里描述一下，说不定有贵人相助哦",
    4,
    "assets/images/help_background.png",
    "https://cdn.fanminet.com/help_cover.png",
  );

  static const CardTypeEnum GROUP = CardTypeEnum(
    "群组",
    "assets/svg/group.svg",
    Colors.purple,
    "大群小群大小群，招募群友，那就创建群组名片！",
    5,
    "assets/images/group_background.png",
    "https://cdn.fanminet.com/group_cover.png",
  );

  static const CardTypeEnum ALL =
      CardTypeEnum("不限", "assets/svg/rainbow.svg", Colors.cyan, "", 0, "", "");

  static CardTypeEnum getCardType(int value) {
    switch (value) {
      case 1:
        return LOVE;
      case 2:
        return FRIEND;
      case 3:
        return SKILL;
      case 4:
        return HELP;
      case 5:
        return GROUP;
      case 0:
        return ALL;
      default:
        return ALL;
    }
  }
}
