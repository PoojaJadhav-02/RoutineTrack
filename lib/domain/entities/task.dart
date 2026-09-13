import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime date; // Normalized yyyy-MM-dd
  final TimeOfDay? time;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.time,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearTime = false,
    bool clearDescription = false,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      date: date ?? this.date,
      time: clearTime ? null : (time ?? this.time),
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          date == other.date &&
          time == other.time &&
          isCompleted == other.isCompleted &&
          createdAt == other.createdAt &&
          completedAt == other.completedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      date.hashCode ^
      time.hashCode ^
      isCompleted.hashCode ^
      createdAt.hashCode ^
      completedAt.hashCode;
}
