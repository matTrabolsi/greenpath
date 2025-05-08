import 'package:flutter/material.dart';
import 'package:greengath/home.dart';
import 'package:greengath/noti_service.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  NotiService().initNotification();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
    primaryColor: Colors.green, // changes selection handle color
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green, // updates Material 3 styles
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.green, // blinking cursor color
      selectionColor: Colors.green.withOpacity(0.3), // highlight color
      selectionHandleColor: Colors.green, // the small circle
    ),
  ),

  ));
}


