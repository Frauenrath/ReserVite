import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f02/providers/current_user_provider.dart';
import 'package:prbd_2526_f02/providers/simulated_time_provider.dart';
import '../../providers/reference_time_provider.dart';

class TopNavBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showSearchButton;
  final bool showLogoutButton;
  final Future<void> Function()? onRefresh;

  const TopNavBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showSearchButton = false,
    this.showLogoutButton = false,
    this.onRefresh,

  });

  // taille standard obligatoire d'une AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final simulatedTime = ref.watch(referenceTimeProvider);
    final currentUserNotifer = ref.read(currentUserProvider.notifier);

    return AppBar(
      leading: showBackButton ?
      IconButton(icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      )
          : null,
      title: Text(title),
      automaticallyImplyLeading: false,

      actions: [
        if (showSearchButton) ...[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/searchResaurant'),
          ),
        ],
        if (onRefresh != null) ...[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () async {
              await onRefresh!();
            }
          ),
        ],
        if (showLogoutButton) ...[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion ${currentUserNotifer.isLoggedIn
                ? '(${currentUserNotifer.loggedUser})' : ''}',
            onPressed: () {
              currentUserNotifer.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ],
      elevation: 2,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      surfaceTintColor: Colors.transparent,

      // le bandeau temporel
      flexibleSpace: Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Tooltip(
              message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
              child: GestureDetector(
                onTap: () {
                  _showDialogBoxTime(context, ref);
                },
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR').format(simulatedTime),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDialogBoxTime(BuildContext context, WidgetRef ref) async {
    final currentSimulatedTime = ref.read(referenceTimeProvider);

    DateTime selectedDate = currentSimulatedTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(currentSimulatedTime);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // statefulBuilder permet de rafraîchir l'AlertDialog à chaque changement
        return StatefulBuilder(
          builder: (context, setStateLocal) {

            // Fonction locale pour choisir la date
            Future<void> chooseDate() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: selectedDate.add(const Duration(days: 365)),
              );
              if (picked != null) {
                // met à jour l'UI de la boîte de dialogue
                setStateLocal(() {
                  selectedDate = picked;
                });
              }
            }

            // Fonction locale pour choisir l'heure
            Future<void> chooseTime() async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: selectedTime,
              );
              if (picked != null) {
                // met à jour l'UI de la boîte de dialogue
                setStateLocal(() {
                  selectedTime = picked;
                });
              }
            }

            return AlertDialog(
              title: const Text('Modifier le temps simulé'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Date'),
                    subtitle: Text(
                      DateFormat('EEEE dd/MM/yyyy', 'fr_FR').format(selectedDate),
                    ),
                    onTap: chooseDate,
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Heure'),
                    subtitle: Text(selectedTime.format(context)),
                    onTap: chooseTime,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () async {
                    await ref.read(simulatedTimeProvider.notifier).setTime(null);
                    if (context.mounted) Navigator.pop(dialogContext);
                  },
                  child: const Text('Effacer (null)'),
                ),
                TextButton(
                  onPressed: () async {
                    // fusion de la date et de l'heure sélectionnées
                    final DateTime finalDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    await ref.read(simulatedTimeProvider.notifier).setTime(finalDateTime);
                    if (context.mounted) Navigator.pop(dialogContext);
                  },
                  child: const Text('Valider'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}