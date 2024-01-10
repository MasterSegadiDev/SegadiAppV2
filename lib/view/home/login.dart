import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:segadi/view_model/login_local_auth/auth_login.dart';
import 'package:segadi/view_model/globals.dart';

import 'package:segadi/view_model/login_local_auth/biometric_authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = "";
  String password = "";
  String value = "";
  int id = 0;
  String token = "";

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      password = prefs.getString('password') ?? '';
      id = prefs.getInt('id') ?? 0;
      token = prefs.getString('token') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("assets/images/logo1.png"),
                const SizedBox(
                  height: 30,
                ),
                if (username.isNotEmpty && password.isNotEmpty) fingerPrint(),
                if (username.isEmpty && password.isEmpty) formLoginButton(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.phone),
        onPressed: () {
          // FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }

  formLoginButton() {
    return Column(
      children: [
        TextFormField(
          keyboardType: TextInputType.name,
          decoration: const InputDecoration(
            labelText: 'Usuario',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          onChanged: (value) {
            username = value;
          },
        ),
        const SizedBox(
          height: 20,
        ),
        TextFormField(
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
            suffixIcon: Icon(Icons.remove_red_eye),
          ),
          onChanged: (value) {
            password = value;
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Has olvidado tu contraseña ?',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          child: MaterialButton(
            onPressed: () => loginPressed(),
            color: Colors.green,
            child: const Text(
              'LOGIN',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }

  fingerPrint() {
    return Column(children: [
      buildAuthenticate(context),
    ]);
  }

  Widget buildAuthenticate(BuildContext context) => buildButton(
        text: '',
        icon: Icons.fingerprint,
        onClicked: () async {
          final isAuthenticated = await localAuth.authenticate();

          if (isAuthenticated) {
            http.Response response =
                await AuthServices.login(username, password);
            Map responseMap = jsonDecode(response.body);

            if (response.statusCode == 200) {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('token', responseMap['token']);
              prefs.setInt('id', responseMap['user']['id']);
              // ignore: use_build_context_synchronously
              Navigator.pushNamed(context, '/home_page');
            }
          }
        },
      );

  Widget buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onClicked,
  }) =>
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(60),
            padding: const EdgeInsets.only(top: 10, left: 9, bottom: 10),
            shape: const CircleBorder(),
            backgroundColor: Colors.green),
        icon: Icon(icon, size: 50),
        label: Text(
          text,
          style: const TextStyle(fontSize: 20),
        ),
        onPressed: onClicked,
      );

  loginPressed() async {
    if (username.isNotEmpty) {
      if (password.isNotEmpty) {
        http.Response response = await AuthServices.login(username, password);
        Map responseMap = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setInt('id', responseMap["user"]['id']);

          prefs.setString('username', username);
          prefs.setString('password', password);

          prefs.setString('name', responseMap["user"]['name']);
          prefs.setString('email', responseMap["user"]['email']);
          prefs.setString('token', responseMap['token']);

          // ignore: use_build_context_synchronously
          Navigator.pushNamed(context, '/home_page');
        }
        if (response.statusCode == 401) {
          // ignore: use_build_context_synchronously
          errorSnackBar(context, responseMap['error_message']);
        }
      } else {
        errorSnackBar(context, 'El campo Contraseña es requerido');
      }
    } else {
      errorSnackBar(context, 'El campo Usuario es requerido');
    }
  }
}
