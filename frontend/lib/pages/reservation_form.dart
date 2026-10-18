import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f02/models/reservation.dart';
import 'package:prbd_2526_f02/pages/widgets/top_nav_bar.dart';
import 'package:prbd_2526_f02/providers/client_state_provider.dart';
import 'package:prbd_2526_f02/providers/reference_time_provider.dart';

class ReservationFormScreen extends ConsumerStatefulWidget {
  final int restaurantId;
  final Reservation? existingReservations;

  const ReservationFormScreen({
    super.key,
    required this.restaurantId,
    this.existingReservations,
  });

  @override
  ConsumerState<ReservationFormScreen> createState() =>
      _ReservationFromScreenState();
}
class _ReservationFromScreenState extends ConsumerState<ReservationFormScreen> {
  final TextEditingController _requestsController = TextEditingController();
  @override
  void initState(){
    super.initState();
    _requestsController.text = widget.existingReservations?.specialRequests ?? '';
    Future.microtask(() {
      ref.read(clientStateProvider.notifier).initReservationForm(
        restaurantId: widget.restaurantId,
        existingReservation: widget.existingReservations,
      );
    });
  }

  @override
  void dispose() {
    _requestsController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clientState = ref.watch(clientStateProvider);
    // verifie si mode ajout et edit
    final isEditing = widget.existingReservations != null;
    final formData = clientState.value;
    final restaurant = formData?.restaurantsList.firstWhere((r) => r.id == widget.restaurantId,);
    final restaurantName = restaurant?.name ?? 'Chargement...';
    final guests = formData?.reservationGuests ?? 2;
    final availableSlots = formData?.availableSlots ?? [];
    final currentDate = ref.watch(referenceTimeProvider);
    final minDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final isMinusDisabled = formData?.reservationDate == null || !formData!.reservationDate!.isAfter(minDate);


    return Scaffold(
      appBar: TopNavBar(
        title: isEditing ? 'Modifier la réservation' : 'Nouvelle réservation',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  restaurantName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final initial = formData?.reservationDate ?? currentDate;
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: initial.isBefore(minDate) ? minDate : initial,
                              firstDate: minDate,
                              lastDate: currentDate.add(const Duration(
                                  days: 365)),
                            );
                            ref.read(clientStateProvider.notifier).updateDate(
                                widget.restaurantId, selectedDate, reservationId: widget.existingReservations?.id);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Date'),
                                      Text(
                                        formData?.reservationDate != null
                                      ? DateFormat('EEEE d/MM/yyyy', 'fr_FR').format(formData!.reservationDate!)
                                      : 'Sélectionner une date',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: isMinusDisabled ? null : ()  {
                        final actualDateForm = formData.reservationDate ?? currentDate;
                        final newDate = actualDateForm.subtract(const Duration(days: 1));

                        ref.read(clientStateProvider.notifier).updateDate(widget.restaurantId, newDate, reservationId: widget.existingReservations?.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final actualDateForm = formData?.reservationDate ?? currentDate;
                        final newDate = actualDateForm.add(const Duration(days: 1));
                        ref.read(clientStateProvider.notifier).updateDate(widget.restaurantId, newDate, reservationId: widget.existingReservations?.id);

                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const Divider(),
                if(formData?.reservationDate != null && formData?.availableSlots != null && availableSlots.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (formData?.hasExistingReservationOnDate == true)
                              ? 'Vous avez déjà une réservation pour ce jour-là.'
                              : 'Aucun créneau disponible. Le restaurant est fermé ce jour-là.',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Créneaux disponibles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: availableSlots.map((time) {
                    final isSelected = time == formData?.reservationTime;
                    return GestureDetector(
                      onTap: () {
                        ref.read(clientStateProvider.notifier).updateTime(widget.restaurantId, time, guests,reservationId: widget.existingReservations?.id,);
                      },
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            time,
                            style: TextStyle(
                              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Nombre de convives'),
                  subtitle: Text('$guests'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed:guests > 1 ? () {
                          ref.read(clientStateProvider.notifier).updateGuests(widget.restaurantId, guests - 1, reservationId: widget.existingReservations?.id);

                        } : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: (formData != null && guests >= formData.maxAvailableCapacity ) ? null : () {
                          ref.read(clientStateProvider.notifier).updateGuests(widget.restaurantId, guests + 1, reservationId: widget.existingReservations?.id);
                        },
                      ),
                    ],
                  ),
                ),
                if(formData != null && guests > formData.maxAvailableCapacity)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Surréservation (capacité)',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'La capacité du restaurant pour ce créneau pourrait être insuffisante pour le nombre de convives demandé.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                  TextFormField(
                    controller: _requestsController,
                    decoration: const InputDecoration(
                      labelText: 'Demandes spéciales (optionnel)',
                      border: OutlineInputBorder(),
                      hintText: 'Allergies, préférences...',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 10){
                      return "Veuillez saisir au moins 10 caractères.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    final existing = widget.existingReservations;
                    if (existing != null && existing.status == 'confirmed' && existing.timestamp.isAfter(currentDate)) {
                      final bool? validerModification = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Modifier une réservation confirmée'),
                            content: const Text(
                              'Cette réservation est confirmée. La modifier la remettra en attente et les tables associées seront libérées. Souhaitez-vous continuer ?'
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(foregroundColor: Colors.deepOrange),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Continuer'),
                              ),
                            ],
                          );
                        },
                      );
                      if (!context.mounted) return;
                      if (validerModification != true) return;
                    }

                    final requestsText = _requestsController.text;
                    final errorMessage = await ref.read(clientStateProvider.notifier).submitReservation(
                      widget.restaurantId,
                      existing,
                      requestsText
                    );
                    if(!context.mounted) return;
                    if (errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
                    } else {
                      if (existing == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Réservation créée avec succès.'), backgroundColor: Colors.green));
                        Navigator.popUntil(context, (route) => route.isFirst);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Réservation modifiée avec succès.'), backgroundColor: Colors.blueGrey));
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(isEditing ? 'Enregistrer les modifications' : 'Créer la réservation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
