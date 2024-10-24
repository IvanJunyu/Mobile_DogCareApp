import 'package:flutter/material.dart';
import 'database_help.dart';  

class SickDogScreen extends StatefulWidget {
  final String dogName;

  SickDogScreen({required this.dogName});

  @override
  _SickDogScreenState createState() => _SickDogScreenState();
}

class _SickDogScreenState extends State<SickDogScreen> {
  bool isCoughing = false;
  bool isVomiting = false;
  bool isItching = false;
  bool hasFever = false;

  Future<void> _findIllnesses() async {
    List<String> symptoms = [];

    if (isCoughing) symptoms.add('Coughing');
    if (isVomiting) symptoms.add('Vomiting');
    if (isItching) symptoms.add('Itching');
    if (hasFever) symptoms.add('Fever');

    List<String> illnesses = await DatabaseHelper.getIllnessesBySymptoms(symptoms);

    if (illnesses.isEmpty) {
      illnesses.add('No matching illnesses found.');
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Possible Illnesses', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: illnesses.map((illness) => Text(illness)).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Is ${widget.dogName} Sick?')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSymptomSwitch('Coughing', isCoughing, (value) => setState(() => isCoughing = value)),
            _buildSymptomSwitch('Vomiting', isVomiting, (value) => setState(() => isVomiting = value)),
            _buildSymptomSwitch('Itching', isItching, (value) => setState(() => isItching = value)),
            _buildSymptomSwitch('Having a Fever', hasFever, (value) => setState(() => hasFever = value)),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _findIllnesses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,  
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),  
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),  
                  ),
                ),
                child: Text('Find Possible Illnesses'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomSwitch(String symptomName, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),  
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(symptomName, style: TextStyle(fontSize: 16)),
          Container(
           
            padding: EdgeInsets.all(4), 
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
