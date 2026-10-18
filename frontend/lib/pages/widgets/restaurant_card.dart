import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f02/models/restaurant.dart';
import 'package:prbd_2526_f02/providers/current_user_provider.dart';
import 'package:prbd_2526_f02/providers/manager_state_provider.dart';

class RestaurantCard extends ConsumerWidget {
  final Restaurant restaurant;
  const RestaurantCard({super.key, required this.restaurant});

    @override
    Widget build(BuildContext context, WidgetRef ref) {

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.restaurant, size: 40),
          title: Text(
            restaurant.name
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(restaurant.city),
                  if (restaurant.rating != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      restaurant.rating.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                  if (restaurant.priceRange != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      '€' * (restaurant.priceRange!),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              if (restaurant.lastReservationDatetime != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Dernière réservation: ${DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(restaurant.lastReservationDatetime!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
              if (restaurant.countPendingReservation != 0) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.pending, size: 14, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      '${restaurant.countPendingReservation} demande${restaurant.countPendingReservation! > 1 ? 's' : ''} en attente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap : () async {
            final isManager = ref.read(currentUserProvider.notifier).isManager;
            if (!isManager) {
              Navigator.pushNamed(context,
                  '/RestaurantDetailsScreen',
                  arguments: restaurant.id
              );
            } else {
              await ref.read(managerStateProvider.notifier).getReservationsRestaurant(restaurant.id);
              if (!context.mounted) return;
              Navigator.pushNamed(context,
                  '/RestaurantManagmentReservations',
                  arguments: restaurant
              );
            }
          }
        ),
      );
    }
  }
