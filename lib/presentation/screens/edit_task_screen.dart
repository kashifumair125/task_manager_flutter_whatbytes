import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final TaskEntity? task;

  const EditTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDueDate;
  late Priority _selectedPriority;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _selectedDueDate = widget.task?.dueDate ?? DateTime.now().add(Duration(days: 1));
    _selectedPriority = widget.task?.priority ?? Priority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _saveTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.task == null) {
        // Create new task
        final newTask = TaskEntity(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _selectedDueDate,
          priority: _selectedPriority,
          isCompleted: false,
        );
        await ref.read(tasksProvider.notifier).addTask(newTask);
      } else {
        // Update existing task
        final updatedTask = TaskEntity(
          id: widget.task!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _selectedDueDate,
          priority: _selectedPriority,
          isCompleted: widget.task!.isCompleted,
        );
        await ref.read(tasksProvider.notifier).updateTask(updatedTask);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task Title',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter task title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Enter task description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              SizedBox(height: 20),
              Text(
                'Priority',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              DropdownButton<Priority>(
                value: _selectedPriority,
                isExpanded: true,
                items: Priority.values
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            p.name.toUpperCase(),
                            style: TextStyle(
                              color: _getPriorityColor(p),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (Priority? value) {
                  setState(() {
                    _selectedPriority = value ?? Priority.medium;
                  });
                },
              ),
              SizedBox(height: 20),
              Text(
                'Due Date',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              ListTile(
                title: Text(
                  _selectedDueDate.toString().split(' ')[0],
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _selectDueDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey),
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.task == null ? 'Create Task' : 'Update Task'),
                ),
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
