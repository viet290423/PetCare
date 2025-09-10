import 'dart:ui';

import 'package:flutter/material.dart';

class PetTipsRequest {
  final String name;
  final String species;
  final int ageMonths;
  final double weightKg;
  final List<String> conditions;
  final String mode;

  PetTipsRequest({
    required this.name,
    required this.species,
    required this.ageMonths,
    required this.weightKg,
    required this.conditions,
    this.mode = 'tips',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'ageMonths': ageMonths,
      'weightKg': weightKg,
      'conditions': conditions,
      'mode': mode,
    };
  }

  factory PetTipsRequest.fromJson(Map<String, dynamic> json) {
    return PetTipsRequest(
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      ageMonths: json['ageMonths'] ?? 0,
      weightKg: (json['weightKg'] ?? 0.0).toDouble(),
      conditions: List<String>.from(json['conditions'] ?? []),
      mode: json['mode'] ?? 'tips',
    );
  }
}

class PetTipsResponse {
  final String tip;
  final PetTipsCategories? categories;

  PetTipsResponse({required this.tip, this.categories});

  factory PetTipsResponse.fromJson(Map<String, dynamic> json) {
    final tip = json['tip'] ?? '';
    return PetTipsResponse(tip: tip, categories: _parseCategories(tip));
  }

  Map<String, dynamic> toJson() {
    return {'tip': tip, 'categories': categories?.toJson()};
  }

  static PetTipsCategories? _parseCategories(String tip) {
    try {
      // Tìm các section dựa trên tiêu đề
      final healthMatch = RegExp(
        r'(\*\*Sức kh(?:ỏe|oẻ)\*\*|Sức kh(?:ỏe|oẻ):)',
        caseSensitive: false,
      ).firstMatch(tip);
      final nutritionMatch = RegExp(
        r'\*\*Dinh dưỡng\*\*|Dinh dưỡng:',
        caseSensitive: false,
      ).firstMatch(tip);
      final careMatch = RegExp(
        r'\*\*Chăm sóc\*\*|Chăm sóc:',
        caseSensitive: false,
      ).firstMatch(tip);

      if (healthMatch == null && nutritionMatch == null && careMatch == null) {
        return null;
      }

      String healthContent = '';
      String nutritionContent = '';
      String careContent = '';

      // Extract health content
      if (healthMatch != null) {
        final start = healthMatch.start;
        final end = nutritionMatch?.start ?? careMatch?.start ?? tip.length;
        healthContent = tip.substring(start, end).trim();
        healthContent = healthContent
            .replaceFirst(RegExp(r'\*\*Sức khỏe\*\*|Sức khỏe:'), '')
            .trim();
      }

      // Extract nutrition content
      if (nutritionMatch != null) {
        final start = nutritionMatch.start;
        final end = careMatch?.start ?? tip.length;
        nutritionContent = tip.substring(start, end).trim();
        nutritionContent = nutritionContent
            .replaceFirst(RegExp(r'\*\*Dinh dưỡng\*\*|Dinh dưỡng:'), '')
            .trim();
      }

      // Extract care content
      if (careMatch != null) {
        final start = careMatch.start;
        careContent = tip.substring(start).trim();
        careContent = careContent
            .replaceFirst(RegExp(r'\*\*Chăm sóc\*\*|Chăm sóc:'), '')
            .trim();
      }

      print('=== PARSING AI RESPONSE ===');
      print('Health content length: ${healthContent.length}');
      print('Nutrition content length: ${nutritionContent.length}');
      print('Care content length: ${careContent.length}');

      final healthCards = healthContent.isNotEmpty
          ? _parseCardsFromContent(healthContent, 'health')
          : null;
      final nutritionCards = nutritionContent.isNotEmpty
          ? _parseCardsFromContent(nutritionContent, 'nutrition')
          : null;
      final careCards = careContent.isNotEmpty
          ? _parseCardsFromContent(careContent, 'care')
          : null;

      print('Health cards: ${healthCards?.length ?? 0}');
      print('Nutrition cards: ${nutritionCards?.length ?? 0}');
      print('Care cards: ${careCards?.length ?? 0}');

      return PetTipsCategories(
        health: healthContent.isNotEmpty ? healthContent : null,
        nutrition: nutritionContent.isNotEmpty ? nutritionContent : null,
        care: careContent.isNotEmpty ? careContent : null,
        healthCards: healthCards,
        nutritionCards: nutritionCards,
        careCards: careCards,
      );
    } catch (e) {
      print('Error parsing categories: $e');
      return null;
    }
  }

