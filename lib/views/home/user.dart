// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:segadi/helper/messages.dart';
// import 'package:segadi/viewmodels/devices/device_view_model.dart';

// class UserScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final deviceAndUserViewModel = Provider.of<DeviceInfoViewModel>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Registro Usuario Segadi Operador',
//           style: TextStyle(color: Colors.white, fontSize: 17),
//         ),
//         backgroundColor: Color(0xFF2C522A),
//         iconTheme: IconThemeData(
//           color: Color(0xFF2C522A),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(10),
//         child: Column(
//           children: <Widget>[
//             Padding(
//               padding: EdgeInsets.all(10),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       height: 15,
//                     ),
//                     TextFormField(
//                       style: TextStyle(height: 1),
//                       onChanged: (value) =>
//                           deviceAndUserViewModel.validateInputName(value),
//                       decoration: InputDecoration(
//                         labelText: 'Nombre',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(100),
//                           borderSide: BorderSide(
//                             color: deviceAndUserViewModel.isValidName
//                                 ? Colors.green
//                                 : Colors.red,
//                             width: 2.0,
//                           ),
//                         ),
//                         errorText: deviceAndUserViewModel.isValidName
//                             ? null
//                             : 'El campo Nombre es requerido',
//                         prefixIcon: Icon(Icons.person),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     TextFormField(
//                       style: TextStyle(height: 1),
//                       keyboardType: TextInputType.name,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(100),
//                           borderSide: BorderSide(
//                             color: deviceAndUserViewModel.isValidFirstName
//                                 ? Colors.green
//                                 : Colors.red,
//                             width: 2.0,
//                           ),
//                         ),
//                         errorText: deviceAndUserViewModel.isValidFirstName
//                             ? null
//                             : 'El campo Apellido Paterno es requerido',
//                         labelText: 'Apellido Paterno',
//                         prefixIcon: Icon(Icons.person),
//                       ),
//                       // controller: travelExpensesViewModel.textController,
//                       onChanged: (value) =>
//                           deviceAndUserViewModel.validateInputFirstName(value),
//                     ),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     TextFormField(
//                       style: TextStyle(height: 1),
//                       keyboardType: TextInputType.name,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(100)),
//                         labelText: 'Apellido Materno',
//                         prefixIcon: Icon(Icons.person),
//                       ),
//                       // controller: travelExpensesViewModel.textController,
//                       onChanged: (value) =>
//                           deviceAndUserViewModel.lastName = value,
//                     ),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     TextFormField(
//                       style: TextStyle(height: 1),
//                       keyboardType: TextInputType.phone,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(100),
//                           borderSide: BorderSide(
//                             color: deviceAndUserViewModel.isValidPhoneJob
//                                 ? Colors.green
//                                 : Colors.red,
//                             width: 2.0,
//                           ),
//                         ),
//                         errorText: deviceAndUserViewModel.isValidPhoneJob
//                             ? null
//                             : 'El campo Télefono Empresarial es requerido',
//                         labelText: 'Número de télefono Empresarial',
//                         prefixIcon: Icon(Icons.phone),
//                       ),
//                       // controller: travelExpensesViewModel.textController,
//                       onChanged: (value) =>
//                           deviceAndUserViewModel.validateInputPhoneJob(value),
//                     ),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     TextFormField(
//                       style: TextStyle(height: 1),
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(100),
//                           borderSide: BorderSide(
//                             color: deviceAndUserViewModel.isValidPhonePerson
//                                 ? Colors.green
//                                 : Colors.red,
//                             width: 2.0,
//                           ),
//                         ),
//                         errorText: deviceAndUserViewModel.isValidPhonePerson
//                             ? null
//                             : 'El campo Télefono Personal es requerido',
//                         labelText: 'Número de télefono Personal',
//                         prefixIcon: Icon(Icons.phone),
//                       ),
//                       // controller: travelExpensesViewModel.textController,
//                       keyboardType: TextInputType.numberWithOptions(
//                         decimal: true,
//                         signed: true,
//                       ),
//                       onChanged: (value) => deviceAndUserViewModel
//                           .validateInputPhonePerson(value),
//                       //  travelExpensesViewModel.import = value,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             if (deviceAndUserViewModel.isLoading)
//               CircularProgressIndicator()
//             else
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2C522A),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(100),
//                     ),
//                     fixedSize: Size(1000, double.infinity)),
//                 onPressed: () async {
//                   await deviceAndUserViewModel.saveDataDevice();
//                   if (deviceAndUserViewModel.errorMessage != '') {
//                     scaffoldMessengerError(
//                         context, deviceAndUserViewModel.errorMessage);
//                   } else if (deviceAndUserViewModel.bandera == true) {
//                     Future.delayed(
//                       Duration(seconds: 3),
//                       () {
//                         Navigator.of(context).pop();
//                         Navigator.pushNamed(context, '/home_page');
//                       },
//                     );
//                   }
//                 },
//                 child: Text(
//                   'Registrarme e Ingresar',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
