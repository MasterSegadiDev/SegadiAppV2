import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:segadi/view_model/login_local_auth/auth_login.dart';
import 'package:segadi/view_model/globals.dart';

import 'package:segadi/view_model/login_local_auth/biometric_authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = "";
  String password = "";
  String name = "";
  String value = "";
  int id = 0;
  String token = "";

  //String usernamePrefs = "";
  //String passwordPrefs = "";

  late bool _passwordVisible;

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      //  usernamePrefs = prefs.getString('username') ?? '';
      name = prefs.getString('name') ?? '';
      //  passwordPrefs = prefs.getString('password') ?? '';
      id = prefs.getInt('id') ?? 0;
      token = prefs.getString('token') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C522A),
        iconTheme: const IconThemeData(color: Color(0xFF2C522A)),
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
                  height: 15,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bienvenido',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                formLoginButton(),
                fingerPrint(),
                const Divider(
                  height: 15.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.phone,
          color: Colors.white,
        ),
        onPressed: () {
          FlutterPhoneDirectCaller.callNumber('+523311364928');
          //FlutterPhoneDirectCaller.callNumber('+523318817103');
          alert();
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
          keyboardType: TextInputType.text,
          //controller: _userPasswordController,
          obscureText: !_passwordVisible, //This will obscure text dynamically
          decoration: InputDecoration(
            //labelText: 'Usuario',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock),

            hintText: 'Contraseña',
            // Here is key idea
            suffixIcon: IconButton(
              icon: Icon(
                // Based on passwordVisible state choose the icon
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: () {
                // Update the state i.e. toogle the state of passwordVisible variable
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
          onChanged: (value) {
            password = value;
          },
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          child: MaterialButton(
            onPressed: () => loginPressed(),
            color: const Color(0xFF2C522A),
            child: const Text(
              'Login',
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
          final prefs = await SharedPreferences.getInstance();
          var usernamePrefs = prefs.getString('username') ?? '';
          var passwordPrefs = prefs.getString('password') ?? '';

          if (usernamePrefs.isEmpty || passwordPrefs.isEmpty) {
            String text =
                'Necesitas iniciar session con tu usuario y contraseña';
            errorSnackBar(context, text);
          } else {
            http.Response response =
                await AuthServices.login(usernamePrefs, passwordPrefs);
            Map responseMap = jsonDecode(response.body);

            if (response.statusCode == 401) {
              String text =
                  "Necesitas loguearte con tu usuario y contraseña primero";
              // ignore: use_build_context_synchronously
              errorSnackBar(context, text);
            } else if (response.statusCode == 200) {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('token', responseMap['token']);
              prefs.setInt('id', responseMap['user']['id']);
              prefs.setString(
                  'user_roll', responseMap['user']['empleado_permisionario']);
              // ignore: use_build_context_synchronously
              Navigator.pushNamed(context, '/home_page');
            }
          }
        }
      });

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
            backgroundColor: const Color(0xFF2C522A)),
        icon: Icon(
          icon,
          size: 50,
          color: Colors.white,
        ),
        label: Text(
          text,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        onPressed: onClicked,
      );

  loginPressed() async {
    if (username.isNotEmpty) {
      if (password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        var usernameStorage = prefs.getString('username') ?? '';
        var passwordStorage = prefs.getString('password') ?? '';

        if (username == usernameStorage && password == passwordStorage) {
          http.Response response = await AuthServices.login(username, password);
          Map responseMap = jsonDecode(response.body);

          if (response.statusCode == 200) {
            final prefs = await SharedPreferences.getInstance();

            prefs.setString('name', responseMap["user"]['name']);
            prefs.setString('email', responseMap["user"]['email']);
            prefs.setString('token', responseMap['token']);
            prefs.setString(
                'user_roll', responseMap['user']['empleado_permisionario']);

            // ignore: use_build_context_synchronously
            Navigator.pushNamed(context, '/home_page');
          } else if (response.statusCode == 401) {
            // ignore: use_build_context_synchronously
            errorSnackBar(context, responseMap['error_message']);
          }
        } else {
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
            prefs.setString(
                'user_roll', responseMap['user']['empleado_permisionario']);
            //username.isEmpty;
            //password.isEmpty;
            // ignore: use_build_context_synchronously
            Navigator.pushNamed(context, '/home_page');
          } else if (response.statusCode == 401) {
            // ignore: use_build_context_synchronously
            errorSnackBar(context, responseMap['error_message']);
          }
        }
      } else {
        errorSnackBar(context, 'El campo Contraseña es requerido');
      }
    } else {
      errorSnackBar(context, 'El campo Usuario es requerido');
    }
  }

  void alert() async {
    await AuthServices.alert();
  }
}