  static List<PetTipCard> _parseCardsFromContent(
    String content,
    String category,
  ) {
    try {
      final cards = <PetTipCard>[];

      // Tách nội dung thành các đoạn dựa trên dấu gạch ngang
      final lines = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      for (String line in lines) {
        final trimmedLine = line.trim();

        // Kiểm tra xem có phải là đầu mục không (bắt đầu bằng dấu gạch ngang)
        if (trimmedLine.startsWith('- ')) {
          final cardContent = trimmedLine.substring(2).trim();

          // Tách tiêu đề và mô tả (nếu có dấu hai chấm)
          if (cardContent.contains(':')) {
            final parts = cardContent.split(':');
            final title = parts[0].trim();
            final description = parts.length > 1
                ? parts.sublist(1).join(':').trim()
                : '';

            cards.add(_createCardFromContent(title, description, category));
          } else {
            // Nếu không có dấu hai chấm, toàn bộ là tiêu đề
            cards.add(_createCardFromContent(cardContent, '', category));
          }
        }
        // Kiểm tra xem có phải là tiêu đề không (có **text**)
        else if (trimmedLine.startsWith('**') && trimmedLine.endsWith('**')) {
          final title = trimmedLine.replaceAll('**', '').trim();
          cards.add(_createCardFromContent(title, '', category));
        }
        // Kiểm tra xem có phải là bullet point không
        else if (trimmedLine.startsWith('* ')) {
          final cardContent = trimmedLine.substring(2).trim();

          if (cardContent.contains(':')) {
            final parts = cardContent.split(':');
            final title = parts[0].trim();
            final description = parts.length > 1
                ? parts.sublist(1).join(':').trim()
                : '';

            cards.add(_createCardFromContent(title, description, category));
          } else {
            cards.add(_createCardFromContent(cardContent, '', category));
          }
        }
        // Kiểm tra xem có phải là số thứ tự không
        else if (RegExp(r'^\d+\.').hasMatch(trimmedLine)) {
          final cardContent = trimmedLine
              .replaceFirst(RegExp(r'^\d+\.\s*'), '')
              .trim();

          if (cardContent.contains(':')) {
            final parts = cardContent.split(':');
            final title = parts[0].trim();
            final description = parts.length > 1
                ? parts.sublist(1).join(':').trim()
                : '';

            cards.add(_createCardFromContent(title, description, category));
          } else {
            cards.add(_createCardFromContent(cardContent, '', category));
          }
        }
      }

      // Nếu không có đầu mục nào, tạo một card duy nhất với toàn bộ nội dung
      if (cards.isEmpty && content.isNotEmpty) {
        cards.add(
          _createCardFromContent(_getDefaultTitle(category), content, category),
        );
      }

      print('Parsed ${cards.length} cards for category $category');
      for (int i = 0; i < cards.length; i++) {
        print('Card $i: ${cards[i].title}');
      }

      return cards;
    } catch (e) {
      print('Error parsing cards from content: $e');
      return [];
    }
  }

  static PetTipCard _createCardFromContent(
    String title,
    String description,
    String category,
  ) {
    // Làm sạch title và description
    final cleanTitle = title.replaceAll(RegExp(r'[:\-•]'), '').trim();
    final cleanDescription = description.trim();

    // Xác định icon và color dựa trên category và title
    final iconInfo = _getIconAndColor(category, cleanTitle);

    return PetTipCard(
      title: cleanTitle,
      description: cleanDescription,
      icon: iconInfo['icon']!,
      color: iconInfo['color']!,
    );
  }

