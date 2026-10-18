import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_f02/models/reservation.dart';
import 'package:prbd_2526_f02/models/restaurant.dart';
import 'package:prbd_2526_f02/providers/current_user_provider.dart';
import 'package:prbd_2526_f02/providers/reference_time_provider.dart';
import 'package:prbd_2526_f02/providers/simulated_time_provider.dart';
import '../models/services.dart';

class ClientStateData {
  final List<Reservation> reservationsList;
  final List<Restaurant> restaurantsList;
  final List<Services> servicesList;
  final String? searchFilter;
  final Reservation? selectedReservation;
  final Restaurant? seletedRestaurant;
  final DateTime? reservationDate;
  final String? reservationTime;
  final int reservationGuests;
  final String reservationRequests;
  final List<String> availableSlots;
  final bool hasExistingReservationOnDate;
  final int maxAvailableCapacity;

  const ClientStateData({
    required this.reservationsList,
    required this.restaurantsList,
    this.selectedReservation,
    this.seletedRestaurant,
    this.searchFilter,
    required this.servicesList,
    this.reservationDate,
    this.reservationTime,
    this.reservationGuests = 2,
    this.reservationRequests = '',
    this.availableSlots = const [],
    this.hasExistingReservationOnDate = false,
    this.maxAvailableCapacity = 0,
  });

  ClientStateData copyWith({
    List<Reservation>? reservationsList,
    List<Restaurant>? restaurantsList,
    Reservation? selectedReservation,
    Restaurant? seletedRestaurant,
    List<Services>? servicesList,
    String? searchFilter,
    DateTime? reservationDate,
    String? reservationTime,
    int? reservationGuests,
    String? reservationRequests,
    List<String>? availableSlots,
    bool? hasExistingReservationOnDate,
    int? maxAvailableCapacity,
  }) {
    return ClientStateData(
      reservationsList: reservationsList ?? this.reservationsList,
      restaurantsList: restaurantsList ?? this.restaurantsList,
      servicesList: servicesList ?? this.servicesList,
      searchFilter: searchFilter ?? this.searchFilter,
      selectedReservation: selectedReservation ?? this.selectedReservation,
      seletedRestaurant: seletedRestaurant ?? this.seletedRestaurant,
      reservationDate: reservationDate ?? this.reservationDate,
      reservationTime: reservationTime ?? this.reservationTime,
      reservationGuests: reservationGuests ?? this.reservationGuests,
      reservationRequests: reservationRequests ?? this.reservationRequests,
      availableSlots: availableSlots ?? this.availableSlots,
      hasExistingReservationOnDate: hasExistingReservationOnDate ?? this.hasExistingReservationOnDate,
      maxAvailableCapacity: maxAvailableCapacity ?? this.maxAvailableCapacity,
    );
  }
}

final clientStateProvider =
  AsyncNotifierProvider<ClientStateNotifier, ClientStateData>(
        () => ClientStateNotifier(),
  );

class ClientStateNotifier extends AsyncNotifier<ClientStateData> {
  @override
  FutureOr<ClientStateData> build() async {
    final previousSelected = state.value?.selectedReservation;
    ref.watch(currentUserProvider);
    ref.watch(simulatedTimeProvider);
    final previousSearchfilter = state.value?.searchFilter ?? "";
    final previousTime = state.value?.reservationTime;
    final previousDate = state.value?.reservationDate;
    final previousGuests = state.value?.reservationGuests ?? 2;
    final result = await Future.wait([
      Reservation.getReservations(),
      Restaurant.getRestaurantClient(previousSearchfilter),
      Services.getServices(),
    ]);

    final listeReservations = result[0] as List<Reservation>;
    final listeRestaurants = result[1] as List<Restaurant>;
    final listeServices = result[2] as List<Services>;

    return ClientStateData(
      reservationsList: listeReservations,
      restaurantsList: listeRestaurants,
      servicesList: listeServices,
      selectedReservation: previousSelected,
      reservationTime: previousTime,
      reservationDate: previousDate,
      reservationGuests: previousGuests,
      searchFilter: previousSearchfilter,
    );
  }

