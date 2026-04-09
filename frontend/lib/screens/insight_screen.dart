import 'package:flutter/material.dart';
import '../core/utils.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/page_tab_bar.dart';

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final List<String> keywords = [
      '기후변화',
      '탄소중립',
      'AI',
      '반도체',
      '신재생에너지',
      '전기차',
      '금리',
      '수출',
      '원자재',
      '친환경',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DateSection(dateText: formatDateWithDay(now)),
                    const SizedBox(height: 18),
                    const PageTabBar(selectedPage: 2),
                    const SizedBox(height: 18),
                    const _MarketMoodCard(),
                    const SizedBox(height: 16),
                    const _ThemeCard(),
                    const SizedBox(height: 16),
                    _KeywordCard(keywords: keywords),
                    const SizedBox(height: 16),
                    const _InsightSummaryCard(),
                  ],
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
                '시장 분석 리포트',
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
            color: const Color(0xFFFFF3E6),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            children: [
              Icon(Icons.remove, size: 16, color: Color(0xFFF2994A)),
              SizedBox(width: 6),
              Text(
                '보통',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF2994A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarketMoodCard extends StatelessWidget {
  const _MarketMoodCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '현재 시장 분위기',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _MoodBadge(
                icon: Icons.sentiment_neutral_rounded,
                label: '보통',
                backgroundColor: Color(0xFFFFF3E6),
                iconColor: Color(0xFFF2994A),
                textColor: Color(0xFFF2994A),
              ),
              SizedBox(width: 10),
              Text(
                '신뢰도 72%',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7B7B86),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Text(
            '오늘 글로벌 시장은 전반적으로 중립적인 분위기를 보이고 있습니다. '
            '기후·AI·반도체 관련 뉴스가 긍정적으로 작용했지만, 금리와 원자재 이슈가 일부 불안 요소로 반영되었습니다.',
            style: TextStyle(
              fontSize: 15,
              height: 1.65,
              color: Color(0xFF2A2A2A),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const _MoodBadge({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '유동성이 높을 것으로 보이는 테마',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ThemeChip(text: '친환경'),
              _ThemeChip(text: 'AI 기술'),
              _ThemeChip(text: '반도체'),
            ],
          ),
          SizedBox(height: 18),
          Text(
            '현재 뉴스 흐름을 종합하면 친환경, AI 기술, 반도체 관련 섹터에 관심이 집중될 가능성이 높습니다. '
            '특히 정책·기술 투자 관련 기사 비중이 높아 단기적으로도 주목받을 수 있습니다.',
            style: TextStyle(
              fontSize: 15,
              height: 1.65,
              color: Color(0xFF2A2A2A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String text;

  const _ThemeChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF3B6EF5),
        ),
      ),
    );
  }
}

class _KeywordCard extends StatelessWidget {
  final List<String> keywords;

  const _KeywordCard({required this.keywords});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주요 키워드',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: keywords
                .map(
                  (keyword) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      keyword,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF44444F),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _InsightSummaryCard extends StatelessWidget {
  const _InsightSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: const Color(0xFF101522),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '한줄 시장 요약',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '현재 시장의 분위기는 보통이며, 유동성이 높을 것으로 보이는 주식 테마는 '
            '\'친환경\'과 \'AI 기술\' 입니다.',
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Color(0xFFE8EAF1),
            ),
          ),
        ],
      ),
    );
  }
}