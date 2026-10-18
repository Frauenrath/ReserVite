import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f02/pages/widgets/top_nav_bar.dart';
import 'package:prbd_2526_f02/providers/reference_time_provider.dart';
import '../providers/client_state_provider.dart';

class ReservationDetailsScreen extends ConsumerWidget {
  const ReservationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientStateAsync = ref.watch(clientStateProvider);
    final referenceTime = ref.watch(referenceTimeProvider);
    final reservation = clientStateAsync.value?.selectedReservation;
    final isEditable = reservation?.status == 'pending' || reservation?.status == 'confirmed';
    final isEditButonActive = (reservation!.status =='pending' ||  reservation.status == 'confirmed') && referenceTime.isBefore(reservation.timestamp);

    Color statusColor = Colors.orange;
    String statusText = 'En attente';

    switch (reservation.status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusText = 'Confirmée';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Annulée';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'Terminée';
        break;
    }
    return Scaffold(
      appBar: TopNavBar(
        title: 'Détails de la réservation',
        showBackButton: true,
        onRefresh: () async {
          ref.read(clientStateProvider.notifier).refreshSelectedReservation();
        }
      ),
      body:
      SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.restaurant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reservation.restaurantName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${reservation.restaurantAddress}, ${reservation.restaurantCity}",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            reservation.restaurantPhone!,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Date: ${DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(reservation.timestamp)}'
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Text('Heure: ${DateFormat('HH:mm').format(reservation.timestamp)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 20),
                          const SizedBox(width: 8),
                          Text('Nombre de convives: ${reservation.numberOfGuests}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info, size: 20),
                          const SizedBox(width: 8),
                          const Text('Statut: '),
                          Chip(
                            label: Text(
                              statusText,
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            backgroundColor: statusColor,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Demandes spéciales',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reservation.specialRequests ?? 'Aucune demande spéciale',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (isEditable) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isEditButonActive ? () {
                            final restaurant = clientStateAsync.value!.restaurantsList.firstWhere(
                                  (r) => r.name == reservation.restaurantName,
                            );
                            Navigator.pushNamed(context, '/ReservationFormScreen',
                              arguments: {'restaurantId': restaurant.id,
                                'existingReservations': reservation,
                              },
                            );
                        } : null,
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDialogBoxCancel(context, ref, reservation.id),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Annuler'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDialogBoxCancel(BuildContext context, WidgetRef ref, int reservationId) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: const Text('Annuler la réservation'),
            content: const Text(
              'Êtes-vous sûr de vouloir annuler cette réservation ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Non'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.deepOrange,
                ),
                onPressed: () {
                  ref.read(clientStateProvider.notifier).cancelReservationsClient(reservationId);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Réservation annulée avec succès."),
                      backgroundColor: Colors.blueGrey,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: const Text('Oui'),
              ),
            ],
          ),
    );
  }
}
