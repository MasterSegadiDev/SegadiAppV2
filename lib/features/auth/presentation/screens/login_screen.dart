import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segadi/shared/widgets/app_snackbar.dart';
import 'package:segadi/features/auth/presentation/providers/auth_provider.dart';
import 'package:segadi/features/auth/presentation/state/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  late final ProviderSubscription<AuthState> _authListener;

  // Paleta de la pantalla. Si ya tienes AppColors centralizado, elimina
  // esto y referencia tus tokens en su lugar.
  static const _background = Color(0xFF0B0F0D);
  static const _surfaceDark = Color(0xFF101812);
  static const _primaryGreen = Color(0xFF1E7A3C);
  static const _textPrimary = Color(0xFF0F1512);
  static const _textSecondary = Color(0xFF6B6B66);
  static const _border = Color(0xFFE0E0DA);

  @override
  void dispose() {
    _authListener.close();

    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _authListener = ref.listenManual<AuthState>(
      authProvider,
      (previous, next) {
        if (!mounted) return;
        switch (next.status) {
          case AuthStatus.authenticated:
            AppSnackbar.success(
              context,
              'Bienvenido a SEGADI',
            );

            Future.delayed(
              const Duration(milliseconds: 700),
              () {
                if (mounted) {
                  context.go('/home');
                }
              },
            );
            break;

          case AuthStatus.error:
            AppSnackbar.error(context,
                next.errorMessage ?? 'Ocurrió un error al iniciar sesión ');

            break;

          default:
            break;
        }
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBranding(),
                        const SizedBox(height: 28),
                        _buildCard(authState),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            color: _primaryGreen,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Image.asset(
            "assets/images/logo1.png",
            width: 58,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'SEGADI',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Gestión de rutas y servicios',
          style: TextStyle(fontSize: 14, color: Color(0xFF8A938C)),
        ),
      ],
    );
  }

  Widget _buildCard(AuthState authState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(
              controller: _usernameController,
              label: 'Usuario',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _passwordController,
              label: 'Contraseña',
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            _buildLoginButton(authState),
            const SizedBox(height: 18),
            const Center(
              child: Text('v2.0.0',
                  style: TextStyle(fontSize: 11, color: _textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(fontSize: 14, color: _textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: _textSecondary),
        prefixIcon: Icon(
          icon,
          size: 18,
          color: _textSecondary,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                  color: _textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryGreen),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Campo obligatorio';
        }

        return null;
      },
    );
  }

  Widget _buildLoginButton(AuthState authState) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: authState.status == AuthStatus.loading ? null : _login,
        child: authState.status == AuthStatus.loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authProvider.notifier).login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
  }
}
