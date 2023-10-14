import 'dart:convert';

import 'package:flutter/material.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'package:segadi/services/login_local_auth/auth_login.dart';
import 'package:segadi/services/globals.dart';

import 'package:segadi/services/login_local_auth/biometric_authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
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
    //init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("assets/images/logo1.png"),
                SizedBox(
                  height: 25,
                ),
                TextFormField(
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (value) {
                    username = value;
                  },
                ),
                SizedBox(
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
                      onPressed: () {
                        print('Has olvidado tu contraseña ?');
                      },
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
                SizedBox(
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
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                    child: Column(children: <Widget>[
                  if (username.isNotEmpty && password.isNotEmpty)
                    buildAuthenticate(context),
                ])),
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

  Widget buildAuthenticate(BuildContext context) => buildButton(
        text: '',
        icon: Icons.fingerprint,
        onClicked: () async {
          final isAuthenticated = await localAuth.authenticate();

          if (isAuthenticated) {
            http.Response response =
                await AuthServices.login(username, password);
            Map responseMap = jsonDecode(response.body);

            print(responseMap['user']['id']);

            if (response.statusCode == 200) {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('token', responseMap['token']);
              prefs.setInt('id', responseMap['user']['id']);
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
            minimumSize: Size.fromHeight(60),
            padding: EdgeInsets.only(top: 10, left: 9, bottom: 10),
            shape: const CircleBorder(),
            backgroundColor: Colors.green),
        icon: Icon(icon, size: 50),
        label: Text(
          text,
          style: TextStyle(fontSize: 20),
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
          prefs.setString('name', responseMap["user"]['name']);
          prefs.setString('email', responseMap["user"]['email']);
          prefs.setString('token', responseMap['token']);

          Navigator.pushNamed(context, '/home_page');
        }
        if (response.statusCode == 401) {
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
