import 'dart:convert';

enum IntentType { calendar, todo, note, expense, reminder, chat }

IntentType intentTypeFromString(String value) {
  return IntentType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => IntentType.chat,
  );
}

class IntentResult {
  final IntentType type;
  final String? title;
  final DateTime? datetime;
  final String? location;
  final String? notes;
  final double? amount;
  final String? category;
  final int? triggerOffsetMinutes;
  final int? linkedIntentRef;

  IntentResult({
    required this.type,
    this.title,
    this.datetime,
    this.location,
    this.notes,
    this.amount,
    this.category,
    this.triggerOffsetMinutes,
    this.linkedIntentRef,
  });

  IntentResult copyWith({
    IntentType? type,
    String? title,
    DateTime? datetime,
    String? location,
    String? notes,
    double? amount,
    String? category,
    int? triggerOffsetMinutes,
    int? linkedIntentRef,
  }) {
    return IntentResult(
      type: type ?? this.type,
      title: title ?? this.title,
      datetime: datetime ?? this.datetime,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      triggerOffsetMinutes: triggerOffsetMinutes ?? this.triggerOffsetMinutes,
      linkedIntentRef: linkedIntentRef ?? this.linkedIntentRef,
    );
  }

  factory IntentResult.fromJson(Map<String, dynamic> json) {
    return IntentResult(
      type: intentTypeFromString(json['type'] as String? ?? 'chat'),
      title: json['title'] as String?,
      datetime: json['datetime'] != null
          ? DateTime.tryParse(json['datetime'] as String)
          : null,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      category: json['category'] as String?,
      triggerOffsetMinutes:
          (json['trigger_offset_minutes'] as num?)?.toInt(),
      linkedIntentRef: (json['linked_intent_ref'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'datetime': datetime?.toIso8601String(),
      'location': location,
      'notes': notes,
      'amount': amount,
      'category': category,
      'trigger_offset_minutes': triggerOffsetMinutes,
      'linked_intent_ref': linkedIntentRef,
    };
  }
}

class IntentParseResponse {
  List<IntentResult> intents;

  IntentParseResponse({
    required this.intents,
  });

  factory IntentParseResponse.fromJsonString(String jsonString) {
    try {
      // Normalisasi teks untuk menghapus block markdown jika LLM mengembalikannya
      String cleanedJson = jsonString.trim();
      if (cleanedJson.startsWith('```')) {
        final lines = cleanedJson.split('\n');
        if (lines.first.startsWith('```')) {
          lines.removeAt(0);
        }
        if (lines.last.trim() == '```') {
          lines.removeLast();
        }
        cleanedJson = lines.join('\n').trim();
      }

      final decoded = jsonDecode(cleanedJson) as Map<String, dynamic>;

      final list = (decoded['intents'] as List<dynamic>? ?? [])
          .map((e) => IntentResult.fromJson(e as Map<String, dynamic>))
          .toList();

      return IntentParseResponse(intents: list);
    } catch (_) {
      return IntentParseResponse(intents: []);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'intents': intents.map((e) => e.toJson()).toList(),
    };
  }
}