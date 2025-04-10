// ignore_for_file: unused_element
import 'package:agritek/Authentication/widget_tree.dart';
import 'package:agritek/Login/profile.dart';
import 'package:agritek/Login/profilesetup.dart';
import 'package:agritek/Updates/Weather/weather.dart';
import 'package:agritek/Updates/Weather/weekforecast.dart';
import 'package:agritek/homepage.dart';
import 'package:flutter/material.dart';
import 'package:agritek/Login/login.dart';
import 'Login/change_password.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:agritek/Agricultural%20Guides/add_info.dart';
import 'package:agritek/Agricultural%20Guides/view_guides.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Your custom color class
class AppColor {
  static const Color background = Color(0xFFE5E5E5);
  // Add more custom colors here
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'high_importance_channel', // Channel ID
    'High Importance Notifications', // Channel name
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    message.notification?.title, // Notification title
    message.notification?.body, // Notification body
    platformChannelSpecifics,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  tz.initializeTimeZones();

  runApp(const MyApp());
}

void saveFcmToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fcmToken': fcmToken,
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColor.background,
        // You can add more theme properties here
      ),
      debugShowCheckedModeBanner: false,
      home: const WidgetTree(),
      routes: {
        '/login': (context) => const StartupPage(),
        '/profileSetup': (context) => const ProfileSetupPage(),
        '/changePassword': (context) => const ChangePasswordPage(),
        '/profile': (context) => const ProfilePage(),
        '/homepage': (context) => const HomePage(),
        '/addinfo': (context) => const AddInformationForm(),
        '/viewcrops': (context) => const ViewGuides(),
        '/weather': (context) => const WeatherScreen(),
        '/forecast': (context) => const SevenDaysForecastScreen()
      },
    );
  }
}
