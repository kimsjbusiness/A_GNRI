// 2면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/report_provider.dart';
import '../core/utils.dart';
import '../core/theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/page_tab_bar.dart';
import 'home_screen.dart';

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

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();
    final provider = context.watch<ReportProvider>();
    final data = provider.insightData;

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
                        pageBuilder: (ctx, a1, a2) => const HomeScreen(),
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
                      _DateSection(
                        dateText: formatDate(now),
                        mood: data['mood'] as String,
                      ),
                      const SizedBox(height: 18),
                      const PageTabBar(selectedPage: 2),
                      const SizedBox(height: 28),
                      _MarketAnalysisCard(
                        data: data,
                        onTap: () =>
                            _showMarketAnalysisBottomSheet(context, data),
                      ),
                      const SizedBox(height: 24),
                      _SentimentAnalysisCard(
                        positiveRatio: data['positiveRatio'] as double,
                        negativeRatio: data['negativeRatio'] as double,
                      ),
                      const SizedBox(height: 24),
                      _KeywordAnalysisCard(
                        keywords: List<String>.from(
                          data['keywords'] as List<dynamic>,
                        ),
                      ),
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

  void _showMarketAnalysisBottomSheet(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = context.colors;
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
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
                          color: colors.border,
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
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: colors.border),
                              ),
                              child: Text(
                                data['mood'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textSecondary,
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.trending_up,
                                    size: 14,
                                    color: Color(0xFF27AE60),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '신뢰도 ${data['confidence']}',
                                    style: const TextStyle(
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
                              color: colors.chipBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _BottomSheetSection(
                      icon: Icons.trending_up,
                      title: '시장 분위기',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            size: 18,
                            color: Color(0xFF11B981),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            data['mood'] as String,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7EC),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '신뢰도 ${data['confidence']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF27AE60),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BottomSheetSection(
                      icon: Icons.bolt_outlined,
                      title: '주요 테마',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (data['themes'] as List<dynamic>)
                            .map(
                              (theme) => _SheetThemeChip(
                                text: theme.toString(),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BottomSheetSection(
                      icon: Icons.analytics_outlined,
                      title: '판단 근거',
                      child: Text(
                        data['reason'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          color: colors.textPrimary,
                          height: 1.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BottomSheetSection(
                      icon: Icons.tag_outlined,
                      title: '관련 키워드',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (data['keywords'] as List<dynamic>)
                            .map(
                              (keyword) => _SheetKeywordChip(
                                text: keyword.toString(),
                                onTap: () => _openNewsSearch(
                                  context,
                                  keyword.toString(),
                                ),
                              ),
                            )
                            .toList(),
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

class _MarketAnalysisCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _MarketAnalysisCard({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
          decoration: _cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '시장 분석',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '상세 보기',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                '시장 분위기',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    size: 19,
                    color: Color(0xFF11B981),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data['mood'] as String,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.chipBg,
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '신뢰도: ${data['confidence']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Divider(height: 1, thickness: 1, color: colors.border),
              const SizedBox(height: 22),
              Text(
                '주요 테마',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                (data['themes'] as List<dynamic>).join(' & '),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 22),
              Divider(height: 1, thickness: 1, color: colors.border),
              const SizedBox(height: 22),
              Text(
                '시장 동향 분석',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                data['summary'] as String,
                style: TextStyle(
                  fontSize: 15,
                  color: colors.textPrimary,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheetSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _BottomSheetSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color:
                context.isDark ? Colors.transparent : const Color(0x08000000),
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
                  color: colors.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: colors.textSecondary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SheetThemeChip extends StatelessWidget {
  final String text;

  const _SheetThemeChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7EC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF27AE60),
        ),
      ),
    );
  }
}

class _SheetKeywordChip extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _SheetKeywordChip({
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.chipBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 5),
                Icon(
                  Icons.open_in_new,
                  size: 12,
                  color: colors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _KeywordAnalysisCard extends StatelessWidget {
  final List<String> keywords;

  const _KeywordAnalysisCard({required this.keywords});

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
            '키워드 분석',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          keywords.isEmpty
              ? Text(
                  '키워드 데이터를 불러오는 중입니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: keywords
                      .map(
                        (k) => _SheetKeywordChip(
                          text: k,
                          onTap: () => _openNewsSearch(context, k),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class _SentimentAnalysisCard extends StatelessWidget {
  final double positiveRatio;
  final double negativeRatio;

  const _SentimentAnalysisCard({
    required this.positiveRatio,
    required this.negativeRatio,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '감성 분석 상세',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _SentimentBar(
            label: '긍정 지수',
            valueText: '${(positiveRatio * 100).round()}%',
            ratio: positiveRatio,
            color: const Color(0xFF11B981),
          ),
          const SizedBox(height: 18),
          _SentimentBar(
            label: '부정 지수',
            valueText: '${(negativeRatio * 100).round()}%',
            ratio: negativeRatio,
            color: const Color(0xFFFF4768),
          ),
        ],
      ),
    );
  }
}

class _SentimentBar extends StatelessWidget {
  final String label;
  final String valueText;
  final double ratio;
  final Color color;

  const _SentimentBar({
    required this.label,
    required this.valueText,
    required this.ratio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              valueText,
              style: TextStyle(
                fontSize: 14,
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: ratio,
            backgroundColor: context.colors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
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
    borderRadius: BorderRadius.circular(10),
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
