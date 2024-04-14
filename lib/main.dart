import 'package:flutter/material.dart';
import 'package:test_zalopay/screens/dashboard.dart';
import 'package:test_zalopay/utils/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: myTheme,
        debugShowCheckedModeBanner: false,
        home: const Dashboard(title: 'E Ticket', version: 'version1'));
  }
}
