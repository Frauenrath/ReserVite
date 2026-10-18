import 'dart:convert';

import '../core/services/api_client.dart';

class Time {
  final DateTime? timestamp;

  Time({
    this.timestamp
  });

  factory Time.fromJson(Map<String, dynamic> json) {
    return Time(
      timestamp: json['simulated_time'] != null ?
      DateTime.tryParse(json['simulated_time']) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'simulated_time': timestamp!.toIso8601String()
    };
  }

  Time copyWith({
    DateTime? timestamp}){
    return Time(
      timestamp: timestamp ?? this.timestamp
    );
  }

  static Future<Time> getSystemTime() async {
    final response = await ApiClient.get('get_system_time', anonymous: true);

    if (response.statusCode == 200) {
      final dynamic body = json.decode(response.body);
      return Time.fromJson(body);

    } else {
      throw Exception('Échec du chargement du temps: ${response.statusCode}');
    }
  }

  static Future<void> setSystemTime(DateTime? time) async {
    final String? timeIso = time?.toIso8601String();

    final response = await ApiClient.post(
      'set_system_time',
      body: json.encode({'new_time': timeIso}),
      anonymous: true,
    );

    if(response.statusCode != 204) {
      throw Exception('Échec de la modification du temps : ${response.statusCode}');
    }
  }

  @override
  String toString() {
    return 'Time: ($timestamp)\n';
  }
}