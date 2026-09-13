import '../../core/utils/date_utils.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.date,
    super.time,
    super.isCompleted,
    required super.createdAt,
    super.completedAt,
  });

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      date: AppDateUtils.normalize(task.date),
      time: task.time,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      completedAt: task.completedAt,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      date: AppDateUtils.fromKey(json['dateKey'] as String? ?? json['date'] as String),
      time: AppTimeUtils.fromStorageString(json['time'] as String?),
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateKey': AppDateUtils.toKey(date),
      'date': AppDateUtils.toKey(date),
      'time': time != null ? AppTimeUtils.toStorageString(time!) : null,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      date: date,
      time: time,
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }
}
