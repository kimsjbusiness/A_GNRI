import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/report_state_provider.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GLOBAL NEWS INTEGRATOR'),
      ),
      body: Consumer<ReportStateProvider>(
        builder: (context, state, child) {
          if (state.hasJustFinishedPipeline) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showMockPushNotification(context);
              state.clearFinishedPipelineFlag();
            });
          }

          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldAccent),
              ),
            );
          }

          if (state.errorMessage != null) {
            return _buildErrorWidget(context, state.errorMessage!, state);
          }

          final report = state.todayReport;
          if (report == null) {
            return _buildEmptyWidget(context, state);
          }

          return RefreshIndicator(
            onRefresh: () => state.fetchTodayReport(),
            color: AppTheme.goldAccent,
            backgroundColor: AppTheme.darkCard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, report.reportDate, state),
                  const SizedBox(height: 24),
                  _buildImagesCarousel(context, report.images),
                  const SizedBox(height: 30),
                  _buildSummariesList(context, report.finalSummariesKr),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String dateStr, ReportStateProvider state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.goldAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
              ),
              child: const Text(
                'TODAY\'S REPORT',
                style: TextStyle(
                  color: AppTheme.goldAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateStr,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            OutlinedButton.icon(
              onPressed: state.isTriggering
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('현재 최신화 진행 중입니다. 잠시만 기다려주세요.'),
                          backgroundColor: AppTheme.darkCard,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  : () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('글로벌 뉴스 분석 및 이미지 생성을 즉시 시작합니다...'),
                          backgroundColor: AppTheme.darkCard,
                          duration: Duration(seconds: 3),
                        ),
                      );
                      final success = await state.triggerTodayPipeline();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('최신화 파이프라인 가동 성공! 완료 시 푸시 알림이 발송됩니다.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('이미 작업이 진행 중이거나 오류가 발생했습니다.'),
                            backgroundColor: AppTheme.errorRed,
                          ),
                        );
                      }
                    },
              icon: state.isTriggering
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldAccent),
                      ),
                    )
                  : const Icon(Icons.refresh, size: 14, color: AppTheme.goldAccent),
              label: Text(
                state.isTriggering ? '최신화 중...' : '지금 최신화 하기',
                style: const TextStyle(fontSize: 11, color: AppTheme.goldAccent, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.goldAccent, width: 1.0),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
        if (state.isTriggering) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  state.pipelineStatusMessage,
                  style: const TextStyle(color: AppTheme.goldAccent, fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.pipelineProgress}%',
                style: const TextStyle(color: AppTheme.goldAccent, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.pipelineProgress / 100.0,
              backgroundColor: AppTheme.darkBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.goldAccent),
              minHeight: 6,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Container(
          height: 3,
          width: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.goldAccent, Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesCarousel(BuildContext context, List<dynamic> images) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI 시각화 분석',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final img = images[index];
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
                        child: Icon(Icons.broken_image, color: AppTheme.textSecondary, size: 40),
                      ),
                    );
                  },
                );
              } catch (e) {
                imageWidget = Container(
                  color: AppTheme.darkBorder,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: AppTheme.textSecondary, size: 40),
                  ),
                );
              }

              return Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
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
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.85),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Text(
                        img.referencedSentence,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummariesList(BuildContext context, List<String> summaries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '핵심 리포트 최종 요약',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(summaries.length, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.darkBorder, width: 1.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
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
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    summaries[index],
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14.5,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message, ReportStateProvider state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 60),
            const SizedBox(height: 16),
            const Text(
              '오류 발생',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => state.fetchTodayReport(),
              icon: const Icon(Icons.refresh, color: AppTheme.darkBg),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context, ReportStateProvider state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description_outlined, color: AppTheme.goldAccent, size: 60),
            const SizedBox(height: 16),
            const Text(
              '오늘의 리포트 없음',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '오늘 생성된 리포트 정보가 존재하지 않습니다.\n백엔드 파이프라인을 구동하여 리포트를 생성해 주세요.',
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

  void showMockPushNotification(BuildContext context) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 12,
        right: 12,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4AF37),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active, color: Color(0xFF0F172A), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'A_GNRI 일일 리포트 도착 🔔',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '오늘의 글로벌 뉴스 요약이 도착했습니다. 지금 읽어보세요!',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                  onPressed: () {
                    overlayEntry.remove();
                  },
                )
              ],
            ),
          ),
        ),
      )
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
