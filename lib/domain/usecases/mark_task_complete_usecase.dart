import '../repositories/task_repository.dart';

class MarkTaskCompleteUseCase {
  final TaskRepository repository;

  MarkTaskCompleteUseCase(this.repository);

  Future<void> call(String taskId, bool isCompleted) {
    return repository.markTaskComplete(taskId, isCompleted);
  }
}
