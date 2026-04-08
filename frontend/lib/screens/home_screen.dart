import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../core/utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<NewsCardData> cards = [
      NewsCardData(
        country: '브라질',
        category: '환경',
        title: '아마존 산림 복원 프로젝트, 100만 그루 나무 식재 완료',
        summary:
            '브라질 정부와 환경 단체들이 추진한 아마존 산림 복원 프로젝트가 첫 번째 이정표를 달성했습니다. 향후 10년간 1억 그루를 추가로 심을 계획입니다.',
      ),
      NewsCardData(
        country: '브라질',
        category: '환경',
        title: '아마존 산림 복원 프로젝트, 100만 그루 나무 식재 완료',
        summary:
            '브라질 정부와 환경 단체들이 추진한 아마존 산림 복원 프로젝트가 첫 번째 이정표를 달성했습니다. 향후 10년간 1억 그루를 추가로 심을 계획입니다.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeaderSection(),
                    const SizedBox(height: 20),
                    const _DateSection(),
                    const SizedBox(height: 18),
                    const _PageTabBar(),
                    const SizedBox(height: 18),

                    ...cards.map((card) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: NewsCard(data: card),
                      );
                    }),

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

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF050A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('🌎')),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Global News Report',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2),
              Text(
                '전세계 통합 뉴스 & 경제 리포트',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
        const Icon(Icons.notifications_none),
        const SizedBox(width: 8),
        const Icon(Icons.dark_mode_outlined),
        const SizedBox(width: 8),
        const Icon(Icons.settings_outlined),
      ],
    );
  }
}

class _DateSection extends StatelessWidget {
  const _DateSection();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDateWithDay(now), // 🔥 utils 사용
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '글로벌 뉴스 & 경제 리포트',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F8EC),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: Colors.green),
              SizedBox(width: 6),
              Text(
                '밝음',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PageTabBar extends StatelessWidget {
  const _PageTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Expanded(child: _TabItem(title: '1면', isSelected: true)),
          Expanded(child: _TabItem(title: '2면', isSelected: false)),
          Expanded(child: _TabItem(title: '3면', isSelected: false)),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;

  const _TabItem({
    required this.title,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class NewsCardData {
  final String country;
  final String category;
  final String title;
  final String summary;

  NewsCardData({
    required this.country,
    required this.category,
    required this.title,
    required this.summary,
  });
}

class NewsCard extends StatelessWidget {
  final NewsCardData data;

  const NewsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              color: Colors.grey[300],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data.summary,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainNewsSection extends StatelessWidget {
  const MainNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 주요 뉴스',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('글로벌 기후 정상회의에서 15개국이 탄소 감축에 합의했습니다.'),
          SizedBox(height: 10),
          Text('아시아 경제 회복세가 가속화되고 있습니다.'),
          SizedBox(height: 10),
          Text('AI 투자 증가가 시장을 이끌고 있습니다.'),
        ],
      ),
    );
  }
}