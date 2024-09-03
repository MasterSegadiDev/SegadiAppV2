import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/view_model/user/user.dart';


class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Info'),
        ),
        body: Consumer<UserViewModel>(
          builder: (context, userViewModel, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Name: ${userViewModel.name}'),
                Text('Age: ${userViewModel.age}'),
                TextField(
                  onChanged: (newName) => userViewModel.updateName(newName),
                  decoration: const InputDecoration(labelText: 'Enter new name'),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (newAge) => userViewModel.updateAge(int.parse(newAge)),
                  decoration: const InputDecoration(labelText: 'Enter new age'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
