import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import 'package:segadi/helper/messages.dart';
import 'package:segadi/viewmodels/login/user_login.dart';

class LoginView extends StatefulWidget {
  LoginView({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C522A),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo con descripción accesible
                  Semantics(
                    label: 'Logo de la aplicación',
                    child: Image.asset(
                      "assets/images/logo1.png",
                      width: size.width * 0.5,
                      semanticLabel: 'App logo',
                    ),
                  ),

                  const SizedBox(height: 24),

                  AutoSizeText('Bienvenido',
                      style: Theme.of(context).textTheme.titleLarge),

                  const SizedBox(height: 24),

                  // Campo usuario con Semantics
                  Semantics(
                    label: 'Campo para ingresar el nombre de usuario',
                    child: _buildTextField(
                      controller: loginViewModel.usernameController,
                      label: 'Usuario',
                      icon: Icons.person,
                      onChanged: (value) => loginViewModel.username = value,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo contraseña con Semantics
                  Semantics(
                    label: 'Campo para ingresar la contraseña',
                    child: _buildPasswordField(loginViewModel),
                  ),

                  const SizedBox(height: 24),

                  // Botón de login con Semantics
                  Semantics(
                    button: true,
                    label: 'Botón para iniciar sesión',
                    child: _buildLoginButton(loginViewModel),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),

      // Botón de llamada con tooltip
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        tooltip: 'Llamar al soporte técnico',
        child: const Icon(Icons.phone, color: Colors.white),
        onPressed: () {
          FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.none,
      validator: (value) =>
          value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  Widget _buildPasswordField(LoginViewModel loginViewModel) {
    return TextFormField(
      controller: loginViewModel.passwordController,
      onChanged: (value) => loginViewModel.password = value,
      textCapitalization: TextCapitalization.none,
      validator: (value) => value == null || value.isEmpty
          ? 'La contraseña es obligatoria'
          : null,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        hintText: 'Contraseña',
        prefixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(context).primaryColorDark,
          ),
          onPressed: () {
            setState(() => _passwordVisible = !_passwordVisible);
          },
        ),
      ),
    );
  }

  Widget _buildLoginButton(LoginViewModel loginViewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C522A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        onPressed: loginViewModel.isLoading
            ? null
            : () async {
                if (_formKey.currentState?.validate() != true) return;

                await loginViewModel.login();

                if (loginViewModel.errorMessage != null &&
                    loginViewModel.errorMessage!.isNotEmpty) {
                  scaffoldMessengerError(context, loginViewModel.errorMessage!);
                } else {
                  scaffoldMessengerSuccess(context);
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.pushReplacementNamed(context, '/home_page');
                  });
                }
              },
        child: loginViewModel.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text('Login', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
