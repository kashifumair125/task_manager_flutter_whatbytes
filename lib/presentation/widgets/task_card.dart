import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../screens/edit_task_screen.dart';

class TaskCard extends ConsumerWidget {
  final TaskEntity task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
            'Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tasksProvider.notifier).deleteTask(task.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

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
            onChanged: (val) => ref.read(tasksProvider.notifier).markTaskComplete(
                  task.id,
                  val ?? false,
                ),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.priority.name.toUpperCase(),
                  style: TextStyle(
                    color: _getPriorityColor(task.priority),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: FaIcon(FontAwesomeIcons.pencil, color: Colors.deepPurple, size: 18),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
              ),
              tooltip: 'Edit',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            IconButton(
              icon: FaIcon(FontAwesomeIcons.trash,
                  color: Colors.redAccent, size: 18),
              onPressed: () => _confirmDelete(context, ref),
              tooltip: 'Delete',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
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
