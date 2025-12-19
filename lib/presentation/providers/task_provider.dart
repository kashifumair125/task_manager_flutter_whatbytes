import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/mark_task_complete_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'auth_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid ?? '';
  return TaskRepositoryImpl(userId);
});

final getTasksUseCaseProvider = Provider<GetTasksUseCase>(
  (ref) => GetTasksUseCase(ref.read(taskRepositoryProvider)),
);

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>(
  (ref) => CreateTaskUseCase(ref.read(taskRepositoryProvider)),
);

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>(
  (ref) => UpdateTaskUseCase(ref.read(taskRepositoryProvider)),
);

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>(
  (ref) => DeleteTaskUseCase(ref.read(taskRepositoryProvider)),
);

final markTaskCompleteUseCaseProvider = Provider<MarkTaskCompleteUseCase>(
  (ref) => MarkTaskCompleteUseCase(ref.read(taskRepositoryProvider)),
);

class TasksNotifier extends Notifier<List<TaskEntity>> {
  @override
  List<TaskEntity> build() => [];

  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  void loadTasks({Priority? priority, bool? status}) {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    _repo.getTasks(userId, priorityFilter: priority, statusFilter: status).listen((tasks) {
      state = _sortByDueDate(tasks);
    });
  }

  Future<void> addTask(TaskEntity task) async {
    await _repo.createTask(task);
  }

  Future<void> updateTask(TaskEntity task) async {
    await _repo.updateTask(task);
  }

  Future<void> deleteTask(String taskId) async {
    await _repo.deleteTask(taskId);
  }

  Future<void> markTaskComplete(String taskId, bool isCompleted) async {
    await _repo.markTaskComplete(taskId, isCompleted);
  }

  List<TaskEntity> _sortByDueDate(List<TaskEntity> tasks) {
    final sorted = [...tasks];
    sorted.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sorted;
  }
}

final tasksProvider = NotifierProvider<TasksNotifier, List<TaskEntity>>(TasksNotifier.new);

final completedTasksStreamProvider = StreamProvider.autoDispose<List<TaskEntity>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ref.watch(taskRepositoryProvider).getTasks(userId, statusFilter: true);
});
