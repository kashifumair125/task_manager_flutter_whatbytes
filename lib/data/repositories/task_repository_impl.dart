import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId;

  TaskRepositoryImpl(this._userId);

  @override
  Future<void> createTask(TaskEntity task) async {
    await _firestore
        .collection('tasks')
        .doc(_userId)
        .collection('userTasks')
        .doc(task.id)
        .set(TaskModel.fromEntity(task).toJson());
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    await _firestore
        .collection('tasks')
        .doc(_userId)
        .collection('userTasks')
        .doc(task.id)
        .update(TaskModel.fromEntity(task).toJson());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _firestore
        .collection('tasks')
        .doc(_userId)
        .collection('userTasks')
        .doc(taskId)
        .delete();
  }

  @override
  Stream<List<TaskEntity>> getTasks(
    String userId, {
    Priority? priorityFilter,
    bool? statusFilter,
  }) {
    Query query =
        _firestore.collection('tasks').doc(userId).collection('userTasks');

    if (priorityFilter != null) {
      query = query.where('priority', isEqualTo: priorityFilter.name);
    }
    if (statusFilter != null) {
      query = query.where('isCompleted', isEqualTo: statusFilter);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromJson(doc.data() as Map<String, dynamic>).toEntity())
              .toList(),
        );
  }

  @override
  Future<void> markTaskComplete(String taskId, bool isCompleted) async {
    await _firestore
        .collection('tasks')
        .doc(_userId)
        .collection('userTasks')
        .doc(taskId)
        .update({'isCompleted': isCompleted});
  }
}
