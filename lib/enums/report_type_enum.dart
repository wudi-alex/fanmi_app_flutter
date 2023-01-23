class ReportTypeEnum {
  final String desc;
  final int value;

  const ReportTypeEnum(this.desc, this.value);

  static const ReportTypeEnum EROTICA = ReportTypeEnum("色情低俗", 0);
  static const ReportTypeEnum ADS = ReportTypeEnum("垃圾广告", 1);
  static const ReportTypeEnum ATTACK = ReportTypeEnum("辱骂攻击", 2);
  static const ReportTypeEnum ILLEGAL = ReportTypeEnum("涉嫌违法犯罪", 3);
  static const ReportTypeEnum TEEN = ReportTypeEnum("涉未成年的不良信息", 4);
  static const ReportTypeEnum FAKE = ReportTypeEnum("描述与实际严重不符", 5);
  static const ReportTypeEnum OTHER = ReportTypeEnum("其他违规行为", 6);
}
