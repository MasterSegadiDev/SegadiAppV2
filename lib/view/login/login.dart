import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/helper/messages.dart';
import 'package:segadi/view_model/login/biometric_viewmodel.dart';
import 'package:segadi/view_model/login/user_login.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

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
        backgroundColor: const Color(0xFF2C522A),
        iconTheme: const IconThemeData(
          color: Color(0xFF2C522A),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                    loginViewModel.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100)),
                  prefixIcon: const Icon(Icons.person),
                ),
                onChanged: (value) => loginViewModel.username = value,
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100)),
                  prefixIcon: const Icon(Icons.lock),
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
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  //loginViewModel.removeAllPrefs();
                },
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "¿Quieres cambiar de usuario?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (loginViewModel.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      fixedSize: const Size(1000, double.infinity)),
                  onPressed: () async {
                    await loginViewModel.login();
                    if (loginViewModel.errorMessage != null) {
                      scaffoldMessengerError(
                          context, loginViewModel.errorMessage!);
                    } else {
                      scaffoldMessengerSuccess(context);
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pushNamed(context, '/home_page');
                      });
                    }
                  },
                  child: const Text('Login'),
                ),
              const SizedBox(
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          fixedSize: const Size(1000, double.infinity)),
      onPressed: () async {
        await biometricViewModel.authenticate();
        if (biometricViewModel.isAuthenticatedWithToken) {
        
          scaffoldMessengerSuccess(context);
         
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushNamed(context, '/home_page');
          });
        } else {
          scaffoldMessengerError(
             
              context,
              'Inicia sesion con tu Usuario y Contraseña');
        }
      },
      child: const Text('Acceder con biometria'),
    );
  }
}
