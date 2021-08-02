String messageItemTime(int msgTimestamp) {
  var date = DateTime.fromMillisecondsSinceEpoch(msgTimestamp*1000);
  var now = DateTime.now();
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return date.hour <= 12
        ? "上午${date.hour}:${date.minute}"
        : "下午${date.hour - 12}:${date.minute}";
  }
  return date.hour <= 12
      ? "${date.year}年${date.month}月${date.day}日 上午${date.hour}:${date.minute}"
      : "${date.year}年${date.month}月${date.day}日 下午${date.hour - 12}:${date.minute}";
}

String customTime(String inputDate) {
  DateTime now = DateTime.now();
  DateTime time = DateTime.parse(inputDate);
  Duration duration = now.difference(time);
  if (duration.inMinutes < 60) {
    return "${duration.inMinutes}分钟前";
  } else if (duration.inHours < 24) {
    return "${duration.inHours}小时前";
  } else if (duration.inDays < 31) {
    return "${duration.inDays}天前";
  } else if (duration.inDays >= 31 && duration.inDays < 90) {
    return "一个月前";
  }
  return "三个月前";
}

int getAge(String? inputDate) {
  if (inputDate == null || inputDate == "") {
    return 0;
  }
  DateTime now = DateTime.now();
  DateTime time = DateTime.parse(inputDate);
  return now.year - time.year;
}
