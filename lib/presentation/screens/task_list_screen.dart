import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/filter.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/filter_provider.dart';
import '../providers/task_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTasks());
  }

  void _loadTasks() {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId != null) {
      final filter = ref.read(filterProvider);
      ref.read(tasksProvider.notifier).loadTasks(priority: filter.priority, status: filter.status);
    }
  }

  Map<String, List<TaskEntity>> _groupTasks(List<TaskEntity> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final grouped = <String, List<TaskEntity>>{'Today': [], 'Tomorrow': [], 'This week': []};

    for (final task in tasks) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      if (taskDate.isAtSameMomentAs(today)) {
        grouped['Today']!.add(task);
      } else if (taskDate.isAtSameMomentAs(tomorrow)) {
        grouped['Tomorrow']!.add(task);
      } else {
        grouped['This week']!.add(task);
      }
    }
    return grouped;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => const _FilterDialog(),
    ).then((_) => _loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final groupedTasks = _groupTasks(tasks);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.deepPurple,
            elevation: 2,
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${DateFormat('d MMMM').format(DateTime.now())}, My Tasks',
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.magnifyingGlass, color: Colors.white, size: 24),
                tooltip: 'Search Tasks',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.sliders, color: Colors.white, size: 24),
                tooltip: 'Filter Tasks',
                onPressed: _showFilterDialog,
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.rightFromBracket, color: Colors.white, size: 24),
                tooltip: 'Logout',
                onPressed: () => ref.read(logoutUseCaseProvider).call(),
              ),
            ],
          ),
          tasks.isEmpty
              ? const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 80, color: Colors.deepPurple),
                        SizedBox(height: 20),
                        Text('No tasks yet.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        SizedBox(height: 8),
                        Text('Create one to get started!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final groupTitle = groupedTasks.keys.elementAt(index);
                      final groupTasks = groupedTasks[groupTitle]!;

                      if (groupTasks.isEmpty) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              groupTitle,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ...groupTasks.map((task) => _TaskCard(task: task)),
                          ],
                        ),
                      );
                    },
                    childCount: groupedTasks.length,
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditTaskScreen())),
        backgroundColor: Colors.deepPurple,
        tooltip: 'Add New Task',
        child: const Icon(FontAwesomeIcons.plus, color: Colors.white, size: 28),
      ),
    );
  }
}

class _FilterDialog extends ConsumerWidget {
  const _FilterDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);

    return AlertDialog(
      title: const Text('Filter Tasks'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Priority?>(
            value: filter.priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: [const DropdownMenuItem(value: null, child: Text('All')), ...Priority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name)))],
            onChanged: (val) => ref.read(filterProvider.notifier).state = Filter(priority: val, status: filter.status),
          ),
          DropdownButtonFormField<bool?>(
            value: filter.status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [DropdownMenuItem(value: null, child: Text('All')), DropdownMenuItem(value: true, child: Text('Completed')), DropdownMenuItem(value: false, child: Text('Incomplete'))],
            onChanged: (val) => ref.read(filterProvider.notifier).state = Filter(priority: filter.priority, status: val),
          ),
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final TaskEntity task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted ? Colors.grey.shade300 : Colors.deepPurple.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: task.isCompleted,
            onChanged: (val) => ref.read(tasksProvider.notifier).markTaskComplete(task.id, val ?? false),
            checkColor: Colors.white,
            activeColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey.shade500 : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            task.description,
            style: TextStyle(
              color: task.isCompleted ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: SizedBox(
          width: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.priority.name.toUpperCase(),
                  style: TextStyle(
                    color: _getPriorityColor(task.priority),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(FontAwesomeIcons.penToSquare, color: Colors.deepPurple, size: 18),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
                ),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.trash, color: Colors.redAccent, size: 18),
                onPressed: () => ref.read(tasksProvider.notifier).deleteTask(task.id),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
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
}
