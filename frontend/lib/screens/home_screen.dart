import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/news_card.dart';
import '../widgets/page_tab_bar.dart';
import '../core/utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final List<NewsCardData> cards = [
      const NewsCardData(
        country: '글로벌',
        category: '기후',
        title: '15개국, 2030년까지 탄소 배출 50% 감축 합의',
        summary:
            '글로벌 기후 정상회의에서 15개국이 2030년까지 탄소 배출을 절반으로 줄이기로 합의했습니다. 미국과 중국은 신재생 에너지 협력 확대를 발표했고, EU는 탄소국경세 시행 시점을 앞당기기로 했습니다.',
        keywords: ['기후', '탄소감축'],
      ),
      const NewsCardData(
        country: '아시아',
        category: '경제',
        title: '아시아 태평양, 회복세 가속… 반도체·증시 동반 상승',
        summary:
            '아시아 태평양 지역의 경제 회복세가 뚜렷해지고 있습니다. 일본 닛케이 지수는 3개월 연속 상승했고, 한국의 반도체 수출은 전년 대비 25% 증가하며 시장 기대감을 높이고 있습니다.',
        keywords: ['경제회복', '반도체'],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DateSection(dateText: formatDate(now)),
                    const SizedBox(height: 18),
                    const PageTabBar(selectedPage: 1),
                    const SizedBox(height: 18),
                    ...cards.map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: NewsCard(
                          data: card,
                          onTap: () => _showNewsBottomSheet(context, card),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const MainNewsSection(),
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

  void _showNewsBottomSheet(BuildContext context, NewsCardData card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF6F6F8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3D3DA),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFE3E3E8)),
                          ),
                          child: Text(
                            card.country,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF666674),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F7EC),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 14,
                                color: Color(0xFF27AE60),
                              ),
                              SizedBox(width: 5),
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
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 210,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFEAF4FF),
                            Color(0xFFF4F8EC),
                          ],
                        ),
                        border: Border.all(color: const Color(0xFFE3E3E8)),
                      ),
                      child: Center(
                        child: Icon(
                          card.category == '기후'
                              ? Icons.public
                              : Icons.show_chart,
                          size: 72,
                          color: const Color(0xFF9A9AA5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      card.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE3E3E8)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
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
                                  Icons.article_outlined,
                                  size: 18,
                                  color: Color(0xFF666674),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                '상세 요약',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111111),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            card.summary,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF333333),
                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE3E3E8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '핵심 키워드',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: card.keywords
                                .map(
                                  (keyword) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F1F5),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      keyword,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF555563),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          '닫기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DateSection extends StatelessWidget {
  final String dateText;

  const _DateSection({
    required this.dateText,
  });

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
              Icon(
                Icons.trending_up,
                size: 16,
                color: Color(0xFF27AE60),
              ),
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

class MainNewsSection extends StatelessWidget {
  const MainNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E3E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 주요 뉴스',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
            ),
          ),
          SizedBox(height: 18),
          Text(
            '글로벌 기후 정상회의에서 15개국이 2030년까지 탄소 배출 50% 감축에 합의했습니다. 미국과 중국은 신재생 에너지 협력 강화를 발표했고, EU는 탄소국경세 시행을 앞당기기로 결정했습니다.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
              height: 1.7,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '아시아 태평양 지역에서 경제 회복세가 가속화되고 있습니다. 일본 닛케이 지수는 3개월 연속 상승세를 기록했고, 한국의 반도체 수출은 전년 대비 25% 증가했습니다.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}