import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  static const List<Map<String, dynamic>> _mockReports = [
    {
      'date': '2026년 4월 1일',
      'mood': '밝음',
      'moodType': 'bright',
      'tags': ['친환경 & AI 기술'],
      'summary':
          '글로벌 기후 정상회의에서 15개국이 2030년까지 탄소 배출 50% 감축에 합의했습니다. 미국과 중국은 신재생 에너지 협력 강화를 발표했으며, EU는 탄소국경세 시행을 앞당기기로 결정했습니다.',
    },
    {
      'date': '2026년 3월 31일',
      'mood': '어두움',
      'moodType': 'dark',
      'tags': ['방위주 & 에너지'],
      'summary':
          '중동 지역에서 긴장이 고조되고 있습니다. 석유 수출국들은 생산량 조정을 논의 중이며, 국제 유가는 배럴당 5달러 상승했습니다. 유럽 증시는 에너지 우려로 하락세를 보였습니다. 미국 연방준',
    },
    {
      'date': '2026년 3월 30일',
      'mood': '보통',
      'moodType': 'neutral',
      'tags': ['핀테크 & 물류'],
      'summary':
          'G7 국가들이 디지털 화폐 협력 체계 구축에 합의했습니다. 중앙은행 디지털화폐(CBDC) 표준화 작업이 시작되며, 국제 결제 시스템의 혁신이 예상됩니다. 글로벌 공급망이 안정화되고 있습',
    },
  ];

  // 리포트 1면과 동일한 뉴스 카드 목데이터
  static const List<Map<String, String>> _mockNewsCards = [
    {
      'country': '브라질',
      'category': '환경',
      'title': '아마존 산림 복원 프로젝트, 100만 그루 나무 식재 완료',
      'summary':
          '브라질 정부와 환경 단체들이 추진한 아마존 산림 복원 프로젝트가 첫 번째 이정표를 달성했습니다. 향후 10년간 1억 그루를 추가로 심을 계획입니다.',
    },
    {
      'country': '브라질',
      'category': '환경',
      'title': '아마존 산림 복원 프로젝트, 100만 그루 나무 식재 완료',
      'summary':
          '브라질 정부와 환경 단체들이 추진한 아마존 산림 복원 프로젝트가 첫 번째 이정표를 달성했습니다. 향후 10년간 1억 그루를 추가로 심을 계획입니다.',
    },
  ];

  Color _moodColor(String type) {
    switch (type) {
      case 'bright':
        return Colors.green;
      case 'dark':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _moodBgColor(String type) {
    switch (type) {
      case 'bright':
        return const Color(0xFFE7F8EC);
      case 'dark':
        return const Color(0xFFFFECEC);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  IconData _moodIcon(String type) {
    switch (type) {
      case 'bright':
        return Icons.trending_up;
      case 'dark':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  void _showReportDetail(
    BuildContext context,
    Map<String, dynamic> report,
    Color moodColor,
    Color moodBgColor,
    IconData moodIcon,
  ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: _ReportDetailModal(
          report: report,
          moodColor: moodColor,
          moodBgColor: moodBgColor,
          moodIcon: moodIcon,
          newsCards: _mockNewsCards,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE3E3E8)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '과거 리포트',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '지난 리포트를 다시 확인하세요',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(_mockReports.length, (i) {
                      final report = _mockReports[i];
                      final moodType = report['moodType'] as String;
                      final moodColor = _moodColor(moodType);
                      final moodBgColor = _moodBgColor(moodType);
                      final moodIcon = _moodIcon(moodType);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ArchiveCard(
                          report: report,
                          moodColor: moodColor,
                          moodBgColor: moodBgColor,
                          moodIcon: moodIcon,
                          onTap: () => _showReportDetail(
                            context,
                            report,
                            moodColor,
                            moodBgColor,
                            moodIcon,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const BottomNavBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}

// ─── 기록 카드 ────────────────────────────────────────────────────────────────
class _ArchiveCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final Color moodColor;
  final Color moodBgColor;
  final IconData moodIcon;
  final VoidCallback onTap;

  const _ArchiveCard({
    required this.report,
    required this.moodColor,
    required this.moodBgColor,
    required this.moodIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tags = report['tags'] as List<dynamic>;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        report['date'] as String,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: moodBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(moodIcon, size: 12, color: moodColor),
                            const SizedBox(width: 3),
                            Text(
                              report['mood'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: moodColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...tags.map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report['summary'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

// ─── 리포트 상세 모달 ──────────────────────────────────────────────────────────
class _ReportDetailModal extends StatelessWidget {
  final Map<String, dynamic> report;
  final Color moodColor;
  final Color moodBgColor;
  final IconData moodIcon;
  final List<Map<String, String>> newsCards;

  const _ReportDetailModal({
    required this.report,
    required this.moodColor,
    required this.moodBgColor,
    required this.moodIcon,
    required this.newsCards,
  });

  @override
  Widget build(BuildContext context) {
    final tags = report['tags'] as List<dynamic>;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 모달 헤더 ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['date'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // 감성 뱃지
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: moodBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(moodIcon, size: 12, color: moodColor),
                                const SizedBox(width: 3),
                                Text(
                                  report['mood'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: moodColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 태그 뱃지
                          ...tags.map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag.toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 닫기 버튼
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFE3E3E8)),

          // ── 스크롤 본문 ────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 주요 이미지 섹션
                  const Text(
                    '주요 이미지',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...newsCards.map(
                    (card) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ModalNewsCard(
                        country: card['country']!,
                        category: card['category']!,
                        title: card['title']!,
                        summary: card['summary']!,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 주요 뉴스 섹션
                  const Text(
                    '주요 뉴스',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    report['summary'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '아시아 경제 회복세가 가속화되고 있습니다. 일본 닛케이 지수는 3개월 연속 상승세를 기록했으며, 한국의 전체 수출이 전년 대비 25% 증가했습니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '테크 기업들의 AI 투자가 가속화되고 있습니다. OpenAI는 새로운 멀티모달 AI 모델을 발표했고, 구글과 마이크로소프트도 AI 인프라에 각각 100억 달러 이상을 투자하기로 했습니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '현재 시장의 분위기는 밝으며, 유동성이 높고 환산되는 주식에 주목할 필요가 있습니다. 전반적 경제 테마는 \'친환경 에너지와 AI 기술\'입니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 모달 뉴스 카드 (이미지 + 국가/카테고리 라벨 오버레이) ───────────────────────
class _ModalNewsCard extends StatelessWidget {
  final String country;
  final String category;
  final String title;
  final String summary;

  const _ModalNewsCard({
    required this.country,
    required this.category,
    required this.title,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 플레이스홀더 + 라벨 오버레이
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.grey[300],
                ),
                child: const Icon(
                  Icons.image_outlined,
                  size: 36,
                  color: Colors.grey,
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Row(
                  children: [
                    _ImageLabel(text: country, dark: true),
                    const SizedBox(width: 6),
                    _ImageLabel(text: category, dark: false),
                  ],
                ),
              ),
            ],
          ),
          // 제목 + 요약
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 이미지 위 라벨 뱃지 ──────────────────────────────────────────────────────
class _ImageLabel extends StatelessWidget {
  final String text;
  final bool dark;

  const _ImageLabel({required this.text, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF111111) : Colors.grey[600],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
