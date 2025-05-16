import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import 'package:segadi/helper/messages.dart';
import 'package:segadi/viewmodels/login/biometric_viewmodel.dart';
import 'package:segadi/viewmodels/login/user_login.dart';

class LoginView extends StatefulWidget {
  LoginView({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginView> {
  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);
    final biometricViewModel = Provider.of<BiometricViewModel>(context);
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset("assets/images/logo1.png", width: size.width * 0.5),

                const SizedBox(height: 24),

                // Bienvenida
                AutoSizeText('Bienvenido',
                    style: Theme.of(context).textTheme.titleLarge),
                // AutoSizeText(loginViewModel.name,
                //     style: Theme.of(context).textTheme.bodyLarge),

                const SizedBox(height: 24),

                // Usuario
                _buildTextField(
                  controller: loginViewModel.usernameController,
                  label: 'Usuario',
                  icon: Icons.person,
                  onChanged: (value) => loginViewModel.username = value,
                ),

                const SizedBox(height: 16),

                // Contraseña
                _buildPasswordField(loginViewModel),

                const SizedBox(height: 24),

                // Botón de login o loading
                loginViewModel.isLoading
                    ? const CircularProgressIndicator()
                    : _buildLoginButton(loginViewModel),

                const SizedBox(height: 16),

                // Biometría si está disponible
                if (biometricViewModel.isBiometricAvailable == true)
                  _buildBiometricButton(biometricViewModel),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
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
        onPressed: () async {
          await loginViewModel.login();
          if (loginViewModel.errorMessage == null) {
            scaffoldMessengerSuccess(context);
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushNamed(context, '/home_page');
            });
          }
        },
        child: const Text('Login', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildBiometricButton(BiometricViewModel biometricViewModel) {
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
        onPressed: () async {
          await biometricViewModel.authenticate();
          if (biometricViewModel.isAuthenticatedWithToken) {
            scaffoldMessengerSuccess(context);
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushNamed(context, '/home_page');
            });
          } else {
            scaffoldMessengerError(
                context, 'Inicia sesión con tu Usuario y Contraseña');
          }
        },
        child: const Text('Acceder con biometría',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
