import 'package:equatable/equatable.dart';

enum Priority { low, medium, high }

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final Priority priority;
  final bool isCompleted;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [id, title, description, dueDate, priority, isCompleted];
}