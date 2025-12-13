import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  Priority? _priorityFilter;
  bool? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authStateProvider).value?.uid;
      if (userId != null) {
        ref.read(tasksProvider.notifier).loadTasks(userId);
      }
    });
  }

  Map<String, List<TaskEntity>> _groupTasks(List<TaskEntity> tasks) {
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final thisWeekEnd = today.add(Duration(days: 7));

    return {
      'Today': tasks
          .where((t) {
            final taskDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
            final todayDate = DateTime(today.year, today.month, today.day);
            return taskDate.isAtSameMomentAs(todayDate);
          })
          .toList(),
      'Tomorrow': tasks
          .where((t) {
            final taskDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
            return taskDate.isAtSameMomentAs(tomorrow);
          })
          .toList(),
      'This Week': tasks
          .where((t) {
            final taskDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
            return taskDate.isAfter(tomorrow) && taskDate.isBefore(thisWeekEnd);
          })
          .toList(),
    };
  }

  Color _getPriorityColor(Priority p) {
    switch (p) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }

  void _logout() async {
    await ref.read(logoutUseCaseProvider).call();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final groupedTasks = _groupTasks(tasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          PopupMenuButton<Priority?>(
            initialValue: _priorityFilter,
            onSelected: (Priority? value) {
              setState(() => _priorityFilter = value);
              final userId = ref.read(authStateProvider).value?.uid;
              if (userId != null) {
                ref.read(tasksProvider.notifier).loadTasks(
                  userId,
                  priority: value,
                  status: _statusFilter,
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [null, ...Priority.values]
                  .map((p) => PopupMenuItem<Priority?>(
                        value: p,
                        child: Text(p?.name ?? 'All Priority'),
                      ))
                  .toList();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(_priorityFilter?.name ?? 'Priority'),
              ),
            ),
          ),
          PopupMenuButton<bool?>(
            initialValue: _statusFilter,
            onSelected: (bool? value) {
              setState(() => _statusFilter = value);
              final userId = ref.read(authStateProvider).value?.uid;
              if (userId != null) {
                ref.read(tasksProvider.notifier).loadTasks(
                  userId,
                  priority: _priorityFilter,
                  status: value,
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [null, true, false]
                  .map((s) => PopupMenuItem<bool?>(
                        value: s,
                        child: Text(
                          s == null ? 'All Status' : s ? 'Completed' : 'Incomplete',
                        ),
                      ))
                  .toList();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(_statusFilter == null ? 'Status' : _statusFilter! ? 'Completed' : 'Incomplete'),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text('No tasks yet. Create one to get started!'),
            )
          : ListView(
              children: groupedTasks.entries.map((entry) {
                if (entry.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                      ),
                    ),
                    ...entry.value.map((task) {
                      return ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (val) {
                            ref.read(tasksProvider.notifier).markTaskComplete(task.id, val ?? false);
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          '${DateFormat('d MMM').format(task.dueDate)} • ${task.description}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: SizedBox(
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(
                                  task.priority.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: _getPriorityColor(task.priority),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditTaskScreen(task: task),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () => ref
                                    .read(tasksProvider.notifier)
                                    .deleteTask(task.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditTaskScreen()),
        ),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
