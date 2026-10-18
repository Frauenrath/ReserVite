import 'dart:convert';
import 'package:prbd_2526_f02/core/services/api_client.dart';

class Restaurant {
  static const int maxSearch = 5; // limite de recherche afficher dans toute l'app

  final int id;
  final String name;
  final String? address;
  final String city;
  final String? phone;
  final String? description;
  final double? rating;
  final int? priceRange;
  final int? slotDuration;
  final DateTime? lastReservationDatetime;
  final int? countPendingReservation;

  Restaurant({
    required this.id,
    required this.name,
    this.address,
    required this.city,
    this.phone,
    this.description,
    this.rating,
    this.priceRange,
    this.slotDuration,
    this.lastReservationDatetime,
    this.countPendingReservation
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      phone: json['phone'],
      description: json['description'],
      rating: json['rating'],
      priceRange: json['price_range'],
      slotDuration: json['slot_duration'],
      lastReservationDatetime: json['last_reservation_datetime'] != null ?
        DateTime.tryParse(json['last_reservation_datetime']) : null,
      countPendingReservation: json['count_pending_reservation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'phone': phone,
      'description': description,
      'rating': rating,
      'price_range': priceRange,
      'slot_duration': slotDuration,
      'last_reservation_datetime': lastReservationDatetime?.toIso8601String(),
      'count_pending_reservation': countPendingReservation
    };
  }

  Restaurant copyWith({
    int? id,
    String? name,
    String? address,
    String? city,
    String? phone,
    String? description,
    double? rating,
    int? priceRange,
    int? slotDuration,
    DateTime? lastReservationDatetime,
    int? countPendingReservation}){

    return Restaurant(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        city: city ?? this.city,
        phone: phone?? this.phone,
        description: description ?? this.description,
        rating: rating ?? this.rating,
        priceRange: priceRange ?? this.priceRange,
        slotDuration: slotDuration ?? this.slotDuration,
        lastReservationDatetime: lastReservationDatetime ?? this.lastReservationDatetime,
        countPendingReservation: countPendingReservation ?? this.countPendingReservation
    );
  }

  static Future<List<Restaurant>> getRestaurantsManager() async {
    final response = await ApiClient.get('get_restaurants_manager');

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Restaurant.fromJson(item)).toList();

    } else {
      throw Exception('Échec du chargement des restaurants du manager: ${response.statusCode}');
    }
  }

  static Future<List<Restaurant>> getRestaurantClient(String searchFilter) async {
    final response = await ApiClient.get(
        'get_restaurants_client?search_filter=$searchFilter&limit_count=$maxSearch');

    if(response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Restaurant.fromJson(item)).toList();
    } else {
      throw Exception('Échec de recherche : ${response.statusCode}');
    }
  }

  @override
  String toString() {
    return 'Restaurant(id: $id, '
        'name: $name, '
        'address: $address, '
        'city: $city, '
        'phone: $phone, '
        'description: $description, '
        'rating: $rating, '
        'priceRange: $priceRange, '
        'slotDuration: $slotDuration, '
        'lastReservationDatetime: $lastReservationDatetime, '
        'countPendingReservation: $countPendingReservation)\n';
  }
}