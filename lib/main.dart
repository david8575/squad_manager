import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/team_management_screen.dart';
import 'screens/formation_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '축구팀 매니저',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/team_management': (context) => TeamManagementScreen(),
        '/formation': (context) => FormationScreen(),
        '/schedule': (context) => ScheduleScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
