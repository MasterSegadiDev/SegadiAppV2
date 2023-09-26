import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:segadi/rounded_button.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:segadi/services/auth_login.dart';
import 'package:segadi/services/globals.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String user = '';
  String password = '';

  loginPressed() async {
    //if (user.isNotEmpty && password.isNotEmpty) {
    //http.Response response = await AuthServices.login(user, password);
    //  Map responseMap = jsonDecode(response.body);

    //if (response.statusCode == 200) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const HomeScreen(),
        ));
    // } else {
    // errorSnackBar(context, responseMap.values.first);
    // }
    //} else {
    //  errorSnackBar(context, 'enter all required fields');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(top: 100, bottom: 0),
              child: Image.network(
                  "https://segadi.com.mx/wp-content/uploads/Logo-Segadi.png"),
            ),
            //Body Container
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Usuario',
                            hintText: 'Ingresa tu usuario Jhon Doe'),
                        onChanged: (value) {
                          user = value;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                            hintText: 'Ingresa tu password'),
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    RoundedButton(
                      btnText: 'Login',
                      onBtnPressed: () => loginPressed(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.phone),
        onPressed: () {
          FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }
}
