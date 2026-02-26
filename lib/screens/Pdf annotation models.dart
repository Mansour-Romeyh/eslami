import 'package:flutter/material.dart';

// نموذج للتظليل
class PdfHighlight {
  final int pageNumber;
  final Rect bounds;
  final Color color;
  final String id;
  final DateTime createdAt;

  PdfHighlight({
    required this.pageNumber,
    required this.bounds,
    required this.color,
    required this.id,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'bounds': {
      'left': bounds.left,
      'top': bounds.top,
      'right': bounds.right,
      'bottom': bounds.bottom,
    },
    'color': color.value,
    'id': id,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PdfHighlight.fromJson(Map<String, dynamic> json) => PdfHighlight(
    pageNumber: json['pageNumber'],
    bounds: Rect.fromLTRB(
      json['bounds']['left'],
      json['bounds']['top'],
      json['bounds']['right'],
      json['bounds']['bottom'],
    ),
    color: Color(json['color']),
    id: json['id'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

// نموذج للملاحظات
class PdfNote {
  final int pageNumber;
  final Offset position;
  final String text;
  final String id;
  final DateTime createdAt;
  final Color color;

  PdfNote({
    required this.pageNumber,
    required this.position,
    required this.text,
    required this.id,
    required this.createdAt,
    this.color = const Color(0xFFFFEB3B),
  });

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'position': {'dx': position.dx, 'dy': position.dy},
    'text': text,
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'color': color.value,
  };

  factory PdfNote.fromJson(Map<String, dynamic> json) => PdfNote(
    pageNumber: json['pageNumber'],
    position: Offset(json['position']['dx'], json['position']['dy']),
    text: json['text'],
    id: json['id'],
    createdAt: DateTime.parse(json['createdAt']),
    color: Color(json['color']),
  );
}

// نموذج للرسم
class PdfDrawing {
  final int pageNumber;
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final String id;
  final DateTime createdAt;

  PdfDrawing({
    required this.pageNumber,
    required this.points,
    required this.color,
    this.strokeWidth = 3.0,
    required this.id,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'points': points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
    'color': color.value,
    'strokeWidth': strokeWidth,
    'id': id,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PdfDrawing.fromJson(Map<String, dynamic> json) => PdfDrawing(
    pageNumber: json['pageNumber'],
    points: (json['points'] as List)
        .map((p) => Offset(p['dx'], p['dy']))
        .toList(),
    color: Color(json['color']),
    strokeWidth: json['strokeWidth'],
    id: json['id'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

// نموذج لـ Bookmark
class PdfBookmark {
  final int pageNumber;
  final String title;
  final String id;
  final DateTime createdAt;

  PdfBookmark({
    required this.pageNumber,
    required this.title,
    required this.id,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'title': title,
    'id': id,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PdfBookmark.fromJson(Map<String, dynamic> json) => PdfBookmark(
    pageNumber: json['pageNumber'],
    title: json['title'],
    id: json['id'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
