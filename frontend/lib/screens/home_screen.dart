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
        country: '브라질',
        category: '환경',
        title: '아마존 산림 복원 프로젝트, 100만 그루 나무 식재 완료',
        summary:
            '브라질 정부와 환경 단체들이 추진한 아마존 산림 복원 프로젝트가 첫 번째 이정표를 달성했습니다. 그루의 나무 식재가 완료되었으며, 향후 10년간 1억 그루를 추가로 심을 계획입니다.',
        keywords: ['브라질', '환경'],
      ),
      const NewsCardData(
        country: '브라질',
        category: '환경',
        title: '아마존 산림 복원 프로젝트, 100만 그루 나무 식재 완료',
        summary:
            '브라질 정부와 환경 단체들이 추진한 아마존 산림 복원 프로젝트가 첫 번째 이정표를 달성했습니다. 그루의 나무 식재가 완료되었으며, 향후 10년간 1억 그루를 추가로 심을 계획입니다.',
        keywords: ['브라질', '환경'],
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
                        child: NewsCard(data: card),
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
            '글로벌 기후 정상회의에서 15개국이 2030년까지 탄소 배출 50% 감축에 합의했습니다. 미국과 중국은 신재생 에너지 협력 강화를 발표했으며, EU는 탄소국경세 시행을 앞당기기로 결정했습니다.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
              height: 1.7,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '아시아 태평양 지역에서 경제 회복세가 가속화되고 있습니다. 일본 닛케이 지수는 3개월 연속 상승세를 기록했으며, 한국의 반도체 수출이 전년 대비 25% 증가했습니다.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
              height: 1.7,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '테크 기업들의 AI 투자가 급증하고 있습니다. OpenAI는 새로운 멀티모달 AI 모델을 발표했고, 구글과 마이크로소프트는 AI 인프라에 각각 100억 달러 이상을 투자하기로 했습니다.',
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