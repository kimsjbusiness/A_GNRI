import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;
import '../../data/providers/report_state_provider.dart';
import '../../core/theme/app_theme.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportStateProvider>().clearSearchedReport();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.goldAccent,
              onPrimary: AppTheme.darkBg,
              surface: AppTheme.darkCard,
              onSurface: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: AppTheme.darkBg,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      final dateStr = DateFormat('yyyy-MM-dd').format(picked);
      context.read<ReportStateProvider>().fetchPastReport(dateStr);
    }
  }

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
    final state = context.watch<ReportStateProvider>();
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PAST REPORTS ARCHIVE'),
      ),
      body: Column(
        children: [
          _buildDatePickerSection(context, formattedDate),
          const Divider(color: AppTheme.darkBorder, height: 1),
          Expanded(
            child: _buildReportContentSection(state),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerSection(BuildContext context, String formattedDate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      color: AppTheme.darkCard,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '조회 대상 날짜',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_month, color: AppTheme.darkBg),
            label: const Text('날짜 선택'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContentSection(ReportStateProvider state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldAccent),
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, color: AppTheme.textSecondary, size: 60),
              const SizedBox(height: 16),
              const Text(
                '조회 실패',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final report = state.searchedReport;
    if (report == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, color: AppTheme.goldAccent, size: 50),
              const SizedBox(height: 16),
              const Text(
                '보고서 아카이브 조회',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '위의 \'날짜 선택\' 버튼을 눌러\n과거 생성되었던 일일 뉴스 통합 리포트를 검색해 보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4),
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
          // 1. Summaries
          const Text(
            '핵심 뉴스 최종 요약',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(report.finalSummariesKr.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppTheme.goldAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppTheme.darkBg,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      report.finalSummariesKr[index],
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // 2. Images Carousel
          if (report.images.isNotEmpty) ...[
            const Text(
              'AI 시각화 분석 이미지',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: report.images.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final img = report.images[index];
                  final base64Str = img.imageDataBase64;
                  
                  Widget imageWidget;
                  try {
                    final bytes = base64Decode(base64Str);
                    imageWidget = Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.darkBorder,
                          child: const Center(
                            child: Icon(Icons.broken_image, color: AppTheme.textSecondary),
                          ),
                        );
                      },
                    );
                  } catch (e) {
                    imageWidget = Container(
                      color: AppTheme.darkBorder,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: AppTheme.textSecondary),
                      ),
                    );
                  }

                  return Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(child: imageWidget),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.85),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Text(
                            img.referencedSentence,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 3. Sentiment Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.goldAccent.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'AI 시장 진단 분석',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14.5,
                      height: 1.5,
                      fontFamily: 'Inter',
                    ),
                    children: [
                      const TextSpan(text: "해당 날짜의 시장 분위기는 "),
                      TextSpan(
                        text: report.marketSentiment,
                        style: const TextStyle(
                          color: AppTheme.goldAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: "이며, 유동성이 높다 판단되는 주식의 테마는 "),
                      TextSpan(
                        text: report.stockTheme.isNotEmpty ? report.stockTheme : "미선정",
                        style: const TextStyle(
                          color: AppTheme.goldAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: "입니다."),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Keywords
          if (report.keywords.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.trending_up, color: AppTheme.goldAccent, size: 20),
                SizedBox(width: 6),
                Text(
                  '인기 트렌드 키워드',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(report.keywords.length, (index) {
              final kw = report.keywords[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: ListTile(
                  dense: true,
                  leading: Text(
                    '${kw.ranking}',
                    style: const TextStyle(
                      color: AppTheme.goldAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: Text(
                    kw.keyword,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.open_in_new, color: AppTheme.goldAccent, size: 16),
                  onTap: () => _launchUrl(kw.searchUrl),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}
