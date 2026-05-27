class DailyReportModel {
  final int reportId;
  final String reportDate;
  final List<String> finalSummariesKr;
  final List<String> detailedSummaries;
  final List<String> top3Sentences;
  final String marketSentiment;
  final String stockTheme;
  final List<TrendingKeywordModel> keywords;
  final List<ReportImageModel> images;

  DailyReportModel({
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

  factory DailyReportModel.fromJson(Map<String, dynamic> json) {
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

    return DailyReportModel(
      reportId: json['report_id'] ?? 0,
      reportDate: json['report_date'] ?? '',
      finalSummariesKr: parsedSummaries,
      detailedSummaries: parsedDetailed,
      top3Sentences: List<String>.from(json['top_3_sentences'] ?? []),
      marketSentiment: json['market_sentiment'] ?? '보통',
      stockTheme: json['stock_theme'] ?? '',
      keywords: (json['keywords'] as List?)
              ?.map((item) => TrendingKeywordModel.fromJson(item))
              .toList() ??
          [],
      images: (json['images'] as List?)
              ?.map((item) => ReportImageModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class TrendingKeywordModel {
  final int ranking;
  final String keyword;
  final String searchUrl;

  TrendingKeywordModel({
    required this.ranking,
    required this.keyword,
    required this.searchUrl,
  });

  factory TrendingKeywordModel.fromJson(Map<String, dynamic> json) {
    return TrendingKeywordModel(
      ranking: json['ranking'] ?? 0,
      keyword: json['keyword'] ?? '',
      searchUrl: json['search_url'] ?? '',
    );
  }
}

class ReportImageModel {
  final String referencedSentence;
  final String imageDataBase64;

  ReportImageModel({
    required this.referencedSentence,
    required this.imageDataBase64,
  });

  factory ReportImageModel.fromJson(Map<String, dynamic> json) {
    return ReportImageModel(
      referencedSentence: json['referenced_sentence'] ?? '',
      imageDataBase64: json['image_data_base64'] ?? '',
    );
  }
}
