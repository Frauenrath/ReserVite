import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:prbd_2526_f02/core/tools/params.dart';
import 'package:prbd_2526_f02/models/security.dart';

final currentUserProvider = AsyncNotifierProvider<CurrentUserNotifier, String?>(
      () => CurrentUserNotifier(),
);

class CurrentUserNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    // pour que le state soit initialisée de manière synchrone
    state = AsyncData(Params.getValue('token'));
    return state.value;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      var token = await Security.login(email, password);
      await Params.setValue('token', token);
      state = AsyncData(token);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void logout() {
    Params.clearValue('token');
    state = AsyncData(null);
  }

  bool get isLoggedIn => loggedUser != null;

  String? get loggedUser {
    return _getNameFromToken(state.value);
  }

  static String? _getEmailFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub'];
    } catch (e) {
      return null;
    }
  }

  bool get isManager => _getRoleFromToken(state.value) == 'manager';

  static String? _getRoleFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['role'];
    } catch (e) {
      return null;
    }
  }

  static String? _getNameFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['name'];
    } catch (e) {
      return null;
    }
  }

  static String? _getIdFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['id'];
    } catch (e) {
      return null;
    }
  }

  Future<void> signUp({
    required String fullname,
    required String email,
    required String password,
    String? phone
  }) async {
    state = const AsyncValue.loading();
    try {
      await Security.signup(
          fullname: fullname,
          email: email,
          password: password,
          phone: phone
      );
      await login(email, password);
      state = AsyncValue.data(Params.getValue('token'));
    } catch (e) {
      state = AsyncValue.error("Signup failed", StackTrace.current);
    }
  }
}
