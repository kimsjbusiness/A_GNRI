/// 1면에서 뉴스 요약 정보를 카드 형태로 보여주는 UI 위젯
/// 뉴스 데이터(국가, 카테고리, 제목, 요약)를 카드 UI로 표현하는 위젯

import 'package:flutter/material.dart';

class NewsCardData {
  final String country;
  final String category;
  final String title;
  final String summary;
  final List<String> keywords;

  const NewsCardData({
    required this.country,
    required this.category,
    required this.title,
    required this.summary,
    this.keywords = const [],
  });
}

class NewsCard extends StatelessWidget {
  final NewsCardData data;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tags = data.keywords.isNotEmpty
        ? data.keywords
        : [data.country, data.category];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE3E3E8)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE3E3E6),
                            Color(0xFFCFCFD4),
                            Color(0xFFB8B8BE),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 56,
                          color: Color(0xFF8C8C94),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 14,
                      bottom: 14,
                      right: 14,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tag = entry.value;

                          return KeywordChip(
                            label: tag,
                            isPrimary: index == 0,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.summary,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7A7A85),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KeywordChip extends StatelessWidget {
  final String label;
  final bool isPrimary;

  const KeywordChip({
    super.key,
    required this.label,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF0A0F2C) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary
              ? const Color(0xFF0A0F2C)
              : const Color(0xFFD9D9DF),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isPrimary ? Colors.white : const Color(0xFF333333),
        ),
      ),
    );
  }
}