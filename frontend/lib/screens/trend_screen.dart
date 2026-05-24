// 3면 (트렌드)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/report_provider.dart';
import '../core/utils.dart';
import '../core/theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/page_tab_bar.dart';
import 'insight_screen.dart';

class TrendScreen extends StatelessWidget {
  const TrendScreen({super.key});

  static const List<Map<String, String>> _fallbackTrends = [
    {'rank': '1', 'keyword': 'OpenAI 신모델'},
    {'rank': '2', 'keyword': '탄소국경세'},
    {'rank': '3', 'keyword': '반도체 수출'},
    {'rank': '4', 'keyword': '기후 정상회의'},
    {'rank': '5', 'keyword': 'AI 투자'},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();
    final provider = context.watch<ReportProvider>();

    final trends = provider.trendKeywords.isNotEmpty
        ? provider.trendKeywords
        : _fallbackTrends;

    final mood = provider.marketSentiment;

    return Scaffold(
      backgroundColor: colors.background,
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
                        pageBuilder: (ctx, a1, a2) => const InsightScreen(),
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
                      _DateSection(dateText: formatDate(now), mood: mood),
                      const SizedBox(height: 18),
                      const PageTabBar(selectedPage: 3),
                      const SizedBox(height: 28),
                      _TrendingKeywordsCard(trends: trends),
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

class _TrendingKeywordsCard extends StatelessWidget {
  final List<Map<String, String>> trends;

  const _TrendingKeywordsCard({required this.trends});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '실시간 인기 검색어',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '전 세계가 주목하고 있는 키워드입니다',
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
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

  Color _circleTextColor(int rank) {
    return rank <= 4 ? Colors.white : const Color(0xFF888896);
  }

  Future<void> _openNewsSearch(BuildContext context, String keyword) async {
    final encodedKeyword = Uri.encodeComponent(keyword);
    final uri = Uri.parse(
      'https://news.google.com/search?q=$encodedKeyword&hl=ko&gl=KR&ceid=KR:ko',
    );

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('뉴스 링크를 열 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rank = int.tryParse(trend['rank'] ?? '5') ?? 5;
    final keyword = trend['keyword'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: keyword.isEmpty ? null : () => _openNewsSearch(context, keyword),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
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
                      trend['rank'] ?? rank.toString(),
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
                    keyword,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvestmentInsightCard extends StatelessWidget {
  const _InvestmentInsightCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '투자 인사이트',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '실시간 검색어는 대중의 관심사를 반영합니다. 급격하게 증가하는 키워드와 관련된 산업 및 기업에 주목해보세요. 단, 투자 결정은 신중하게 하시기 바랍니다.',
            style: TextStyle(
              fontSize: 14,
              color: colors.textPrimary,
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
  final String mood;

  const _DateSection({required this.dateText, required this.mood});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final Color badgeBg;
    final Color badgeColor;
    final IconData badgeIcon;
    if (mood == '어두움') {
      badgeBg = const Color(0xFFFFEBEE);
      badgeColor = const Color(0xFFE53935);
      badgeIcon = Icons.trending_down;
    } else if (mood == '보통') {
      badgeBg = const Color(0xFFFFF8E1);
      badgeColor = const Color(0xFFFFA000);
      badgeIcon = Icons.trending_flat;
    } else {
      badgeBg = const Color(0xFFE8F7EC);
      badgeColor = const Color(0xFF27AE60);
      badgeIcon = Icons.trending_up;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '글로벌 뉴스 & 경제 리포트',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Icon(badgeIcon, size: 16, color: badgeColor),
              const SizedBox(width: 6),
              Text(
                mood,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) {
  final colors = context.colors;
  return BoxDecoration(
    color: colors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: colors.border),
    boxShadow: [
      BoxShadow(
        color: context.isDark ? Colors.transparent : const Color(0x05000000),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