  Future<void> researchRestaurants(String newSearchFilter) async {
    try {
      // récupére la liste des restos.
      final newRestaurantsList = await Restaurant.getRestaurantClient(newSearchFilter);
      // Mise à jour de l'état => l'UI se réfraissit automatiquement.
      state = const AsyncLoading();
      if (state.hasValue) {
        state = AsyncData(
          state.value!.copyWith(
              restaurantsList: newRestaurantsList,
              searchFilter: newSearchFilter,
          ),
        );
      }
    } catch (err, stack) {
      print('Erreur lors de l' 'obtention des restaurants après recherche : $err, $stack');
    }
  }

  Future<void> getSelectedReservation(int id) async {
    try {
      final newsSelectedReservation = await Reservation.getReservationById(id);

      if (state.hasValue) {
        state = AsyncData(
          state.value!.copyWith(
            selectedReservation: newsSelectedReservation,
          ),
        );
      }
    } catch (err, stack) {
      print('Erreur lors de la demande de la réservation selectionnée: $err, $stack');
    }
  }

  Future<void> refreshSelectedReservation() async {
      final currentState = state.value!;
      final currentReservation = currentState.selectedReservation;
      try {
      final newsSelectedReservation = await Reservation.getReservationById(currentReservation!.id);

      state = AsyncData(
        currentState.copyWith(
          selectedReservation: newsSelectedReservation,
        ),
      );

    } catch (err, stack) {
      print('Erreur lors du refresh de la réservation selectionnée: $err, $stack');
      state = AsyncError(err, stack);
    }
  }

  Future<void> refreshReservations() async {
    try {
      final newReservationsList = await Reservation.getReservations();

      if (state.hasValue) {
        state = AsyncData(
          state.value!.copyWith(
            reservationsList: newReservationsList,
          ),
        );
      }
    } catch (err, stack) {
      print('Erreur lors du rafraîchissement des réservations : $err, $stack');
    }
  }

  Future<void> refreshRestaurants() async {
    try {
      final searchFilter = state.value?.searchFilter ?? "";
      final newRestaurantsList = await Restaurant.getRestaurantClient(searchFilter);

      if (state.hasValue) {
        state = AsyncData(
          state.value!.copyWith(
            restaurantsList: newRestaurantsList
          ),
        );
      }
    } catch (err, stack) {
      print('Erreur lors du rafraîchissement des restaurants : $err, $stack');
    }
  }