  static String _getDefaultTitle(String category) {
    switch (category) {
      case 'health':
        return 'Sức khỏe';
      case 'nutrition':
        return 'Dinh dưỡng';
      case 'care':
        return 'Chăm sóc';
      default:
        return 'Tips';
    }
  }

  static Map<String, String> _getIconAndColor(String category, String title) {
    final lowerTitle = title.toLowerCase();

    // Health category
    if (category == 'health') {
      if (lowerTitle.contains('khám') ||
          lowerTitle.contains('kiểm tra') ||
          lowerTitle.contains('định kỳ')) {
        return {'icon': 'medical_services', 'color': 'blue'};
      } else if (lowerTitle.contains('phòng bệnh') ||
          lowerTitle.contains('vaccine') ||
          lowerTitle.contains('phòng ngừa')) {
        return {'icon': 'vaccines', 'color': 'green'};
      } else if (lowerTitle.contains('triệu chứng') ||
          lowerTitle.contains('theo dõi') ||
          lowerTitle.contains('quan sát')) {
        return {'icon': 'monitor_heart', 'color': 'red'};
      } else if (lowerTitle.contains('dị ứng') ||
          lowerTitle.contains('allergy')) {
        return {'icon': 'warning', 'color': 'red'};
      } else {
        return {'icon': 'health_and_safety', 'color': 'red'};
      }
    }

    // Nutrition category
    if (category == 'nutrition') {
      if (lowerTitle.contains('thực phẩm') ||
          lowerTitle.contains('nên dùng') ||
          lowerTitle.contains('ăn')) {
        return {'icon': 'restaurant', 'color': 'orange'};
      } else if (lowerTitle.contains('nên tránh') ||
          lowerTitle.contains('tránh') ||
          lowerTitle.contains('không nên')) {
        return {'icon': 'no_food', 'color': 'red'};
      } else if (lowerTitle.contains('khẩu phần') ||
          lowerTitle.contains('lượng') ||
          lowerTitle.contains('định lượng')) {
        return {'icon': 'scale', 'color': 'green'};
      } else if (lowerTitle.contains('nước') || lowerTitle.contains('uống')) {
        return {'icon': 'water_drop', 'color': 'blue'};
      } else {
        return {'icon': 'restaurant_menu', 'color': 'orange'};
      }
    }

    // Care category
    if (category == 'care') {
      if (lowerTitle.contains('vệ sinh') ||
          lowerTitle.contains('tắm') ||
          lowerTitle.contains('làm sạch')) {
        return {'icon': 'shower', 'color': 'blue'};
      } else if (lowerTitle.contains('môi trường') ||
          lowerTitle.contains('nhà') ||
          lowerTitle.contains('sống')) {
        return {'icon': 'home', 'color': 'brown'};
      } else if (lowerTitle.contains('vận động') ||
          lowerTitle.contains('chơi') ||
          lowerTitle.contains('tinh thần')) {
        return {'icon': 'fitness_center', 'color': 'green'};
      } else if (lowerTitle.contains('tinh thần') ||
          lowerTitle.contains('stress') ||
          lowerTitle.contains('tâm lý')) {
        return {'icon': 'psychology', 'color': 'purple'};
      } else {
        return {'icon': 'spa', 'color': 'green'};
      }
    }

    return {'icon': 'lightbulb', 'color': 'blue'};
  }
}

class PetTipsCategories {
  final String? health;
  final String? nutrition;
  final String? care;
  final List<PetTipCard>? healthCards;
  final List<PetTipCard>? nutritionCards;
  final List<PetTipCard>? careCards;

  PetTipsCategories({
    this.health,
    this.nutrition,
    this.care,
    this.healthCards,
    this.nutritionCards,
    this.careCards,
  });

