import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_f02/providers/simulated_time_provider.dart';

final referenceTimeProvider = Provider<DateTime>((ref) {
  final simulatedTime = ref.watch(simulatedTimeProvider);
  return simulatedTime?.timestamp ?? DateTime.now();
});