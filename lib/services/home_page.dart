import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Segadi'),
        ),
        body: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome SEGADI APP',
                  style: TextStyle(fontSize: 40),
                ),
                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      );
}
