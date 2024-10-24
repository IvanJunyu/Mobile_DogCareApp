import 'package:flutter/material.dart';
import 'main_page.dart';   
import 'setting_page.dart'; 
import 'database_help.dart';    

void main() {
  runApp(DogCaringApp());
}

class DogCaringApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog Caring App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AppNavigator(),
    );
  }
}

class AppNavigator extends StatelessWidget {
  Future<bool> _checkPetData() async {
    final petData = await DatabaseHelper.getPetData();
    return petData != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkPetData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error loading data')));
        } else {
          bool hasPetData = snapshot.data ?? false;
          return hasPetData ? MainPage() : SettingPage();
        }
      },
    );
  }
}
