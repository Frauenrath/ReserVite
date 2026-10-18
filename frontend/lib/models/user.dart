import 'package:prbd_2526_f02/Models/security.dart';

class User {
  final String fullName;
  final String email;
  final String? phone;

  User({
    required this.fullName,
    required this.email,
    this.phone
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
    };
  }

  User copyWith({
    String? fullName,
    String? email,
    String? phone}){
    return User(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  static String? validateFullname(String? fullname) {
    final minLength = 3;
    if (fullname == null || fullname.trim().isEmpty) {
      return 'Veuillez entrer un nom valide.';
    } else if (fullname.length < minLength) {
      return 'Le nom complet doit contenir au moins $minLength caractères.';
    } else {
      return null;
    }
  }

  static Future<String?> validateFullnameUnicity(String? fullname) async {
    var res = await Security.checkFullnameAvailable(fullname: fullname?.trim());
    return res ? null : 'Ce nom complet est déjà utilisé';
  }

  static String? validateEmail(String? email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (email == null || email.trim().isEmpty) {
      return 'Veuillez entrer une adresse email.';
    } else if (!emailRegex.hasMatch(email)) {
      return 'Veuillez entrer une adresse email valide.';
    } else {
      return null;
    }
  }

  static Future<String?> validateEmailUnicity(String? email) async {
    var res = await Security.checkEmailAvailable(email: email?.trim());
    return res ? null : 'Cet email est déjà utilisé';
  }

  static String? validatePassword(String? password) {
    final hasLowercase = RegExp(r'[a-z]');
    final hasUppercase = RegExp(r'[A-Z]');
    final hasDigits    = RegExp(r'\d');
    final hasSpecial   = RegExp(r'[,;.:!?/$%&@#]');

    if (password == null || password.trim().isEmpty) {
      return 'Veuillez entrer un mot de passe.';
    } else if (!hasLowercase.hasMatch(password)) {
      return 'Le mot de passe doit contenir au moins une minuscule.';
    } else if (!hasUppercase.hasMatch(password)) {
      return 'Le mot de passe doit contenir au moins une majuscule.';
    } else if (!hasDigits.hasMatch(password)) {
      return 'Le mot de passe doit contenir au moins un chiffre.';
    } else if (!hasSpecial.hasMatch(password)) {
      return 'Le mot de passe doit contenir au moins un caractère spécial autorisé.';
    } else if (password.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    } else {
      return null;
    }
  }

  static String? validateConfirmPassword(String? confPassword, String? password) {
    if (confPassword == null || confPassword.trim().isEmpty) {
      return 'Veuillez confirmer votre mot de passe.';
    } else if (confPassword != password) {
      return 'Les deux mots de passe doivent être identiques.';
    } else {
      return null;
    }
  }

  static String? validatePhoneUser(String? phoneNumber) {
    if (phoneNumber != null && phoneNumber.trim().length > 50) {
      return 'Ne doit pas faire plus que 50 caractères.';
    } else {
      return null;
    }
  }

  @override
  String toString() {
    return '(fullName: $fullName, '
        'email: $email, '
        'phone: $phone)';
  }
}