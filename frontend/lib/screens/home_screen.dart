
// 1면(홈)
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/news_card.dart';
import '../widgets/page_tab_bar.dart';
import '../core/utils.dart';
import '../core/theme.dart';
import 'insight_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReportProvider>();
      if (!provider.hasData && !provider.isLoading) {
        provider.loadLatest();
      }
    });
  }

  static String _extractTitle(String summary) {
    final dotIndex = summary.indexOf('. ');
    if (dotIndex > 5 && dotIndex <= 65) {
      return summary.substring(0, dotIndex);
    }
    if (summary.length > 65) return '${summary.substring(0, 65)}...';
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();
    final provider = context.watch<ReportProvider>();

    Widget body;

    if (provider.isLoading && !provider.hasData) {
      body = Center(
        child: CircularProgressIndicator(color: colors.textPrimary),
      );
    } else if (provider.error != null && !provider.hasData) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_outlined, size: 48, color: colors.textSecondary),
            const SizedBox(height: 16),
            Text(
              '리포트를 불러오지 못했습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '인터넷 연결을 확인해주세요',
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<ReportProvider>().loadLatest(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.textPrimary,
                foregroundColor: colors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    } else {
      final fullReport = provider.report;
      final insightData = provider.insightData;

      final List<NewsCardData> cards;
      final List<String> mainSentences;

      if (fullReport != null) {
        final summaries = fullReport.finalSummariesKr.take(2).toList();
        final detailedSummaries = fullReport.detailedSummaries.take(2).toList();
        cards = summaries.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final summary = entry.value;
                final detailed = detailedSummaries.length > index ? detailedSummaries[index] : summary;
                return NewsCardData(
                  country: '글로벌',
                  category: '국제',
                  title: summary,
                  summary: detailed,
                );
              },
            )
            .toList();
        mainSentences = fullReport.top3Sentences;
      } else {
        cards = const [
          NewsCardData(
            country: '글로벌',
            category: '기후',
            title: '15개국, 2030년까지 탄소 배출 50% 감축 합의',
            summary:
                '글로벌 기후 정상회의에서 15개국이 2030년까지 탄소 배출을 절반으로 줄이기로 합의했습니다. 미국과 중국은 신재생 에너지 협력 확대를 발표했고, EU는 탄소국경세 시행 시점을 앞당기기로 했습니다.',
            keywords: ['기후', '탄소감축'],
          ),
          NewsCardData(
            country: '아시아',
            category: '경제',
            title: '아시아 태평양, 회복세 가속… 반도체·증시 동반 상승',
            summary:
                '아시아 태평양 지역의 경제 회복세가 뚜렷해지고 있습니다. 일본 닛케이 지수는 3개월 연속 상승했고, 한국의 반도체 수출은 전년 대비 25% 증가하며 시장 기대감을 높이고 있습니다.',
            keywords: ['경제회복', '반도체'],
          ),
        ];
        mainSentences = const [
          '글로벌 기후 정상회의에서 15개국이 2030년까지 탄소 배출 50% 감축에 합의했습니다.',
          '미국과 중국은 신재생 에너지 협력 강화를 발표했고, EU는 탄소국경세 시행을 앞당기기로 결정했습니다.',
          '아시아 태평양 지역에서 경제 회복세가 가속화되고 있습니다.',
        ];
      }

      body = GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -300) {
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
              if (provider.isPipelineRunning || provider.pipelineProgress > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _PipelineStatusCard(
                    progress: provider.pipelineProgress,
                    status: provider.pipelineStatus,
                    isRunning: provider.isPipelineRunning,
                  ),
                ),
              _DateSection(
                dateText: formatDate(now),
                mood: insightData['mood'] as String,
              ),
              const SizedBox(height: 18),
              const PageTabBar(selectedPage: 1),
              const SizedBox(height: 18),
              ...cards.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NewsCard(
                    data: entry.value,
                    imageBytes: provider.imageAt(entry.key),
                    onTap: () => _showNewsBottomSheet(
                      context,
                      entry.value,
                      provider.imageAt(entry.key),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              MainNewsSection(sentences: mainSentences),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(child: body),
            const BottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }

  void _showNewsBottomSheet(
    BuildContext context,
    NewsCardData card,
    Uint8List? imageBytes,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final sheetColors = context.colors;
        return Container(
          decoration: BoxDecoration(
            color: sheetColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                          color: sheetColors.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: sheetColors.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: sheetColors.border),
                              ),
                              child: Text(
                                card.country,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: sheetColors.textSecondary,
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: sheetColors.chipBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: sheetColors.textSecondary,
                            ),
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: context.isDark
                              ? const [Color(0xFF1E2030), Color(0xFF1E2820)]
                              : const [Color(0xFFEAF4FF), Color(0xFFF4F8EC)],
                        ),
                        border: Border.all(color: sheetColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imageBytes != null
                          ? Image.memory(
                              imageBytes,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(
                                card.category == '기후'
                                    ? Icons.public
                                    : Icons.show_chart,
                                size: 72,
                                color: sheetColors.textSecondary,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      card.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: sheetColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: sheetColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sheetColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: context.isDark
                                ? Colors.transparent
                                : const Color(0x08000000),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                                decoration: BoxDecoration(
                                  color: sheetColors.iconBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.article_outlined,
                                  size: 18,
                                  color: sheetColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '상세 요약',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: sheetColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            card.summary,
                            style: TextStyle(
                              fontSize: 15,
                              color: sheetColors.textPrimary,
                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (card.keywords.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: sheetColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sheetColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '핵심 키워드',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: sheetColors.textPrimary,
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
                                        color: sheetColors.chipBg,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        keyword,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: sheetColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _PipelineStatusCard extends StatelessWidget {
  final int progress;
  final String status;
  final bool isRunning;

  const _PipelineStatusCard({
    required this.progress,
    required this.status,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDone = !isRunning && progress == 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: isDone
            ? const Color(0xFFE8F7EC)
            : colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? const Color(0xFF27AE60)
              : colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isRunning)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.textPrimary,
                  ),
                )
              else
                Icon(
                  isDone ? Icons.check_circle_outline : Icons.error_outline,
                  size: 16,
                  color: isDone
                      ? const Color(0xFF27AE60)
                      : colors.textSecondary,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isRunning
                      ? '리포트 최신화 중...'
                      : isDone
                          ? '최신화 완료!'
                          : '최신화 완료',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDone
                        ? const Color(0xFF27AE60)
                        : colors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$progress%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDone
                      ? const Color(0xFF27AE60)
                      : colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 6,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone
                    ? const Color(0xFF27AE60)
                    : colors.textPrimary,
              ),
            ),
          ),
          if (status.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: colors.textSecondary,
              ),
            ),
          ],
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

class MainNewsSection extends StatelessWidget {
  final List<String> sentences;

  const MainNewsSection({super.key, required this.sentences});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.transparent
                : const Color(0x08000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 주요 뉴스',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          ...sentences.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key < sentences.length - 1 ? 14 : 0,
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.textPrimary,
                  height: 1.7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
