import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'db_helper.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Timer foodTimer, waterTimer, playTimer, walkTimer;
  Duration foodCountdown = Duration(hours: 24);
  Duration waterCountdown = Duration(hours: 24);
  Duration playCountdown = Duration(hours: 24);
  Duration walkCountdown = Duration(hours: 24);
  int foodSupply = 0;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadData();
    _startCountdownTimers();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadData() async {
    final data = await DBHelper.getData('PetCare');
    if (data.isNotEmpty) {
      setState(() {
        foodSupply = data[0]['foodSupply'];
      });
    }
  }

  void _startCountdownTimers() {
    foodTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (foodCountdown.inSeconds > 0) {
          foodCountdown = foodCountdown - Duration(seconds: 1);
        } else {
          _showNotification("Food time has reached 0!");
          foodTimer.cancel();
        }
      });
    });

    // Similar setup for waterTimer, playTimer, walkTimer
  }

  void _resetTimer(Timer timer, Duration countdown) {
    timer.cancel();
    setState(() {
      countdown = Duration(hours: 24); // Reset to 24 hours
    });
    _startCountdownTimers();
  }

  void _decrementFoodSupply() {
    setState(() {
      foodSupply--;
    });
    if (foodSupply == 3) {
      _showNotification("Food supply is low, please restock soon!");
    } else if (foodSupply == 0) {
      _showNotification("Out of food! Please buy more immediately!");
    }
  }

  Future<void> _showNotification(String message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id', // Channel ID
    'your_channel_name', // Channel Name
    channelDescription: 'your_channel_description', // Channel Description
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    'Pet Care Reminder', // Notification Title
    message, // Notification Body
    platformChannelSpecifics, // Platform-specific notification details
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Care Dashboard'),
      ),
      body: Column(
        children: [
          Text('Food Countdown: ${foodCountdown.inHours}:${foodCountdown.inMinutes.remainder(60)}:${foodCountdown.inSeconds.remainder(60)}'),
          ElevatedButton(onPressed: () => _resetTimer(foodTimer, foodCountdown), child: Text('Reset Food Timer')),
          // Similar UI for Water, Play, and Walk Countdown
          SizedBox(height: 20),
          Text('Food Supply: $foodSupply'),
          ElevatedButton(onPressed: _decrementFoodSupply, child: Text('Use One Food')),
        ],
      ),
    );
  }
}
