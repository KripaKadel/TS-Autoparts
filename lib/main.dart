import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:ts_autoparts_app/screens/login_screen.dart';
import 'package:ts_autoparts_app/screens/register_screen.dart';
import 'package:ts_autoparts_app/screens/home_screen.dart'; // Import HomeScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  
      title: 'TS Autoparts',
      initialRoute: '/',
      routes: {
        '/': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
      theme: ThemeData(
        // Apply the Montserrat font globally
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
        primaryColor: Color(0xFF144FAB), // Primary color for the app
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFF144FAB), // Primary color for buttons
        ),
      ),
    );
  }
}
