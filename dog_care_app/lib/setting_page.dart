import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';  
import 'database_help.dart';   
import 'main_page.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _foodPeriodController = TextEditingController();
  final TextEditingController _waterPeriodController = TextEditingController();
  final TextEditingController _playPeriodController = TextEditingController();
  final TextEditingController _walkPeriodController = TextEditingController();
  final TextEditingController _foodLeftController = TextEditingController();
  File? _selectedImage;
  String? _imageBase64;

  @override
  void initState() {
    super.initState();
    _loadPetData();   
  }

 Future<void> _loadPetData() async {
  final petData = await DatabaseHelper.getPetData();   

  if (petData != null) {
    setState(() {
      _nameController.text = petData['name'] ?? '';
       _foodPeriodController.text = (petData['foodPeriod'] ~/ 60).toString();  
      _waterPeriodController.text = (petData['waterPeriod'] ~/ 60).toString();  
      _playPeriodController.text = (petData['playPeriod'] ~/ 60).toString();  
      _walkPeriodController.text = (petData['walkPeriod'] ~/ 60).toString();  
      _foodLeftController.text = petData['foodLeft'].toString();
    });
  } else {
     print("No pet data found.");
  }
}


   Future<void> _chooseImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      final bytes = await _selectedImage!.readAsBytes();
      _imageBase64 = base64Encode(bytes);  
    }
  }

  Future<void> _submitData() async {
  if (_formKey.currentState!.validate()) {
     final petData = {
      'id': 1,   
      'name': _nameController.text,
      'foodPeriod': int.parse(_foodPeriodController.text) * 60,
      'waterPeriod': int.parse(_waterPeriodController.text) * 60,
      'playPeriod': int.parse(_playPeriodController.text) * 60,
      'walkPeriod': int.parse(_walkPeriodController.text) * 60,
      'foodLeft': int.parse(_foodLeftController.text),
      'image': _imageBase64,
    };
    
    await DatabaseHelper.insertOrUpdatePetData(petData);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }
}


  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),  
        borderSide: BorderSide(color: Colors.blue, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.grey[200],  
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pet Settings')),
      body: Center(  
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,   
              crossAxisAlignment: CrossAxisAlignment.center,  
              children: [
                Container(
                  width: 250,   
                  child: TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration('Pet\'s Name', Icons.pets),
                    validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                  ),
                ),
                SizedBox(height: 10),  
                Container(
                  width: 250,
                  child: TextFormField(
                    controller: _foodPeriodController,
                    decoration: _buildInputDecoration('Food Period (hours)', Icons.fastfood),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter food period' : null,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: 250,
                  child: TextFormField(
                    controller: _waterPeriodController,
                    decoration: _buildInputDecoration('Water Period (hours)', Icons.water),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter water period' : null,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: 250,
                  child: TextFormField(
                    controller: _playPeriodController,
                    decoration: _buildInputDecoration('Play Period (hours)', Icons.sports_soccer),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter play period' : null,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: 250,
                  child: TextFormField(
                    controller: _walkPeriodController,
                    decoration: _buildInputDecoration('Walk Period (hours)', Icons.directions_walk),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter walk period' : null,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: 250,
                  child: TextFormField(
                    controller: _foodLeftController,
                    decoration: _buildInputDecoration('Food Left', Icons.kitchen),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter food left' : null,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _chooseImage,
                  child: Text('Choose Image for Pet'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),  // Button style
                    ),
                  ),
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),  // Rounded image preview
                      child: Image.file(_selectedImage!, height: 150),  // Show selected image
                    ),
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _submitData,
                      child: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        textStyle: TextStyle(fontSize: 18),  // Bigger font size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),  // Rounded button
                        ),
                      ),
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
}
