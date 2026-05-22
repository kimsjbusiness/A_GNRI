// 과거 리포트

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../models/report_model.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../core/theme.dart';
import '../core/utils.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReportProvider>();
      if (provider.history.isEmpty && !provider.isLoadingHistory) {
        provider.loadHistory();
      }
    });
  }

  String _formatDateStr(String dateStr) {
    try {
      final parts = dateStr.split('-');
      final dt = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return formatDate(dt);
    } catch (_) {
      return dateStr;
    }
  }

  String _moodType(String sentiment) {
    if (sentiment == '밝음') return 'bright';
    if (sentiment == '어두움') return 'dark';
    return 'neutral';
  }

  Color _moodColor(String type) {
    switch (type) {
      case 'bright':
        return const Color(0xFF27AE60);
      case 'dark':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFFFFA000);
    }
  }

  Color _moodBgColor(String type) {
    switch (type) {
      case 'bright':
        return const Color(0xFFE7F8EC);
      case 'dark':
        return const Color(0xFFFFECEC);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  IconData _moodIcon(String type) {
    switch (type) {
      case 'bright':
        return Icons.trending_up;
      case 'dark':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  void _showReportDetail(BuildContext context, ReportHistoryItem item) {
    final moodType = _moodType(item.marketSentiment);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: _ReportDetailModal(
          dateText: _formatDateStr(item.reportDate),
          summary: item.summaryPreview,
          marketSentiment: item.marketSentiment,
          moodColor: _moodColor(moodType),
          moodBgColor: _moodBgColor(moodType),
          moodIcon: _moodIcon(moodType),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<ReportProvider>();

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
                    Text(
                      '시장 인사이트',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '현재 시장의 분위기와 주요 테마를 확인하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '과거 리포트',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (provider.isLoadingHistory)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (provider.history.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            '과거 리포트가 없습니다',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ...provider.history.map((item) {
                        final moodType = _moodType(item.marketSentiment);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ArchiveCard(
                            dateText: _formatDateStr(item.reportDate),
                            mood: item.marketSentiment,
                            moodColor: _moodColor(moodType),
                            moodBgColor: _moodBgColor(moodType),
                            moodIcon: _moodIcon(moodType),
                            summary: item.summaryPreview,
                            onTap: () => _showReportDetail(context, item),
                          ),
                        );
                      }),
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

// ─── 기록 카드 ────────────────────────────────────────────────────────────────
class _ArchiveCard extends StatelessWidget {
  final String dateText;
  final String mood;
  final Color moodColor;
  final Color moodBgColor;
  final IconData moodIcon;
  final String summary;
  final VoidCallback onTap;

  const _ArchiveCard({
    required this.dateText,
    required this.mood,
    required this.moodColor,
    required this.moodBgColor,
    required this.moodIcon,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: moodBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(moodIcon, size: 12, color: moodColor),
                        const SizedBox(width: 3),
                        Text(
                          mood,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: moodColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textPrimary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─── 리포트 상세 모달 ──────────────────────────────────────────────────────────
class _ReportDetailModal extends StatelessWidget {
  final String dateText;
  final String summary;
  final String marketSentiment;
  final Color moodColor;
  final Color moodBgColor;
  final IconData moodIcon;

  const _ReportDetailModal({
    required this.dateText,
    required this.summary,
    required this.marketSentiment,
    required this.moodColor,
    required this.moodBgColor,
    required this.moodIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: moodBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(moodIcon, size: 12, color: moodColor),
                            const SizedBox(width: 3),
                            Text(
                              marketSentiment,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: moodColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
          ),
          Divider(height: 1, thickness: 1, color: colors.border),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '주요 뉴스',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    summary,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
