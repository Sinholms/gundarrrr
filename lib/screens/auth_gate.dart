import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import 'umkm_registration_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthState>(
      valueListenable: AuthService.authState,
      builder: (context, state, _) {
        if (!state.isLoggedIn) return const LoginScreen();
        if (!state.hasCompletedUmkmRegistration) {
          return const UmkmRegistrationScreen();
        }
        return const MainShell();
      },
    );
  }
}