  Future<void> cancelReservationsClient(int reservationId) async {
    final currentState = state.value!;
    state = AsyncLoading();
    try{
      await Reservation.cancelReservation(reservationId);
      final updatedReservationsList = currentState.reservationsList
          .map((reservation) => reservation.id == reservationId ?
            reservation.copyWith(status: 'cancelled') : reservation,
      ).toList();

      Reservation selectedReservation = currentState.selectedReservation!;
      if (selectedReservation.id == reservationId) {
        selectedReservation = selectedReservation.copyWith(status: 'cancelled');
      }

      final updatedRestaurants = currentState.restaurantsList.map((restaurant) {
        // on cible le bon restaurant (idealement par id, sinon par nom)
        if (restaurant.name == currentState.selectedReservation?.restaurantName) {

          // On ne décrémente que si la réservation annulée était 'pending'
          final bool wasPending = currentState.selectedReservation?.status == 'pending';
          final currentPending = restaurant.countPendingReservation ?? 0;
          final int newPending = wasPending ? (currentPending > 0 ? currentPending - 1 : 0) : currentPending;

          // on cherche toutes les reservations actives restantes de ce restaurant
          final restaurantReservations = updatedReservationsList
              .where((r) => r.restaurantName == restaurant.name && r.status != 'cancelled')
              .toList();

          DateTime? newLastDatetime;
          if (restaurantReservations.isNotEmpty) {
            // on trie ou on cherche la date la plus récente parmi celles qui restent
            newLastDatetime = restaurantReservations
                .map((r) => r.timestamp)
                .reduce((value, element) => value.isAfter(element) ? value : element);
          } else {
            // s'il n'y a plus aucune reservation active, là on peut mettre null
            newLastDatetime = null;
          }

          // on applique les modifications au restaurant
          return restaurant.copyWith(
            countPendingReservation: newPending,
            lastReservationDatetime: newLastDatetime, // Contient la vraie valeur recalculée
          );
        }

        return restaurant;
      }).toList();

      state = AsyncData(
        currentState.copyWith(
          reservationsList: updatedReservationsList,
          selectedReservation: selectedReservation,
          restaurantsList: updatedRestaurants,
        )
      );
    }catch(error, stackTrace){
      state = AsyncError(error, stackTrace);
    }
  }
  Future<void> initReservationForm({Reservation? existingReservation, required int restaurantId}) async{
    if(!state.hasValue) return; // ca regarde si les donnees sont bien chargee avant de modifer le formulaire
    DateTime targetDate;
    String? targetTime;
    int guests = 2;
    String requests = '';

    if(existingReservation == null){
      // MODE AJOUT
      final now = ref.read(referenceTimeProvider);
      targetDate = DateTime(now.year, now.month, now.day);

    }else{
      // mode EDITION
      final timestamp = existingReservation.timestamp;
      targetDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
      targetTime = "${timestamp.hour.toString().padLeft(2,'0')}:${timestamp.minute.toString().padLeft(2,'0')}";
      guests = existingReservation.numberOfGuests;
      requests = existingReservation.specialRequests ?? '';
      }

    try{
      final data = await Reservation.getFormContext(restaurantId, targetDate, reservationId:  existingReservation?.id);
      List<String> parsedSlots = [];
      if(data['slots'] != null){
        //Extrait les Strings de la liste d'objet
        parsedSlots = (data['slots'] as List).map((slot) => slot['time'].toString()).toList();
      }
      bool hasExisting = data['has_existing'] ?? false;
      int capacity = data['capacity'] ?? 999;
      if (existingReservation == null && parsedSlots.isNotEmpty) {
        targetTime = parsedSlots.first;
      }
      state = AsyncData(
          state.value!.copyWith(
            reservationDate: targetDate,
            reservationTime: targetTime,
            reservationGuests: guests,
            reservationRequests: requests,
            availableSlots: parsedSlots,
            hasExistingReservationOnDate: hasExisting,
            maxAvailableCapacity: capacity,
          )
      );
    }catch(error){
      print("Erreur de capacité : $error");
    }
  }

  void updateGuests(int restaurantId, int newGuests, {int? reservationId}){
    state = AsyncData(state.value!.copyWith(reservationGuests: newGuests));
  }
  Future<void> updateDate(int restaurantId, DateTime? newDate, {int? reservationId}) async {
    if (newDate == null || !state.hasValue) return;

   try {
     final data = await Reservation.getFormContext(restaurantId, newDate, reservationId: reservationId);
     List<String> parsedSlots = [];
     if(data['slots'] != null){
       //Extrait les Strings de la liste d'objet
       parsedSlots = (data['slots'] as List).map((slot) => slot['time'].toString()).toList();
     }

     final bool hasExisting = data['has_existing'] ?? false;
     final int capacity = data['capacity'] ?? 999;
     state = AsyncData(
         state.value!.copyWith(
           reservationDate: newDate,
           reservationTime: null,
           availableSlots: parsedSlots,
           maxAvailableCapacity: capacity,
           hasExistingReservationOnDate: hasExisting,
         )
     );
   }catch(error){
     print("Erreur ou aucun créneau disponible : $error");
     state = AsyncData(
         state.value!.copyWith(
           reservationDate: newDate,
           reservationTime: null,
           availableSlots: [],
           hasExistingReservationOnDate: false,
         )
     );
   }
   }


