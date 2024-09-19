import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/helper/messages.dart';
import 'package:segadi/view_model/login/biometric_viewmodel.dart';
import 'package:segadi/view_model/login/user_login.dart';

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2C522A),
        iconTheme: IconThemeData(
          color: Color(0xFF2C522A),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/images/logo1.png"),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    'Bienvenido',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    minFontSize: 13,
                    maxFontSize: 16,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    loginViewModel.name,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    minFontSize: 13,
                    maxFontSize: 16,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100)),
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (value) => loginViewModel.username = value,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100)),
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                onChanged: (value) => loginViewModel.password = value,
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {
                  //loginViewModel.removeAllPrefs();
                },
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "¿Quieres cambiar de usuario?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 10),
              if (loginViewModel.isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C522A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      fixedSize: Size(1000, double.infinity)),
                  onPressed: () async {
                    await loginViewModel.login();
                    if (loginViewModel.errorMessage != null) {
                      scaffoldMessengerError(
                          context, loginViewModel.errorMessage!);
                    } else {
                      scaffoldMessengerSuccess(context);
                      Future.delayed(Duration(seconds: 2), () {
                        Navigator.pushNamed(context, '/home_page');
                      });
                    }
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              SizedBox(
                height: 20,
              ),
              if (biometricViewModel.isBiometricAvailable == true)
                fingerPrint(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget fingerPrint(BuildContext context) {
    final biometricViewModel = Provider.of<BiometricViewModel>(context);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C522A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          fixedSize: Size(1000, double.infinity)),
      onPressed: () async {
        await biometricViewModel.authenticate();
        if (biometricViewModel.isAuthenticatedWithToken) {
          scaffoldMessengerSuccess(context);

          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushNamed(context, '/home_page');
          });
        } else {
          scaffoldMessengerError(
              context, 'Inicia sesion con tu Usuario y Contraseña');
        }
      },
      child: Text(
        'Acceder con biometria',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
