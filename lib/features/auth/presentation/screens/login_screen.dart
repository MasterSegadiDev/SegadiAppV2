import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    ref.listenManual(
      authProvider,
      (previous, next) {
        if (next.status == AuthStatus.authenticated) {
          context.go('/home');
        }
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Color(0xFF2C522A),
              Color(0xFF1B321A),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  24,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/logo1.png",
                      width: size.width * 0.4,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(
                          0xFF2C522A,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    _buildField(
                      controller: _usernameController,
                      label: 'Usuario',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    _buildLoginButton(authState),
                  ],
                ),
              ),
            ),
          ),
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF2C522A),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            12,
          ),
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

  Widget _buildLoginButton(
    AuthState authState,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C522A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
        ),
        onPressed: _login,
        child: const Text(
          'Iniciar Sesión',
          style: TextStyle(
            fontSize: 18,
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
