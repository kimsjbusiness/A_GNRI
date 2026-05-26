// 1면에서 뉴스 요약 정보를 카드 형태로 보여주는 UI 위젯

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/theme.dart';

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
  final Uint8List? imageBytes;

  const NewsCard({
    super.key,
    required this.data,
    this.onTap,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Stack(
                  children: [
                    if (imageBytes != null)
                      Image.memory(
                        imageBytes!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: context.isDark
                                ? const [
                                    Color(0xFF252530),
                                    Color(0xFF1E1E28),
                                    Color(0xFF18181F),
                                  ]
                                : const [
                                    Color(0xFFE3E3E6),
                                    Color(0xFFCFCFD4),
                                    Color(0xFFB8B8BE),
                                  ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 56,
                            color: colors.textSecondary,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        height: 1.35,
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
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF0A0F2C) : colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary ? const Color(0xFF0A0F2C) : colors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isPrimary ? Colors.white : colors.textPrimary,
        ),
      ),
    );
  }
}
