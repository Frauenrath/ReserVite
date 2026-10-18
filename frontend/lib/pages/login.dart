import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_f02/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2526_f02/models/user.dart';
import 'package:prbd_2526_f02/pages/widgets/top_nav_bar.dart';
import 'package:prbd_2526_f02/providers/current_user_provider.dart';
import 'package:prbd_2526_f02/providers/simulated_time_provider.dart';

import '../models/security.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = ValidatingTextEditingController(
    validator: User.validateEmail,
    initialValue: '',
  );
  final _passwordController = ValidatingTextEditingController(
    validator: User.validatePassword,
    initialValue: '',
  );

  @override
  void initState() {
    _emailController.onAfterValidated = () => setState(() {});
    _passwordController.onAfterValidated = () => setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: TopNavBar(
        title: 'Connexion',
        onRefresh: ref.read(simulatedTimeProvider.notifier).refreshSimulatedTime,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      const Icon(
                        Icons.restaurant,
                        size: 80,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Connectez-vous',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email),
                          errorText: _emailController.errorText,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          errorText: _passwordController.errorText,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _submitForm(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Se connecter'),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                        child: const Text(
                          'Pas encore de compte ? S\'inscrire',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Raccourcis de débogage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Se connecter directement en tant que :',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _login('brlacroix@epfc.eu', 'Password1,'),
                          icon: const Icon(Icons.person),
                          label: const Text('Client (Bruno)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _login('mamichel@epfc.eu', 'Password1,'),
                          icon: const Icon(Icons.person),
                          label: const Text('Client (Marc)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _login('bepenelle@epfc.eu', 'Password1,'),
                          icon: const Icon(Icons.manage_accounts),
                          label: const Text('Manager (Benoît)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _login('gedielman@epfc.eu', 'Password1,'),
                          icon: const Icon(Icons.manage_accounts),
                          label: const Text('Manager (Geoffrey)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDialogBoxResetDB(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réinitialiser la base de données'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDialogBoxResetDB() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: const Text('Réinitialiser la base de données'),
            content: const Text(
              'Êtes-vous sûr de vouloir réinitialiser la base de données ? '
                  'Cette action supprimera toutes les données '
                  'et les restaurera aux valeurs par défaut.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _resetDataBase();
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Base de données réinitialisée avec succès."),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
    );
  }

  void _resetDataBase() async {
    try {
      await Security.resetDataBase();
    } catch(e) {
      print(e);
    }
  }

  void _submitForm() {
    if (!_validateForm()) return;
    _login(_emailController.text.trim(), _passwordController.text);
  }

  bool _validateForm() {
    _emailController.validate();
    _passwordController.validate();
    return _isFormValid;
  }

  bool get _isFormValid =>
      _emailController.isValid == true && _passwordController.isValid == true;

  Future<void> _login(String mail, String password) async {
    final securityNotifier = ref.read(currentUserProvider.notifier);
    await ref.read(currentUserProvider.notifier).login(mail, password);
    if (!mounted) return;

    final securityState = ref.read(currentUserProvider);

    securityState.when(
      data: (token) {
        if (token != null) {
          if (securityNotifier.isManager) {
            Navigator.pushReplacementNamed(context, '/homeManager');
          } else {
            Navigator.pushReplacementNamed(context, '/homeClient');
          }
        }
      },
      error: (error, _) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email ou mot de passe incorrect."),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ),
        );
      },
      loading: () {},
    );
  }
}