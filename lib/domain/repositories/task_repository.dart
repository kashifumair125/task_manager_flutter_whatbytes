import '../entities/task_entity.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> getTasks(
    String userId, {
    Priority? priorityFilter,
    bool? statusFilter,
  });

  Future<void> createTask(TaskEntity task);

  Future<void> updateTask(TaskEntity task);

  Future<void> deleteTask(String taskId);

  Future<void> markTaskComplete(String taskId, bool isCompleted);
}
