import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'main_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController petNameController = TextEditingController();
  TimeOfDay? foodTime;
  TimeOfDay? waterTime;
  TimeOfDay? playTime;
  TimeOfDay? walkTime;
  int foodSupply = 0;

  Future<void> _selectTime(BuildContext context, Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  Future<void> _submitData() async {
    await DBHelper.insert('PetCare', {
      'petName': petNameController.text,
      'foodTime': foodTime.toString(),
      'waterTime': waterTime.toString(),
      'playTime': playTime.toString(),
      'walkTime': walkTime.toString(),
      'foodSupply': foodSupply
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: petNameController,
              decoration: InputDecoration(labelText: 'Pet Name'),
            ),
            ElevatedButton(
              onPressed: () => _selectTime(context, (time) => setState(() => foodTime = time)),
              child: Text('Select Food Time'),
            ),
            ElevatedButton(
              onPressed: () => _selectTime(context, (time) => setState(() => waterTime = time)),
              child: Text('Select Water Time'),
            ),
            ElevatedButton(
              onPressed: () => _selectTime(context, (time) => setState(() => playTime = time)),
              child: Text('Select Play Time'),
            ),
            ElevatedButton(
              onPressed: () => _selectTime(context, (time) => setState(() => walkTime = time)),
              child: Text('Select Walk Time'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Food Supply (meals left)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  foodSupply = int.parse(value);
                });
              },
            ),
            ElevatedButton(
              onPressed: _submitData,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
