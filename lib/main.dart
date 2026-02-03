import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const PrintProApp());
}

class PrintProApp extends StatelessWidget {
  const PrintProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrintPro Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        visualDensity: VisualDensity.compact,
        textTheme: GoogleFonts.interTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            displayMedium: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            displaySmall: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            headlineMedium: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
            titleLarge: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
            bodyLarge: TextStyle(fontSize: 14, color: Colors.black),
            bodyMedium: TextStyle(fontSize: 13, color: Colors.black),
            labelLarge: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
            labelSmall: TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
