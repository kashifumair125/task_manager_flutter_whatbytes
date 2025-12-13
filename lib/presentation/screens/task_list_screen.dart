import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/filter.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/filter_provider.dart';
import '../providers/task_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/glassmorphic_container.dart';
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('${DateFormat('d MMMM').format(DateTime.now())}, My Tasks', style: const TextStyle(fontSize: 16, color: Colors.white)),
              background: GlassmorphicContainer(
                borderRadius: 0,
                child: Container(),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
              IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: _showFilterDialog),
              IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () => ref.read(logoutUseCaseProvider).call()),
            ],
          ),
          tasks.isEmpty
              ? const SliverFillRemaining(child: Center(child: Text('No tasks yet. Create one!')))
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
                            Text(groupTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
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
        child: const Icon(Icons.add, color: Colors.white),
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
    return GlassmorphicContainer(
      child: ListTile(
        leading: Checkbox(value: task.isCompleted, onChanged: (val) => ref.read(tasksProvider.notifier).markTaskComplete(task.id, val ?? false), checkColor: Colors.white, activeColor: Colors.deepPurple),
        title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null, color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(task.description, style: TextStyle(color: Colors.white70)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(label: Text(task.priority.name, style: const TextStyle(color: Colors.white)), backgroundColor: _getPriorityColor(task.priority)),
            IconButton(icon: const Icon(FontAwesomeIcons.penToSquare, color: Colors.white, size: 20), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)))),
            IconButton(icon: const Icon(FontAwesomeIcons.trash, color: Colors.redAccent, size: 20), onPressed: () => ref.read(tasksProvider.notifier).deleteTask(task.id)),
          ],
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
