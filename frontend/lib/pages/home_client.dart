import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_f02/pages/widgets/reservation_card.dart';
import 'package:prbd_2526_f02/pages/widgets/top_nav_bar.dart';
import '../providers/client_state_provider.dart';

class HomeClientScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends ConsumerState<HomeClientScreen> {
  String _selectedFilter = 'pending';

  @override
  Widget build(BuildContext context) {
    final reservationsAsync = ref.watch(clientStateProvider);

    return Scaffold(
      appBar: TopNavBar(
        title: 'Mes réservations',
        showSearchButton: true,
        onRefresh: ref.read(clientStateProvider.notifier).refreshReservations,
        showLogoutButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: 'all',
                    icon: Icon(Icons.list, size: 24),
                    tooltip: 'Toutes',
                  ),
                  ButtonSegment(
                    value: 'pending',
                    icon: Icon(Icons.pending, size: 24, color: Colors.orange),
                    tooltip: 'En attente',
                  ),
                  ButtonSegment(
                    value: 'confirmed',
                    icon: Icon(
                        Icons.check_circle, size: 24, color: Colors.green),
                    tooltip: 'Confirmées',
                  ),
                  ButtonSegment(
                    value: 'completed',
                    icon: Icon(
                        Icons.event_available, size: 24, color: Colors.blue),
                    tooltip: 'Terminées',
                  ),
                  ButtonSegment(
                    value: 'cancelled',
                    icon: Icon(Icons.cancel, size: 24, color: Colors.red),
                    tooltip: 'Annulées',
                  ),
                ],
                selected: <String>{_selectedFilter},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedFilter = newSelection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: reservationsAsync.when(
                data: (clientData) {
                  final listeReservations = clientData.reservationsList;
                  final listeFiltree = _selectedFilter == 'all'
                      ? listeReservations
                      : listeReservations.where((res) => res.status == _selectedFilter).toList();

                  if (listeFiltree.isEmpty) {
                    return const Center(
                      child: Text('Aucune réservation trouvée.'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: listeFiltree.length,
                    itemBuilder: (context, index) {
                      final reservation = listeFiltree[index];

                      return ReservationCard(reservation: reservation);
                    },
                  );
                },

                loading: () =>
                const Center(
                  child: CircularProgressIndicator(),
                ),

                error: (erreur, stackTrace) =>
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Erreur : $erreur',
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/searchResaurant'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle réservation'),
      ),
    );
  }
}