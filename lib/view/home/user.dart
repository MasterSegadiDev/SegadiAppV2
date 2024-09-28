import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/view_model/devices/device_view_model.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceAndUserViewModel = Provider.of<DeviceInfoViewModel>(context);
    return Container(
      height: 600,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100)),
                        prefixIcon: Icon(Icons.person),
                      ),
                      //controller: deviceAndUserViewModel.usernameController,
                      onChanged: (value) =>
                          deviceAndUserViewModel.nameUser = value,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100)),
                        labelText: 'Apellido Paterno',
                      ),
                      // controller: travelExpensesViewModel.textController,
                      onChanged: (value) =>
                          deviceAndUserViewModel.firstName = value,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100)),
                        labelText: 'Apellido Materno',
                      ),
                      // controller: travelExpensesViewModel.textController,
                      onChanged: (value) =>
                          deviceAndUserViewModel.lastName = value,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100)),
                        labelText: 'Número de télefono',
                      ),
                      // controller: travelExpensesViewModel.textController,
                      onChanged: (value) =>
                          deviceAndUserViewModel.phoneNumber = value,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100)),
                        labelText: 'campo extra',
                      ),
                      // controller: travelExpensesViewModel.textController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      onChanged: null,
                      //  travelExpensesViewModel.import = value,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100)),
                        labelText: 'campo extra',
                      ),
                      // controller: travelExpensesViewModel.textController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      onChanged: null,
                      //  travelExpensesViewModel.import = value,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                deviceAndUserViewModel.saveDataDevice();
                                print(
                                    ' bandera ${deviceAndUserViewModel.bandera}');
                                if (deviceAndUserViewModel.bandera == true) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushNamed('/home_page');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(20), // <-- Radius
                                ),
                                backgroundColor: const Color(0xFF2C522A),
                              ),
                              child: Text(
                                'Registrarme e ingresar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
