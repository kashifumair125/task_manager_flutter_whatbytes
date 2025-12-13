import 'package:equatable/equatable.dart';

import 'task_entity.dart';

class Filter extends Equatable {
  final Priority? priority;
  final bool? status;

  const Filter({this.priority, this.status});

  @override
  List<Object?> get props => [priority, status];
}
