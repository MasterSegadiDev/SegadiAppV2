import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:segadi/view/home/home.dart';
import 'package:segadi/view_model/globals.dart';
import 'package:segadi/view_model/login_local_auth/auth_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State createState() => _FormScreen();
}

class _FormScreen extends State<FormScreen> {
  String username = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C522A),
      ),
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
                const Divider(
                  height: 15.0,
                  color: Colors.white,
                ),
                Column(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  loginPressed() async {
    if (username.isNotEmpty) {
      if (password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        print(prefs.getKeys());
        /*http.Response response = await AuthServices.login(username, password);
        Map responseMap = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setInt('id', responseMap["user"]['id']);

          prefs.setString('username', username);
          prefs.setString('password', password);

          prefs.setString('name', responseMap["user"]['name']);
          prefs.setString('email', responseMap["user"]['email']);
          prefs.setString('token', responseMap['token']);
*/
        //returnHomeScreen();
      }
      /*  if (response.statusCode == 401) {
          // ignore: use_build_context_synchronously
          errorSnackBar(context, responseMap['error_message']);
        }
      } else {
        errorSnackBar(context, 'El campo Contraseña es requerido');
      }
    } else {
      errorSnackBar(context, 'El campo Usuario es requerido');
    }*/
    }
  }

  void returnHomeScreen() {
    Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const HomeScreen(),
      ),
    );
  }
}
