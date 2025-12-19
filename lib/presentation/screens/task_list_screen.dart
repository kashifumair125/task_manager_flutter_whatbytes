import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../domain/entities/filter.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/filter_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'edit_task_screen.dart';
import 'history_screen.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTasks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTasks() {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId != null) {
      final filter = ref.read(filterProvider);
      ref.read(tasksProvider.notifier).loadTasks(priority: filter.priority, status: filter.status);
    }
  }

  List<TaskEntity> _filterTasks(List<TaskEntity> tasks) {
    if (_searchQuery.isEmpty) return tasks;
    return tasks.where((task) {
      return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Map<String, List<TaskEntity>> _groupTasks(List<TaskEntity> tasks) {
    final filteredTasks = _filterTasks(tasks);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final grouped = <String, List<TaskEntity>>{'Today': [], 'Tomorrow': [], 'This week': []};

    for (final task in filteredTasks) {
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
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
            leading: _isSearching
                ? IconButton(
                    icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white, size: 22),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    padding: EdgeInsets.zero,
                  )
                : IconButton(
                    icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Back',
                  ),
            actions: _isSearching
                ? []
                : [
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.clockRotateLeft, color: Colors.white, size: 22),
                      tooltip: 'Task History',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.magnifyingGlass, color: Colors.white, size: 22),
                      tooltip: 'Search Tasks',
                      onPressed: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.filter, color: Colors.white, size: 22),
                      tooltip: 'Filter Tasks',
                      onPressed: _showFilterDialog,
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.rightFromBracket, color: Colors.white, size: 22),
                      tooltip: 'Logout',
                      onPressed: () => ref.read(logoutUseCaseProvider).call(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: FaIcon(FontAwesomeIcons.magnifyingGlass, color: Colors.white, size: 20),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  )
                : null,
          ),
          tasks.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.circleCheck,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No tasks yet.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create one to get started!',
                          style: TextStyle(color: Colors.grey),
                        ),
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
                            ...groupTasks.map((task) => TaskCard(task: task)),
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditTaskScreen()),
        ),
        backgroundColor: Colors.deepPurple,
        tooltip: 'Add New Task',
        child: const Center(
          child: FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 28),
        ),
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
            icon: const FaIcon(FontAwesomeIcons.chevronDown, size: 16),
            decoration: InputDecoration(
              labelText: 'Priority',
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: FaIcon(FontAwesomeIcons.flag, size: 20, color: Colors.deepPurple),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              ...Priority.values.map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.name),
                ),
              )
            ],
            onChanged: (val) => ref.read(filterProvider.notifier).state = Filter(
              priority: val,
              status: filter.status,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<bool?>(
            value: filter.status,
            icon: const FaIcon(FontAwesomeIcons.chevronDown, size: 16),
            decoration: InputDecoration(
              labelText: 'Status',
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: FaIcon(FontAwesomeIcons.clipboardCheck, size: 20, color: Colors.deepPurple),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: true, child: Text('Completed')),
              DropdownMenuItem(value: false, child: Text('Incomplete'))
            ],
            onChanged: (val) => ref.read(filterProvider.notifier).state = Filter(
              priority: filter.priority,
              status: val,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        )
      ],
    );
  }
}
