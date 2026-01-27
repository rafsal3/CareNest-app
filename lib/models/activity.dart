import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Activity extends Equatable {
  final String id;
  final String label;
  final bool isCompleted;
  final IconData icon;

  const Activity({
    required this.id,
    required this.label,
    required this.isCompleted,
    required this.icon,
  });

  Activity copyWith({
    String? id,
    String? label,
    bool? isCompleted,
    IconData? icon,
  }) {
    return Activity(
      id: id ?? this.id,
      label: label ?? this.label,
      isCompleted: isCompleted ?? this.isCompleted,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [id, label, isCompleted, icon];
}
