import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/api_service.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../core/theme.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _calendarOpen = false;
  DailyReport? _report;
  bool _isLoading = false;
  bool _notFound = false;

  Future<void> _loadReport(DateTime date) async {
    setState(() {
      _isLoading = true;
      _notFound = false;
      _report = null;
      _calendarOpen = false;
    });
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final report = await ApiService.getReportByDate(dateStr);
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _notFound = true;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}년 ${d.month}월 ${d.day}일';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Divider(height: 1, thickness: 1, color: colors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('과거 리포트',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('날짜를 선택해 해당 날의 리포트를 확인하세요',
                        style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                    const SizedBox(height: 20),

                    // 날짜 선택 토글 바
                    GestureDetector(
                      onTap: () => setState(() => _calendarOpen = !_calendarOpen),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 18, color: colors.textSecondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _formatDate(_selectedDate),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary),
                              ),
                            ),
                            AnimatedRotation(
                              turns: _calendarOpen ? 0.25 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(Icons.chevron_right,
                                  size: 18, color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 인라인 달력
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: _calendarOpen
                          ? Container(
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.border),
                              ),
                              child: CalendarDatePicker(
                                initialDate: _selectedDate,
                                firstDate: DateTime(2024, 1, 1),
                                lastDate: DateTime.now(),
                                onDateChanged: (date) {
                                  setState(() => _selectedDate = date);
                                  _loadReport(date);
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 20),

                    // 리포트 콘텐츠
                    if (_isLoading)
                      const Center(
                          child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator()))
                    else if (_notFound)
                      _EmptyState(
                        icon: Icons.search_off,
                        message: '해당 날짜의 리포트가 없습니다',
                        colors: colors,
                      )
                    else if (_report != null)
                      _ReportContent(report: _report!, colors: colors)
                    else
                      _EmptyState(
                        icon: Icons.calendar_today,
                        message: '날짜를 선택하면 리포트를 볼 수 있어요',
                        colors: colors,
                      ),
                  ],
                ),
              ),
            ),
            const BottomNavBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final AppColors colors;

  const _EmptyState({required this.icon, required this.message, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(icon, size: 48, color: colors.textSecondary),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(fontSize: 14, color: colors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  final DailyReport report;
  final AppColors colors;

  const _ReportContent({required this.report, required this.colors});

  String _moodType(String s) =>
      s == '밝음' ? 'bright' : s == '어두움' ? 'dark' : 'neutral';

  Color _moodColor(String t) => t == 'bright'
      ? const Color(0xFF27AE60)
      : t == 'dark'
          ? const Color(0xFFE53935)
          : const Color(0xFFFFA000);

  Color _moodBgColor(String t) => t == 'bright'
      ? const Color(0xFFE7F8EC)
      : t == 'dark'
          ? const Color(0xFFFFECEC)
          : const Color(0xFFFFF3E0);

  IconData _moodIcon(String t) => t == 'bright'
      ? Icons.trending_up
      : t == 'dark'
          ? Icons.trending_down
          : Icons.trending_flat;

  @override
  Widget build(BuildContext context) {
    final moodType = _moodType(report.marketSentiment);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 + 감성 뱃지
        Row(
          children: [
            Expanded(
              child: Text(report.reportDate,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _moodBgColor(moodType),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_moodIcon(moodType), size: 13, color: _moodColor(moodType)),
                  const SizedBox(width: 4),
                  Text(report.marketSentiment,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _moodColor(moodType))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 핵심 요약
        if (report.finalSummariesKr.isNotEmpty) ...[
          _SectionTitle(title: '핵심 뉴스 요약', colors: colors),
          const SizedBox(height: 10),
          ...List.generate(report.finalSummariesKr.length, (i) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: colors.textPrimary, shape: BoxShape.circle),
                  child: Text('${i + 1}',
                      style: TextStyle(
                          color: colors.background,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(report.finalSummariesKr[i],
                      style: TextStyle(
                          fontSize: 13, color: colors.textPrimary, height: 1.5)),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
        ],

        // AI 이미지 캐러셀
        if (report.images.isNotEmpty) ...[
          _SectionTitle(title: 'AI 시각화 이미지', colors: colors),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: report.images.length,
              itemBuilder: (context, i) {
                final img = report.images[i];
                Widget imageWidget;
                try {
                  imageWidget = Image.memory(
                    base64Decode(img.imageDataBase64),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                } catch (_) {
                  imageWidget = Icon(Icons.broken_image,
                      color: colors.textSecondary);
                }
                return Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(child: imageWidget),
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                          child: Text(img.referencedSentence,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 시장 진단
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(title: 'AI 시장 진단', colors: colors),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                      fontSize: 14, color: colors.textPrimary, height: 1.5),
                  children: [
                    const TextSpan(text: '해당 날짜의 시장 분위기는 '),
                    TextSpan(
                        text: report.marketSentiment,
                        style: TextStyle(
                            color: _moodColor(moodType),
                            fontWeight: FontWeight.bold)),
                    const TextSpan(text: '이며, 주목할 테마는 '),
                    TextSpan(
                        text: report.stockTheme.isNotEmpty
                            ? report.stockTheme
                            : '미선정',
                        style: TextStyle(
                            color: _moodColor(moodType),
                            fontWeight: FontWeight.bold)),
                    const TextSpan(text: '입니다.'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 키워드
        if (report.keywords.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionTitle(title: '인기 트렌드 키워드', colors: colors),
          const SizedBox(height: 10),
          ...report.keywords.map((kw) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: ListTile(
              dense: true,
              leading: Text('${kw.ranking}',
                  style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold)),
              title: Text(kw.keyword,
                  style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600)),
            ),
          )),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final AppColors colors;
  const _SectionTitle({required this.title, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary));
  }
}
