import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/time.dart';

final simulatedTimeProvider =
NotifierProvider<SimulatedTimeNotifier, Time?>(
      () => SimulatedTimeNotifier(),
);

class SimulatedTimeNotifier extends Notifier<Time?> {
  @override
  Time? build() {
    _loadSystemTimeFromDatabase();
    return null;
  }

  Future<void> _loadSystemTimeFromDatabase() async {
    try {
      final response = await Time.getSystemTime();
        state = response;

    } catch (e) {
      print("Erreur lors de la récupération du temps système: $e");
    }
  }

  Future<void> setTime(DateTime? newTime) async {
    await Time.setSystemTime(newTime);

    state = newTime != null ? Time(timestamp: newTime) : null;
  }

  Future<void> refreshSimulatedTime() async {
    try {
      final newSimulatedTime = await Time.getSystemTime();

      state = newSimulatedTime;
    } catch (err, stack) {
      print('Erreur lors du rafraîchissement des réservations : $err, $stack');
    }
  }
}