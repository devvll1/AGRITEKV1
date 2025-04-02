import 'package:agritek/Authentication/widget_tree.dart';
import 'package:agritek/Login/profile.dart';
import 'package:agritek/Login/profilesetup.dart';
import 'package:agritek/Updates/Weather/weather.dart';
import 'package:agritek/Updates/Weather/weekforecast.dart';
import 'package:agritek/homepage.dart';
import 'package:flutter/material.dart';
import 'package:agritek/farmguide.dart';
import 'package:agritek/Login/login.dart';
import 'Login/change_password.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:agritek/Agricultural%20Guides/add_info.dart';
import 'package:agritek/Agricultural%20Guides/view_guides.dart';

// Your custom color class
class AppColor {
  static const Color background = Color(0xFFE5E5E5);
  // Add more custom colors here
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
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
        '/home': (context) => const FarmGuidePage(),
        '/addinfo': (context) => const AddInformationForm(),
        '/viewcrops': (context) => const ViewGuides(),
        '/weather': (context) => const WeatherScreen(),
        '/forecast': (context) => const SevenDaysForecastScreen()
      },
    );
  }
}
