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
  final GetTasksUseCase _getTasks;
  final CreateTaskUseCase _createTask;
  final UpdateTaskUseCase _updateTask;
  final DeleteTaskUseCase _deleteTask;
  final MarkTaskCompleteUseCase _markTaskComplete;

  TasksNotifier(
    this._getTasks,
    this._createTask,
    this._updateTask,
    this._deleteTask,
    this._markTaskComplete,
  );

  @override
  List<TaskEntity> build() => [];

  void loadTasks(
    String userId, {
    Priority? priority,
    bool? status,
  }) {
    _getTasks.call(userId, priorityFilter: priority, statusFilter: status).listen(
      (tasks) {
        state = _sortByDueDate(tasks);
      },
    );
  }

  Future<void> addTask(TaskEntity task) async {
    await _createTask.call(task);
  }

  Future<void> updateTask(TaskEntity task) async {
    await _updateTask.call(task);
  }

  Future<void> deleteTask(String taskId) async {
    await _deleteTask.call(taskId);
  }

  Future<void> markTaskComplete(String taskId, bool isCompleted) async {
    await _markTaskComplete.call(taskId, isCompleted);
  }

  List<TaskEntity> _sortByDueDate(List<TaskEntity> tasks) {
    final sorted = [...tasks];
    sorted.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sorted;
  }
}

final tasksProvider = NotifierProvider<TasksNotifier, List<TaskEntity>>(
  () {
    final getTasks = GetTasksUseCase(TaskRepositoryImpl(''));
    final createTask = CreateTaskUseCase(TaskRepositoryImpl(''));
    final updateTask = UpdateTaskUseCase(TaskRepositoryImpl(''));
    final deleteTask = DeleteTaskUseCase(TaskRepositoryImpl(''));
    final markTaskComplete = MarkTaskCompleteUseCase(TaskRepositoryImpl(''));

    return TasksNotifier(
      getTasks,
      createTask,
      updateTask,
      deleteTask,
      markTaskComplete,
    );
  },
);