  Map<String, dynamic> toJson() {
    return {
      'health': health,
      'nutrition': nutrition,
      'care': care,
      'healthCards': healthCards?.map((e) => e.toJson()).toList(),
      'nutritionCards': nutritionCards?.map((e) => e.toJson()).toList(),
      'careCards': careCards?.map((e) => e.toJson()).toList(),
    };
  }

  factory PetTipsCategories.fromJson(Map<String, dynamic> json) {
    return PetTipsCategories(
      health: json['health'],
      nutrition: json['nutrition'],
      care: json['care'],
      healthCards: json['healthCards'] != null
          ? (json['healthCards'] as List)
                .map((e) => PetTipCard.fromJson(e))
                .toList()
          : null,
      nutritionCards: json['nutritionCards'] != null
          ? (json['nutritionCards'] as List)
                .map((e) => PetTipCard.fromJson(e))
                .toList()
          : null,
      careCards: json['careCards'] != null
          ? (json['careCards'] as List)
                .map((e) => PetTipCard.fromJson(e))
                .toList()
          : null,
    );
  }

  bool get hasAnyContent => health != null || nutrition != null || care != null;

  bool get hasAnyCards =>
      (healthCards?.isNotEmpty ?? false) ||
      (nutritionCards?.isNotEmpty ?? false) ||
      (careCards?.isNotEmpty ?? false);
}

class PetTipCard {
  final String title;
  final String description;
  final String icon;
  final String color;

  PetTipCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
    };
  }

  factory PetTipCard.fromJson(Map<String, dynamic> json) {
    return PetTipCard(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'lightbulb',
      color: json['color'] ?? 'blue',
    );
  }
}

class PetTip {
  final String id;
  final String petId;
  final String tip;
  final DateTime createdAt;
  final String category;

  PetTip({
    required this.id,
    required this.petId,
    required this.tip,
    required this.createdAt,
    required this.category,
  });

  factory PetTip.fromJson(Map<String, dynamic> json) {
    return PetTip(
      id: json['id'] ?? '',
      petId: json['petId'] ?? '',
      tip: json['tip'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      category: json['category'] ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'tip': tip,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }
}

class PetGrowthResponse {
  final String tip;
  final bool hasWarning;
  final String?
  warningType; // 'sudden_increase', 'sudden_decrease', 'gradual_increase', 'gradual_decrease'

  PetGrowthResponse({
    required this.tip,
    this.hasWarning = false,
    this.warningType,
  });

  factory PetGrowthResponse.fromJson(Map<String, dynamic> json) {
    return PetGrowthResponse(
      tip: json['tip'] ?? '',
      hasWarning: json['hasWarning'] ?? false,
      warningType: json['warningType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'tip': tip, 'hasWarning': hasWarning, 'warningType': warningType};
  }

  /// Lấy màu sắc phù hợp với loại cảnh báo
  Color get warningColor {
    switch (warningType) {
      case 'sudden_increase':
      case 'gradual_increase':
        return Colors.orange;
      case 'sudden_decrease':
      case 'gradual_decrease':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  /// Lấy icon phù hợp với loại cảnh báo
  IconData get warningIcon {
    switch (warningType) {
      case 'sudden_increase':
      case 'gradual_increase':
        return Icons.trending_up;
      case 'sudden_decrease':
      case 'gradual_decrease':
        return Icons.trending_down;
      default:
        return Icons.warning;
    }
  }

  /// Lấy text mô tả loại cảnh báo
  String get warningDescription {
    switch (warningType) {
      case 'sudden_increase':
        return 'Tăng cân đột ngột';
      case 'sudden_decrease':
        return 'Giảm cân đột ngột';
      case 'gradual_increase':
        return 'Tăng cân liên tục';
      case 'gradual_decrease':
        return 'Giảm cân liên tục';
      default:
        return 'Thay đổi cân nặng';
    }
  }
}
