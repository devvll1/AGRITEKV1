import 'package:agritek/Authentication/widget_tree.dart';
import 'package:agritek/CropFarming/crop_farming.dart';
import 'package:agritek/CropFarming/croptypes.dart';
import 'package:agritek/CropFarming/fruits/fruit.dart';
import 'package:agritek/CropFarming/fruits/mango.dart';
import 'package:agritek/CropFarming/grains/corn.dart';
import 'package:agritek/CropFarming/grains/grain.dart';
import 'package:agritek/CropFarming/grass/grass.dart';
import 'package:agritek/CropFarming/legumes/legume.dart';
import 'package:agritek/CropFarming/vegetables/upo.dart';
import 'package:agritek/CropFarming/vegetables/vegetable.dart';
import 'package:agritek/FIsheries%20and%20Aquaculture/fisheries.dart';
import 'package:agritek/Forestry/forestry.dart';
import 'package:agritek/Livestock/chicken.dart';
import 'package:agritek/Livestock/livestock.dart';
import 'package:agritek/Livestock/livestocklist.dart';
import 'package:agritek/Login/profile.dart';
import 'package:agritek/Login/profilesetup.dart';
import 'package:agritek/Updates/weather.dart';
import 'package:agritek/Updates/weekforecast.dart';
import 'package:agritek/homepage.dart';
import 'package:flutter/material.dart';
import 'package:agritek/farmguide.dart';
import 'package:agritek/Login/login.dart';
import 'Login/change_password.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:agritek/CropFarming/add_info.dart';

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
        '/cropfarming': (context) => const CropFarmingScreen(),
        '/addinfo': (context) => const AddInformationForm(),
        '/forestry': (context) => const ForestryScreen(),
        '/aquaculture': (context) => const AquacultureScreen(),
        '/livestock': (context) => const LivestockScreen(),
        '/livestocklist': (context) => const LiveStockListScreen(),
        '/chicken': (context) => const Chicken(),
        '/croptypes': (context) => const TypeOfCropsScreen(),
        '/vegetables': (context) => const VegetablesApp(),
        '/upo': (context) => const Upo(),
        '/fruits': (context) => const FruitsApp(),
        '/mango': (context) => const Mango(),
        '/grains': (context) => const GrainsApp(),
        '/corn': (context) => const Corn(),
        '/grass': (context) => const GrassApp(),
        '/legumes': (context) => const LegumesApp(),
        '/weather': (context) => const WeatherScreen(),
        '/forecast': (context) => const SevenDaysForecastScreen()
      },
    );
  }
}
