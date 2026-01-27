import 'package:flutter/material.dart';

class Medicine {
  final String name;
  final String dosage;
  final String time;
  final String frequency;
  final bool isCompleted;
  final String category;
  final String type; // e.g., 'Capsules', 'Tablets'
  final Color color;
  final String purpose;

  const Medicine({
    required this.name,
    required this.dosage,
    required this.time,
    required this.frequency,
    this.isCompleted = false,
    required this.category,
    required this.type,
    required this.color,
    required this.purpose,
  });
}
