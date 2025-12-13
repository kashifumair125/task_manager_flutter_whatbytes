import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    _selectedDueDate = widget.task?.dueDate ?? DateTime.now();
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      final task = TaskEntity(
        id: widget.task?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
        isCompleted: widget.task?.isCompleted ?? false,
      );

      if (widget.task == null) {
        await ref.read(tasksProvider.notifier).addTask(task);
      } else {
        await ref.read(tasksProvider.notifier).updateTask(task);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white, size: 22),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(controller: _titleController, label: 'Task Title', icon: FontAwesomeIcons.heading),
            const SizedBox(height: 16),
            _buildTextField(controller: _descriptionController, label: 'Description', maxLines: 4, icon: FontAwesomeIcons.fileLines),
            const SizedBox(height: 24),
            _buildPrioritySelector(),
            const SizedBox(height: 24),
            _buildDueDateSelector(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.task == null ? 'Create Task' : 'Update Task', style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, int maxLines = 1, IconData? icon}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null 
          ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: FaIcon(icon, color: Colors.deepPurple, size: 24),
            )
          : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return DropdownButtonFormField<Priority>(
      value: _selectedPriority,
      icon: const FaIcon(FontAwesomeIcons.chevronDown, size: 16),
      decoration: InputDecoration(
        labelText: 'Priority',
        prefixIcon: const Padding(
          padding: EdgeInsets.all(12.0),
          child: FaIcon(FontAwesomeIcons.flag, color: Colors.deepPurple, size: 24),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: Priority.values.map((p) {
        return DropdownMenuItem(
          value: p,
          child: Text(
            p.name.toUpperCase(),
            style: TextStyle(
              color: _getPriorityColor(p),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
      onChanged: (Priority? value) {
        if (value != null) setState(() => _selectedPriority = value);
      },
    );
  }

  Widget _buildDueDateSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const FaIcon(FontAwesomeIcons.calendar, color: Colors.deepPurple, size: 24),
        title: Text(
          DateFormat('d MMMM yyyy').format(_selectedDueDate),
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        trailing: FaIcon(FontAwesomeIcons.arrowRight, color: Colors.deepPurple.shade400, size: 20),
        onTap: _selectDueDate,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
