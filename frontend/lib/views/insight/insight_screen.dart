import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;
import '../../data/providers/report_state_provider.dart';
import '../../core/theme/app_theme.dart';

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $urlString');
      }
    } catch (e) {
      developer.log("Error launching URL: $urlString", error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INSIGHTS & TRENDS'),
      ),
      body: Consumer<ReportStateProvider>(
        builder: (context, state, child) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldAccent),
              ),
            );
          }

          final report = state.todayReport;
          if (report == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.analytics_outlined, color: AppTheme.goldAccent, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      '인사이트 정보 없음',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '인사이트 분석을 위한 오늘의 뉴스 데이터가 필요합니다.\n먼저 일일 요약 탭에서 리포트를 불러와 주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => state.fetchTodayReport(),
                      icon: const Icon(Icons.refresh, color: AppTheme.darkBg),
                      label: const Text('새로고침'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnalysisCard(context, report.marketSentiment, report.stockTheme),
                const SizedBox(height: 30),
                _buildKeywordsSection(context, report.keywords),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, String sentiment, String theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard,
            Color(0xFF1E293B),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldAccent.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 24),
              const SizedBox(width: 8),
              const Text(
                'AI 시장 진단 분석',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                height: 1.6,
                fontFamily: 'Inter',
              ),
              children: [
                const TextSpan(text: "현재 시장의 분위기는 "),
                TextSpan(
                  text: sentiment,
                  style: const TextStyle(
                    color: AppTheme.goldAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const TextSpan(text: "이며, 유동성이 높다 판단되는 주식의 테마는 "),
                TextSpan(
                  text: theme.isNotEmpty ? theme : "미선정",
                  style: const TextStyle(
                    color: AppTheme.goldAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const TextSpan(text: "입니다."),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Gemini AI 엔진 분석 기준',
                style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.7),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordsSection(BuildContext context, List<dynamic> keywords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up, color: AppTheme.goldAccent, size: 22),
            const SizedBox(width: 8),
            const Text(
              '실시간 인기 검색어 (Top 10)',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Google Pytrends 기준 주요 키워드 및 검색 링크',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        if (keywords.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: const Text(
              '수집된 트렌드 키워드가 없습니다.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: keywords.length,
            itemBuilder: (context, index) {
              final kw = keywords[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.darkBorder,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${kw.ranking}',
                      style: const TextStyle(
                        color: AppTheme.goldAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  title: Text(
                    kw.keyword,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.open_in_new,
                    color: AppTheme.goldAccent,
                    size: 18,
                  ),
                  onTap: () => _launchUrl(kw.searchUrl),
                ),
              );
            },
          ),
      ],
    );
  }
}
