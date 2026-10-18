import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f02/models/reservation.dart';
import 'package:prbd_2526_f02/providers/current_user_provider.dart';
import 'package:prbd_2526_f02/providers/manager_state_provider.dart';
import '../../providers/client_state_provider.dart';

class ReservationCard extends ConsumerWidget {
  final Reservation reservation;
  const ReservationCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isManager = ref.watch(currentUserProvider.notifier).isManager;
    ref.watch(clientStateProvider);

    IconData statusIcon = Icons.pending;
    Color statusColor = Colors.orange;

    switch (reservation.status) {
      case 'confirmed':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
        break;
      case 'completed':
        statusIcon = Icons.event_available;
        statusColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          if (isManager) {
            await ref.read(managerStateProvider.notifier).getSelectedReservationByIdManager(reservation.id);
            if (!context.mounted) return;
            Navigator.pushNamed(context, '/ReservationDetailsManagerScreen');
          }else {
            await ref.read(clientStateProvider.notifier).getSelectedReservation(reservation.id);
            if (!context.mounted) return;
            Navigator.pushNamed(context, '/ReservationDetailsScreen');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Tooltip(
                message: reservation.status,
                child: Icon(statusIcon, size: 32, color: statusColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du restaurant ou de l'owner coter manager
                    if (isManager) ...[
                      Text(
                        reservation.ownerName!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      Text(
                        reservation.restaurantName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    if(isManager) ...[
                      Row(
                        children: [
                          const Icon(Icons.restaurant, size: 16),
                          const SizedBox(width: 4),
                          // nom du restaurant
                          Text(
                          reservation.restaurantName,
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14),
                          const SizedBox(width: 4),
                          // Ville du restaurant
                          Text(
                            reservation.restaurantCity!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        // Date brute ou formatée
                        Text(
                          DateFormat('EEE dd/MM/yyyy à H:mm', 'fr_FR').format(reservation.timestamp),
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 4),
                        //Nombre de convives
                        Text(
                          '${reservation.numberOfGuests} convives',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}