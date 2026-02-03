import 'package:flutter/material.dart';

// 전문가 칼럼 데이터 모델
class ColumnData {
  final String id;
  final String title;
  final String author;
  final String date;
  final IconData icon;
  final String content;

  const ColumnData({
    required this.id,
    required this.title,
    required this.author,
    required this.date,
    required this.icon,
    required this.content,
  });
}

// 전문가 칼럼 더미 데이터
class ColumnRepository {
  static const List<ColumnData> columns = [
    ColumnData(
      id: 'column_001',
      title: "특약사항에 '이 문구' 없으면 보증금 날립니다",
      author: '박성훈 변호사',
      date: '2026.01.20',
      icon: Icons.gavel,
      content: '''전세 계약 시 특약사항에 반드시 기재해야 할 핵심 문구를 알려드립니다.

1. "본 계약의 잔금은 확정일자를 받은 후 지급한다"
→ 이 문구가 없으면 잔금을 먼저 주고 확정일자를 못 받는 경우가 발생할 수 있습니다.

2. "임대인은 보증금 반환 시까지 근저당권 설정을 금지한다"
→ 계약 후 추가로 근저당을 설정하여 전세금이 위험해지는 것을 방지합니다.

3. "임대인의 체납 세금이 있을 시 계약을 해지할 수 있다"
→ 나중에 발견되는 체납으로 인한 피해를 예방할 수 있습니다.

이 세 가지 문구는 변호사로서 강력히 권장하는 필수 특약사항입니다.
계약서에 반드시 기재하시고, 임대인과 중개업소의 날인을 받으세요.

특약사항은 계약서의 가장 중요한 부분이며, 나중에 분쟁 발생 시 법적 근거가 됩니다.
중개업소에서 "관례상 안 쓴다"고 하더라도, 반드시 요구하시기 바랍니다.''',
    ),
    ColumnData(
      id: 'column_002',
      title: 'HUG 보증보험, 거절되는 집의 3가지 특징',
      author: '최지수 법무사',
      date: '2026.01.18',
      icon: Icons.shield_outlined,
      content: '''HUG(주택도시보증공사) 전세보증보험 가입이 거절되는 경우가 있습니다.

1. 전세가율이 매우 높은 경우 (매매가 대비 80% 이상)
→ 깡통전세 위험이 높아 보험사에서 가입을 거부합니다.

2. 근저당권 설정액이 과도한 경우
→ 선순위 채권이 많으면 보증금 회수가 어려워 거절됩니다.

3. 임대인이 세금 체납 중인 경우
→ 국세, 지방세 체납 이력이 있으면 위험 신호입니다.

보증보험 가입이 거절된 집은 위험 신호이므로, 계약을 재고하시는 것이 안전합니다.
보증지킴이 앱으로 사전에 진단받으시면 이런 위험을 미리 확인하실 수 있습니다.

특히 2030 사회초년생의 경우, HUG 보증보험은 거의 필수입니다.
가입이 안 되는 집이라면 다른 집을 알아보시는 것을 강력히 권장합니다.''',
    ),
    ColumnData(
      id: 'column_003',
      title: "등기부등본 '을구'에서 꼭 봐야 할 권리 관계",
      author: '김건희 대표',
      date: '2026.01.15',
      icon: Icons.description_outlined,
      content: '''등기부등본의 '을구'는 소유권 이외의 권리 관계를 보여줍니다.

확인해야 할 핵심 항목:

1. 근저당권 설정액
→ 전세보증금보다 근저당이 크면 위험합니다.

2. 선순위 채권 여부
→ 먼저 설정된 전세권이나 임차권이 있는지 확인하세요.

3. 가압류, 가등기 등 제한물권
→ 이런 권리가 있으면 경매로 갈 가능성이 높습니다.

등기부등본은 반드시 계약 당일 발급본을 받아서 확인하시고,
의심스러운 내용이 있다면 반드시 전문가와 상담하세요.

Safe-Guard 엔진은 이런 복잡한 권리 관계를 3초 만에 분석해드립니다.

추가로, 등기부등본의 '갑구'는 소유권 변동 사항을, '을구'는 소유권 이외의 권리를 나타냅니다.
두 부분을 모두 꼼꼼히 확인하시는 것이 안전합니다.''',
    ),
  ];
}
