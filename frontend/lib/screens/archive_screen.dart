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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ArchiveCard(
                          report: report,
                          moodColor: _moodColor(moodType),
                          moodBgColor: _moodBgColor(moodType),
                          moodIcon: _moodIcon(moodType),
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

class _ArchiveCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final Color moodColor;
  final Color moodBgColor;
  final IconData moodIcon;

  const _ArchiveCard({
    required this.report,
    required this.moodColor,
    required this.moodBgColor,
    required this.moodIcon,
  });

  @override
  Widget build(BuildContext context) {
    final tags = report['tags'] as List<dynamic>;

    return Container(
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
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[600]),
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
    );
  }
}
