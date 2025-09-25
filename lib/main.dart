import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mqtt_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const HydroApp());
}

class HydroApp extends StatelessWidget {
  const HydroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MqttProvider()..initializeMQTT(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hidroponik Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
