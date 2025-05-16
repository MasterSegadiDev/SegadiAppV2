import 'package:flutter/material.dart';

class ContainerMovementsModal extends StatefulWidget {
  @override
  _ContainerMovementsModal createState() => _ContainerMovementsModal();
}

class _ContainerMovementsModal extends State<ContainerMovementsModal> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _inputController1 = TextEditingController();
  final TextEditingController _inputController2 = TextEditingController();
  final TextEditingController _inputController3 = TextEditingController();
  final TextEditingController _inputController4 = TextEditingController();
  final TextEditingController _inputController5 = TextEditingController();
  final TextEditingController _inputController6 = TextEditingController();
  final TextEditingController _inputController7 = TextEditingController();
  final TextEditingController _inputController8 = TextEditingController();

  // Variables para los select options
  String? _selectOption1;
  String? _selectOption2;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(''),
      contentPadding: EdgeInsets.zero, // Elimina padding predeterminado
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12), // Opcional, para bordes redondeados
      ),
      content: Container(
        width: 720, // Ancho al 100% del contenedor
        child: SingleChildScrollView(
          // Hace que el contenido sea desplazable
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextInput('Input 1', _inputController1),
                  _buildTextInput('Input 2', _inputController2),
                  _buildTextInput('Input 3', _inputController3),
                  _buildTextInput('Input 4', _inputController4),
                  _buildTextInput('Input 5', _inputController5),
                  _buildTextInput('Input 6', _inputController6),
                  _buildTextInput('Input 7', _inputController7),
                  _buildTextInput('Input 8', _inputController8),

                  // Selector de opción 1
                  _buildDropdown('Select Option 1', _selectOption1,
                      ['Option 1', 'Option 2', 'Option 3']),

                  // Selector de opción 2
                  _buildDropdown('Select Option 2', _selectOption2,
                      ['Option A', 'Option B', 'Option C']),

                  SizedBox(height: 20),
                  // ElevatedButton(
                  //   onPressed: _submitForm,
                  //   child: Text('Registrar Movimiento'),
                  // ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C522A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        fixedSize: Size(900, double.infinity)),
                    onPressed: () => _submitForm,
                    child: Text(
                      'Registrar Movimiento',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Función para mostrar un campo de texto
  Widget _buildTextInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  // Función para mostrar un campo de selección
  Widget _buildDropdown(
      String label, String? selectedValue, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            if (label == 'Select Option 1') {
              _selectOption1 = value;
            } else {
              _selectOption2 = value;
            }
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  // Función para manejar el envío del formulario
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Procesar el formulario
      print('Formulario enviado');
      print('Input 1: ${_inputController1.text}');
      print('Input 2: ${_inputController2.text}');
      print('Select Option 1: $_selectOption1');
      print('Select Option 2: $_selectOption2');
      // Aquí puedes manejar el envío de los datos (guardar, enviar a servidor, etc.)
    }
  }
}
