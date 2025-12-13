import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Stream<List<TaskEntity>> call(
    String userId, {
    Priority? priorityFilter,
    bool? statusFilter,
  }) {
    return repository.getTasks(
      userId,
      priorityFilter: priorityFilter,
      statusFilter: statusFilter,
    );
  }
}
