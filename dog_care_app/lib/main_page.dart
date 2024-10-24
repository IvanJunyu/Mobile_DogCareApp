import 'package:flutter/material.dart';
import 'database_help.dart';
import 'dart:async';
import 'dart:convert';   
import 'setting_page.dart';
import 'sick_dog_screen.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map<String, dynamic>? petData;
  Timer? _foodTimer, _waterTimer, _playTimer, _walkTimer;
  int _foodTime = 0, _waterTime = 0, _playTime = 0, _walkTime = 0;
  Image? petImage;

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    petData = await DatabaseHelper.getPetData();
    if (petData != null) {
      setState(() {
        _foodTime = petData!['foodPeriod'] * 60;
        _waterTime = petData!['waterPeriod'] * 60;
        _playTime = petData!['playPeriod'] * 60;
        _walkTime = petData!['walkPeriod'] * 60;
        _loadPetImage();  
      });
      _startTimers();
    }
  }

  void _loadPetImage() {
    if (petData!['image'] != null) {
      final bytes = base64Decode(petData!['image']);
      petImage = Image.memory(bytes, height: 150);   
    }
  }

  void _startTimers() {
    _foodTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_foodTime > 0) {
          _foodTime--;
        }
      });
    });

    _waterTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_waterTime > 0) {
          _waterTime--;
        }
      });
    });

    _playTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_playTime > 0) {
          _playTime--;
        }
      });
    });

    _walkTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_walkTime > 0) {
          _walkTime--;
        }
      });
    });
  }

  String _getPetState() {
    bool isHungry = _foodTime == 0;
    bool isThirsty = _waterTime == 0;
    bool isBored = _playTime == 0 || _walkTime == 0;

    if (isHungry && isThirsty && isBored) {
      return '${petData!['name']} needs care now!!';
    } else if (isHungry && isThirsty) {
      return '${petData!['name']} is hungry and thirsty';
    } else if (isHungry && isBored) {
      return '${petData!['name']} is hungry and bored';
    } else if (isThirsty && isBored) {
      return '${petData!['name']} is thirsty and bored';
    } else if (isHungry) {
      return '${petData!['name']} is hungry';
    } else if (isThirsty) {
      return '${petData!['name']} is thirsty';
    } else if (isBored) {
      return '${petData!['name']} is bored';
    } else {
      return '${petData!['name']} is happy!';
    }
  }

  Future<void> _showRandomTip() async {
    String tip = await DatabaseHelper.getRandomDogTip();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tip)),
    );
  }

  void _resetTimer(String timerType) async {
    Map<String, dynamic> mutablePetData = Map<String, dynamic>.from(petData!);

    switch (timerType) {
      case 'food':
        setState(() {
          _foodTime = mutablePetData['foodPeriod'] * 60;
          if (mutablePetData['foodLeft'] > 4) {
            mutablePetData['foodLeft'] -= 1;
          } else if(mutablePetData['foodLeft'] > 1){
            _showLessFoodMessage();
            mutablePetData['foodLeft'] -= 1;
          }else if(mutablePetData['foodLeft'] == 1){
            _showOutOfFoodMessage();
            mutablePetData['foodLeft'] -= 1;
          }else{
            _showOutOfFoodMessage();
          }
        });
        await DatabaseHelper.updatePetData(mutablePetData);
        petData = mutablePetData;
        break;
      case 'water':
        setState(() {
          _waterTime = mutablePetData['waterPeriod'] * 60;
        });
        break;
      case 'play':
        setState(() {
          _playTime = mutablePetData['playPeriod'] * 60;
        });
        break;
      case 'walk':
        setState(() {
          _walkTime = mutablePetData['walkPeriod'] * 60;
        });
        break;
    }
  }

  void _showOutOfFoodMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No food left! Please refill.')),
    );
  }

    void _showLessFoodMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Less food left! Please consider refill.')),
    );
  }

  Future<void> _resetSettings() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SettingPage()),
    );
  }

  Future<void> _addFood() async {
    int? additionalFood = await _showAddFoodDialog();

    if (additionalFood != null && additionalFood > 0) {
      Map<String, dynamic> mutablePetData = Map<String, dynamic>.from(petData!);
      setState(() {
        mutablePetData['foodLeft'] += additionalFood;
      });
      await DatabaseHelper.updatePetData(mutablePetData);
      petData = mutablePetData;
    }
  }

  Future<int?> _showAddFoodDialog() async {
    TextEditingController _foodController = TextEditingController();

    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Food'),
          content: TextField(
            controller: _foodController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Enter amount of food to add'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                int? additionalFood = int.tryParse(_foodController.text);
                if (additionalFood != null) {
                  Navigator.of(context).pop(additionalFood);
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToSickDogScreen() {
    if (petData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SickDogScreen(dogName: petData!['name']),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (petData == null) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text('${petData!['name']}\'s Care'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    children: [
      SizedBox(height: 25),  
      Text(
        'Best Care For ${petData!['name']}!',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ],
  ),
),


              if (petImage != null) petImage!,  
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _getPetState(),  
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),

               _buildCountdown('Food Timer', _foodTime, 'food', Icons.fastfood),
              _buildCountdown('Water Timer', _waterTime, 'water', Icons.local_drink),
              _buildCountdown('Play Timer', _playTime, 'play', Icons.sports_soccer),
              _buildCountdown('Walk Timer', _walkTime, 'walk', Icons.directions_walk),

               Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _navigateToSickDogScreen,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  child: Text('My Dog is Sick'),
                ),
              ),
            ],
          ),

           Positioned(
            top: -10,
            right: 16,
            child: Row(
              children: [
                Text('Food Left: ${petData!['foodLeft']}'),
                IconButton(
                 onPressed: _addFood,
                icon: Icon(Icons.add_circle, size: 25, color: Colors.green),
                ),
              ],
            ),
          ),

           Positioned(
            top: -10,
            left: 16,
            child: IconButton(
              onPressed: _resetSettings,
              icon: Icon(Icons.settings),
            ),
          ),
          Positioned(
            top: 15,
            right: 16,
             child: Row(
              children: [
                Text('Get tips'),
                IconButton(
                 onPressed: _showRandomTip,
                icon: Icon(Icons.lightbulb_circle, size: 25, color: Colors.yellow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown(String title, int timeLeft, String timerType, IconData icon) {
   int hours = timeLeft ~/ 3600;
  int minutes = (timeLeft % 3600) ~/ 60;
  int seconds = timeLeft % 60;

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Card(
      color: Colors.grey[300],
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
         subtitle: Text(
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        ),
        trailing: ElevatedButton(
          onPressed: () => _resetTimer(timerType),
          child: Text('Reset'),
        ),
      ),
    ),
  );
}


  @override
  void dispose() {
    _foodTimer?.cancel();
    _waterTimer?.cancel();
    _playTimer?.cancel();
    _walkTimer?.cancel();
    super.dispose();
  }
}
