import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.dueDate,
    required super.priority,
    super.isCompleted,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        dueDate: DateTime.parse(json['dueDate']),
        priority: Priority.values.byName(json['priority']),
        isCompleted: json['isCompleted'] ?? false,
      );

  factory TaskModel.fromEntity(TaskEntity entity) => TaskModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        dueDate: entity.dueDate,
        priority: entity.priority,
        isCompleted: entity.isCompleted,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority.name,
        'isCompleted': isCompleted,
      };

  TaskEntity toEntity() => this;
}
