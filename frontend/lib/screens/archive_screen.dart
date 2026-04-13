import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  static const List<Map<String, dynamic>> _mockInsights = [
    {
      'date': '2026년 4월 1일',
      'mood': '밝음',
      'moodType': 'bright',
      'tags': ['친환경 에너지', '반도체'],
      'summary':
          '글로벌 기후 정상회의에서 15개국이 탄소 배출 감축에 합의하며 친환경 정책 기대감이 높아졌고, 아시아 태평양 지역의 경기 회복과 한국 반도체 수출 증가가 함께 나타나며 시장 전반의 투자 심리가 개선되고 있습니다.',
      'detail':
          '탄소 감축 정책 강화와 반도체 업황 회복이 동시에 나타나며 관련 테마의 유동성이 커지고 있습니다.',
      'keywords': ['탄소감축', '친환경', '반도체', '경제회복'],
    },
    {
      'date': '2026년 3월 31일',
      'mood': '밝음',
      'moodType': 'bright',
      'tags': ['친환경 에너지', '반도체'],
      'summary':
          '글로벌 기후 정상회의에서 15개국이 탄소 배출 감축에 합의하며 친환경 정책 기대감이 높아졌고, 아시아 태평양 지역의 경기 회복과 한국 반도체 수출 증가가 함께 나타나며 시장 전반의 투자 심리가 개선되고 있습니다.',
      'detail':
          '탄소 감축 정책 강화와 반도체 업황 회복이 동시에 나타나며 관련 테마의 유동성이 커지고 있습니다.',
      'keywords': ['탄소감축', '친환경', '반도체', '경제회복'],
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
                      '시장 인사이트',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '현재 시장의 분위기와 주요 테마를 확인하세요',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _moodBgColor('bright'),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _moodIcon('bright'),
                                      size: 12,
                                      color: _moodColor('bright'),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '밝음',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _moodColor('bright'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ...['친환경 에너지', '반도체'].map(
                                (tag) => Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tag,
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
                          const Text(
                            '현재 시장의 분위기는 밝으며, 유동성이 높다고 판단되는 테마는 "친환경 에너지"와 "반도체" 입니다.',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '글로벌 기후 정상회의에서 15개국이 탄소 배출 감축에 합의하며 친환경 정책 기대감이 높아졌고, 아시아 태평양 지역의 경기 회복과 한국 반도체 수출 증가가 함께 나타나며 시장 전반의 투자 심리가 개선되고 있습니다.',
                            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '탄소 감축 정책 강화와 반도체 업황 회복이 동시에 나타나며 관련 테마의 유동성이 커지고 있습니다.',
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: ['탄소감축', '친환경', '반도체', '경제회복'].map(
                              (keyword) => Chip(
                                label: Text(keyword),
                              ),
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(_mockInsights.length, (i) {
                      final insight = _mockInsights[i];
                      final moodType = insight['moodType'] as String;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _InsightCard(
                          insight: insight,
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

class _InsightCard extends StatelessWidget {
  final Map<String, dynamic> insight;
  final Color moodColor;
  final Color moodBgColor;
  final IconData moodIcon;

  const _InsightCard({
    required this.insight,
    required this.moodColor,
    required this.moodBgColor,
    required this.moodIcon,
  });

  @override
  Widget build(BuildContext context) {
    final tags = insight['tags'] as List<dynamic>;

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
                      insight['date'] as String,
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
                            insight['mood'] as String,
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
                  insight['summary'] as String,
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
