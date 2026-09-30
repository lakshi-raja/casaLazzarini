import 'package:flutter/foundation.dart';

@immutable
class Suite {
  final String id;
  final String code;
  final String displayName;
  final bool active;
  final DateTime createdAt;

  const Suite({
    required this.id,
    required this.code,
    required this.displayName,
    required this.active,
    required this.createdAt,
  });

  factory Suite.fromMap(Map<String, dynamic> map) {
    return Suite(
      id: map['id'] as String,
      code: map['code'] as String,
      displayName: map['display_name'] as String,
      active: map['active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
