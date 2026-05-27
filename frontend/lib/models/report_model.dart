class ReportKeyword {
  final int ranking;
  final String keyword;
  final String searchUrl;

  const ReportKeyword({
    required this.ranking,
    required this.keyword,
    required this.searchUrl,
  });

  factory ReportKeyword.fromJson(Map<String, dynamic> json) => ReportKeyword(
        ranking: json['ranking'] as int,
        keyword: json['keyword'] as String,
        searchUrl: json['search_url'] as String,
      );
}

class ReportImage {
  final String referencedSentence;
  final String imageDataBase64;

  const ReportImage({
    required this.referencedSentence,
    required this.imageDataBase64,
  });

  factory ReportImage.fromJson(Map<String, dynamic> json) => ReportImage(
        referencedSentence: json['referenced_sentence'] as String,
        imageDataBase64: json['image_data_base64'] as String,
      );
}

class DailyReport {
  final int reportId;
  final String reportDate;
  final List<String> finalSummariesKr;
  final List<String> detailedSummaries;
  final List<String> top3Sentences;
  final String marketSentiment;
  final String stockTheme;
  final List<ReportKeyword> keywords;
  final List<ReportImage> images;

  const DailyReport({
    required this.reportId,
    required this.reportDate,
    required this.finalSummariesKr,
    required this.detailedSummaries,
    required this.top3Sentences,
    required this.marketSentiment,
    required this.stockTheme,
    required this.keywords,
    required this.images,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    final rawSummaries = List<String>.from(json['final_summaries_kr'] ?? []);
    final List<String> parsedSummaries = [];
    final List<String> parsedDetailed = [];

    for (final s in rawSummaries) {
      if (s.contains('||')) {
        final parts = s.split('||');
        parsedSummaries.add(parts[0].trim());
        parsedDetailed.add(parts[1].trim());
      } else {
        parsedSummaries.add(s);
        parsedDetailed.add(s);
      }
    }

    return DailyReport(
      reportId: json['report_id'] as int,
      reportDate: json['report_date'] as String,
      finalSummariesKr: parsedSummaries,
      detailedSummaries: parsedDetailed,
      top3Sentences: List<String>.from(json['top_3_sentences'] as List),
      marketSentiment: (json['market_sentiment'] as String?) ?? '보통',
      stockTheme: json['stock_theme'] as String,
      keywords: (json['keywords'] as List? ?? [])
          .map((e) => ReportKeyword.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List? ?? [])
          .map((e) => ReportImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReportHistoryItem {
  final String reportDate;
  final String marketSentiment;
  final String summaryPreview;

  const ReportHistoryItem({
    required this.reportDate,
    required this.marketSentiment,
    required this.summaryPreview,
  });

  factory ReportHistoryItem.fromJson(Map<String, dynamic> json) =>
      ReportHistoryItem(
        reportDate: json['report_date'] as String,
        marketSentiment: (json['market_sentiment'] as String?) ?? '보통',
        summaryPreview: json['summary_preview'] as String,
      );
}
