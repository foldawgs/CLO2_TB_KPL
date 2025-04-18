import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:switchcash/screens/history_screens.dart';
import 'package:switchcash/screens/home_screens.dart';
import 'package:switchcash/screens/list_screen.dart';
import 'package:switchcash/screens/welcome_screen.dart';
import 'package:switchcash/styles/app_colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Switch Cash',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        useMaterial3: true,
      ),
      home: WelcomeScreen(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreens(),
    HistoryScreens(),
    ListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.primary, // or any color you want
        // unselectedItemColor:
        //     Colors.white.withOpacity(0.6), // faded for unselected
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: 'Currency Rates',
          ),
        ],
      ),
    );
  }
}
