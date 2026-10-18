import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_f02/pages/widgets/restaurant_card.dart';
import 'package:prbd_2526_f02/pages/widgets/top_nav_bar.dart';
import 'package:prbd_2526_f02/providers/manager_state_provider.dart';

class ManagerRestaurantsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managerStateAsync = ref.watch(managerStateProvider);

    return Scaffold(
      appBar: TopNavBar(
        title: 'Mes restaurants',
        onRefresh: ref.read(managerStateProvider.notifier).refreshRestaurantsList,
        showLogoutButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: managerStateAsync.when(
                data: (clientData) {
                  final restaurantList = clientData.restaurantsList;
                    if (restaurantList.isEmpty) {
                      return const Center(
                        child: Text('Aucun restaurant trouvé. '
                            'Veuillez à contacter un administrateur afin de vous en assigner.'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: restaurantList.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurantList[index];
                        return RestaurantCard(restaurant: restaurant);
                      },
                    );
                  },
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
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}