  Future<void> updateTime(int restaurantId, String newTime, int numberOfGuests,{int? reservationId}) async{
    if (!state.hasValue || state.value!.reservationDate == null) return;

    state = AsyncData(
        state.value!.copyWith(
          reservationTime: newTime,
          reservationGuests: numberOfGuests,
        )
    );
    final date = state.value!.reservationDate!;
    final timeParts = newTime.split(':');
    final completeDateTime = DateTime(date.year, date.month, date.day, int.parse(timeParts[0]), int.parse(timeParts[1]),);
    try{
      final availableSeats = await Reservation.getAvailableCapacity(restaurantId, completeDateTime, reservationId: reservationId);

      state = AsyncData(
        state.value!.copyWith(
          maxAvailableCapacity: availableSeats,
        )
      );
    }catch(error){
      print("Erreur de capacité : $error");
    }
  }

  Future<String?> submitReservation(int restaurantId, Reservation? existingReservation, String requests) async {
    if (!state.hasValue) return "Erreur de chargement du formulaire.";
    final formData = state.value!;

    if (formData.reservationDate == null || formData.reservationTime == null) {
      return 'Veuillez sélectionner une date et une heure.';
    }
    final date = formData.reservationDate!;
    final timeParts = formData.reservationTime!.split(':');
    final completeDateTime = DateTime(
      date.year, date.month, date.day,
      int.parse(timeParts[0]), int.parse(timeParts[1]),
    );
    int trueCapacityRemaining = await Reservation.getAvailableCapacity(restaurantId, completeDateTime, reservationId: existingReservation?.id);
    if (formData.reservationGuests > trueCapacityRemaining){
      return 'Impossible de réserver : car la capacité est surcharger. ';
    }
    List<Reservation> updatedList;
    List<Restaurant> updatedRestaurants = formData.restaurantsList;
    Reservation? newSelectedReservation = formData.selectedReservation;
    try {
      if (existingReservation == null) {
        final newReservation = await Reservation.createReservation(restaurantId, completeDateTime, formData.reservationGuests, requests);
        updatedList = [...formData.reservationsList, newReservation];

        updatedRestaurants = formData.restaurantsList.map((restaurant) {
          if (restaurant.id != restaurantId) return restaurant;

          final currentPending = restaurant.countPendingReservation ?? 0;
          return restaurant.copyWith(
            countPendingReservation: currentPending + 1,
          );
        }).toList();
      } else {
        // Mode edition :

        newSelectedReservation = existingReservation.copyWith(
          timestamp: completeDateTime,
          numberOfGuests: formData.reservationGuests,
          specialRequests: requests,
          status: "pending"
        );

        updatedList = formData.reservationsList
            .map((reservation) => reservation.id == existingReservation.id ?
        reservation.copyWith(timestamp: completeDateTime , numberOfGuests: formData.reservationGuests , specialRequests: requests, status: "pending") : reservation,
        ).toList();

        await Reservation.updateReservation(
            existingReservation.id,
            completeDateTime,
            formData.reservationGuests,
            requests
        );
        final bool wasPending = existingReservation.status == 'pending';

        // Si la réservation est en attente et change de restaurant, on ajuste les deux compteurs
        updatedRestaurants = formData.restaurantsList.map((restaurant) {
          if (restaurant.id != restaurantId) {
            return restaurant;
          }

          final currentPending = restaurant.countPendingReservation ?? 0;
          if (!wasPending) {
            return restaurant.copyWith(
              countPendingReservation: currentPending + 1,
            );
          }

          return restaurant;
        }).toList();

      }
      state = AsyncData(formData.copyWith(reservationsList: updatedList, restaurantsList: updatedRestaurants, selectedReservation: newSelectedReservation)); // on met a jour la liste global des réservations et la liste dse restaurants pour le compte de reservation pending.
      return null; // cbon pas d'erreur ici

    } catch (erreur) {
      return "Erreur lors de la réservation : $erreur";
    }
  }
}