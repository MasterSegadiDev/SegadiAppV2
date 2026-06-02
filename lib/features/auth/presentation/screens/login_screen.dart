// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../view_models/login_view_model.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isPasswordVisible = false;

//   @override
//   Widget build(BuildContext context) {
//     // Escuchamos el ViewModel de esta pantalla
//     final vm = context.watch<LoginViewModel>();
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             colors: [Color(0xFF2C522A), Color(0xFF1B321A)],
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Container(
//               constraints: const BoxConstraints(maxWidth: 400),
//               padding: const EdgeInsets.all(30),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: const [
//                   BoxShadow(color: Colors.black26, blurRadius: 15)
//                 ],
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Image.asset("assets/images/logo1.png",
//                         width: size.width * 0.4),
//                     const SizedBox(height: 30),
//                     const Text('Bienvenido ',
//                         style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2C522A))),
//                     const SizedBox(height: 30),

//                     // Usuario
//                     _buildField(
//                       controller: vm.usernameController,
//                       label: 'Usuario',
//                       icon: Icons.person_outline,
//                     ),
//                     const SizedBox(height: 16),

//                     // Password
//                     _buildField(
//                       controller: vm.passwordController,
//                       label: 'Contraseña',
//                       icon: Icons.lock_outline,
//                       isPassword: true,
//                     ),
//                     const SizedBox(height: 30),

//                     _buildLoginButton(vm),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildField(
//       {required TextEditingController controller,
//       required String label,
//       required IconData icon,
//       bool isPassword = false}) {
//     return TextFormField(
//       controller: controller,
//       obscureText: isPassword && !_isPasswordVisible,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: const Color(0xFF2C522A)),
//         suffixIcon: isPassword
//             ? IconButton(
//                 icon: Icon(_isPasswordVisible
//                     ? Icons.visibility
//                     : Icons.visibility_off),
//                 onPressed: () =>
//                     setState(() => _isPasswordVisible = !_isPasswordVisible),
//               )
//             : null,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       validator: (val) => val!.isEmpty ? 'Campo obligatorio' : null,
//     );
//   }

//   Widget _buildLoginButton(LoginViewModel vm) {
//     return SizedBox(
//       width: double.infinity,
//       height: 55,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF2C522A),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         onPressed: vm.isLoading
//             ? null
//             : () async {
//                 if (_formKey.currentState!.validate()) {
//                   final success = await vm.login();
//                   if (!success && mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: Text(vm.errorMessage ?? 'Error de acceso')));
//                   }
//                 }
//               },
//         child: vm.isLoading
//             ? const CircularProgressIndicator(color: Colors.white)
//             : const Text('Iniciar Sesión',
//                 style: TextStyle(color: Colors.white)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // IMPORTANTE: Agregamos la importación de GoRouter
import '../view_models/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ViewModel de esta pantalla
    final vm = context.watch<LoginViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Color(0xFF2C522A), Color(0xFF1B321A)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 15)
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/images/logo1.png",
                        width: size.width * 0.4),
                    const SizedBox(height: 30),
                    const Text('Bienvenido ',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C522A))),
                    const SizedBox(height: 30),

                    // Usuario
                    _buildField(
                      controller: vm.usernameController,
                      label: 'Usuario',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    _buildField(
                      controller: vm.passwordController,
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),

                    _buildLoginButton(vm),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2C522A)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) => val!.isEmpty ? 'Campo obligatorio' : null,
    );
  }

  Widget _buildLoginButton(LoginViewModel vm) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C522A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: vm.isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  final success = await vm.login();

                  if (!mounted) return;

                  if (success) {
                    // --- ENRUTAMIENTO CONCRETO POR ROL ---
                    if (vm.currentRole == 'OPERADOR_TRAILER') {
                      context.go('/operaciones');
                    } else if (vm.currentRole == 'OPERADOR_GRUA') {
                      context.go('/contenedores');
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(vm.errorMessage ?? 'Error de acceso')));
                  }
                }
              },
        child: vm.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Iniciar Sesión',
                style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
