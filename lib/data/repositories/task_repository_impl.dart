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
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(task.id)
        .set(TaskModel.fromEntity(task).toJson());
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(task.id)
        .update(TaskModel.fromEntity(task).toJson());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
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
        _firestore.collection('users').doc(userId).collection('tasks');

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
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(taskId)
        .update({'isCompleted': isCompleted});
  }
}
