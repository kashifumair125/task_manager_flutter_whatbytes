import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/filter.dart';

final filterProvider = StateProvider<Filter>((ref) => const Filter());
