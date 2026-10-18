import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_f02/Models/user.dart';
import 'package:prbd_2526_f02/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2526_f02/pages/widgets/top_nav_bar.dart';
import 'package:prbd_2526_f02/providers/current_user_provider.dart';
import '../providers/simulated_time_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SignupScreen> createState() => _SignupSreenState();
  }

class _SignupSreenState extends ConsumerState<SignupScreen> {
  late ValidatingTextEditingController _fullnameController;
  late ValidatingTextEditingController _emailController;
  late ValidatingTextEditingController _passwordController;
  late ValidatingTextEditingController _confirmPasswordController;
  late ValidatingTextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    _fullnameController = ValidatingTextEditingController(
      validator: User.validateFullname,
      asyncValidator: User.validateFullnameUnicity,
    );
    _fullnameController.onAfterValidated = () => setState(() {});

    _emailController = ValidatingTextEditingController(
      validator: User.validateEmail,
      asyncValidator: User.validateEmailUnicity,
    );
    _emailController.onAfterValidated = () => setState(() {});

    _passwordController = ValidatingTextEditingController(
      validator: User.validatePassword,
    );
    _passwordController.onAfterValidated = () => setState(() {});

    _confirmPasswordController = ValidatingTextEditingController(
      validator: (value) =>
          User.validateConfirmPassword(value, _passwordController.text),
    );
    _confirmPasswordController.onAfterValidated = () => setState(() {});

    _phoneController = ValidatingTextEditingController(
      validator: User.validatePhoneUser,
    );
    _phoneController.onAfterValidated = () => setState(() {});
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: TopNavBar(
        title: 'Inscription',
        showBackButton: true,
        onRefresh: ref.read(simulatedTimeProvider.notifier).refreshSimulatedTime,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 32),
                const Text(
                  'Créez votre compte',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _fullnameController,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                    errorText: _fullnameController.errorText,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    errorText: _emailController.errorText,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    errorText: _passwordController.errorText,
                  ),
                  onChanged: (value) => _confirmPasswordController.validate(),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                    errorText: _confirmPasswordController.errorText,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Téléphone (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    errorText: _phoneController.errorText
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async => await _submitForm(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('S\'inscrire'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Déjà un compte ? Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!await _validateForm()) return;
    try {
      await ref.read(currentUserProvider.notifier).signUp(
        fullname: _fullnameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      );
      if (mounted) {
            Navigator.pushReplacementNamed(context, '/homeClient');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'inscription : $error')),
        );
      }
    }
  }

  Future<bool> _validateForm() async {
    await _fullnameController.validateAndWait();
    await _emailController.validateAndWait();
    await _passwordController.validateAndWait();
    await _confirmPasswordController.validateAndWait();
    await _phoneController.validateAndWait();
    return _isFormValid;
  }

  bool get _isFormValid =>
      _fullnameController.isValid == true &&
          _emailController.isValid == true &&
          _passwordController.isValid == true &&
          _confirmPasswordController.isValid == true &&
          _phoneController.isValid == true;
}