// 3면 (트렌드)

import 'package:flutter/material.dart';
import '../core/utils.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/page_tab_bar.dart';
import 'insight_screen.dart';

class TrendScreen extends StatelessWidget {
  const TrendScreen({super.key});

  static const List<Map<String, String>> _mockTrends = [
    {'rank': '1', 'keyword': 'OpenAI 신모델'},
    {'rank': '2', 'keyword': '탄소국경세'},
    {'rank': '3', 'keyword': '반도체 수출'},
    {'rank': '4', 'keyword': '기후 정상회의'},
    {'rank': '5', 'keyword': 'AI 투자'},
  ];

  static const Map<String, dynamic> _insightData = {
    'mood': '밝음',
    'confidence': '72%',
    'themes': ['친환경 에너지', '반도체'],
    'keywords': ['기후', '탄소감축', '경제회복', '반도체'],
    'summary':
        '현재 시장의 분위기는 밝으며, 유동성이 높다 판단되는 주식의 테마는 \'친환경 에너지\'와 \'반도체\'입니다.',
    'reason':
        '글로벌 기후 정상회의의 탄소 감축 합의와 아시아 태평양 지역의 경기 회복, 반도체 수출 증가가 함께 반영되었습니다.',
    'positiveRatio': 0.72,
    'negativeRatio': 0.28,
  };

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity > 300) {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => InsightScreen(
                          reportData: _insightData,
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DateSection(dateText: formatDate(now)),
                      const SizedBox(height: 18),
                      const PageTabBar(
                        selectedPage: 3,
                        insightData: _insightData,
                      ),
                      const SizedBox(height: 28),
                      _TrendingKeywordsCard(trends: _mockTrends),
                      const SizedBox(height: 24),
                      const _InvestmentInsightCard(),
                    ],
                  ),
                ),
              ),
            ),
            const BottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}

// 실시간 인기 검색어 카드
class _TrendingKeywordsCard extends StatelessWidget {
  final List<Map<String, String>> trends;

  const _TrendingKeywordsCard({required this.trends});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '실시간 인기 검색어',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '전 세계가 주목하고 있는 키워드입니다',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF9A9AA5),
            ),
          ),
          const SizedBox(height: 20),
          ...trends.map((trend) => _TrendItem(trend: trend)),
        ],
      ),
    );
  }
}

class _TrendItem extends StatelessWidget {
  final Map<String, String> trend;

  const _TrendItem({required this.trend});

  // 순위별 동그라미 배경색 (1위 가장 진하게, 점점 밝아짐)
  Color _circleBgColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFF111111);
      case 2:
        return const Color(0xFF444451);
      case 3:
        return const Color(0xFF777780);
      case 4:
        return const Color(0xFFAAAAAB);
      default:
        return const Color(0xFFD3D3DA);
    }
  }

  // 순위별 동그라미 텍스트색
  Color _circleTextColor(int rank) {
    return rank <= 4 ? Colors.white : const Color(0xFF888896);
  }

  @override
  Widget build(BuildContext context) {
    final rank = int.parse(trend['rank']!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3E3E8)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _circleBgColor(rank),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  trend['rank']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _circleTextColor(rank),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                trend['keyword']!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
            ),
            Icon(
              Icons.open_in_new,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

// 투자 인사이트 카드
class _InvestmentInsightCard extends StatelessWidget {
  const _InvestmentInsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F1F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: Color(0xFF666674),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '투자 인사이트',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '실시간 검색어는 대중의 관심사를 반영합니다. 급격하게 증가하는 키워드와 관련된 산업 및 기업에 주목해보세요. 단, 투자 결정은 신중하게 하시기 바랍니다.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSection extends StatelessWidget {
  final String dateText;

  const _DateSection({required this.dateText});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '글로벌 뉴스 & 경제 리포트',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9A9AA5),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F7EC),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: Color(0xFF27AE60)),
              SizedBox(width: 6),
              Text(
                '밝음',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF27AE60),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFE3E3E8)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x05000000),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
  );
}
