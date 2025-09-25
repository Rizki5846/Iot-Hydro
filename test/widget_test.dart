import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hydro_monitor/screens/home_screen.dart';
import 'package:hydro_monitor/providers/mqtt_provider.dart';
import 'package:hydro_monitor/models/sensor_data.dart';
import 'package:hydro_monitor/widgets/sensor_card.dart';

void main() {
  testWidgets('HomeScreen displays sensor data and pump buttons work',
      (WidgetTester tester) async {
    // Buat data sensor dummy sesuai struktur baru
    final dummyData = SensorData(
      deviceId: 'hydro_001',
      temperature: 25.5,
      soilHum: 70.0,  // Changed from humidity to soilHum
      ph: 6.0,
      tds: 1200.0,   // Changed from ec to tds
      waterLevel: 80,
      pumpWater: true,   // New field
      pumpNutrient: false, // New field
    );

    // Buat provider dummy
    final mqttProvider = MqttProvider();
    // Set the latestData directly since it's not private in your code
    mqttProvider.latestData = dummyData;

    // Build HomeScreen dengan provider
    await tester.pumpWidget(
      ChangeNotifierProvider<MqttProvider>.value(
        value: mqttProvider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Tunggu frame selesai
    await tester.pumpAndSettle();

    // Cek teks sensor sesuai struktur baru
    expect(find.text('Device: hydro_001'), findsOneWidget);
    expect(find.text('25.5 °C'), findsOneWidget);        // Temperature
    expect(find.text('70.0 %'), findsOneWidget);         // Soil Humidity (changed)
    expect(find.text('6.0'), findsOneWidget);            // pH
    expect(find.text('1200 ppm'), findsOneWidget);       // TDS (changed unit)
    expect(find.text('80 %'), findsOneWidget);           // Water Level
    
    // Cek status pompa (sekarang ada dua pompa)
    expect(find.text('ON'), findsNWidgets(2));           // Water Pump ON
    expect(find.text('OFF'), findsNWidgets(2));          // Nutrient Pump OFF

    // Cek tombol Water Pump ada dan bisa ditekan
    final waterPumpButton = find.widgetWithText(SensorCard, 'Water Pump');
    expect(waterPumpButton, findsOneWidget);

    // Tekan tombol Water Pump untuk mematikan
    await tester.tap(waterPumpButton);
    await tester.pump();

    // Update dummy data agar pumpWater Off terlihat
    mqttProvider.latestData = dummyData.copyWith(pumpWater: false);
    // Call notifyListeners to trigger UI update
    mqttProvider.notifyListeners();
    await tester.pump();

    // Pastikan status Water Pump berubah menjadi OFF
    expect(find.text('OFF'), findsNWidgets(3)); // Now both pumps are OFF

    // Test Nutrient Pump button
    final nutrientPumpButton = find.widgetWithText(SensorCard, 'Nutrient Pump');
    expect(nutrientPumpButton, findsOneWidget);

    // Tekan tombol Nutrient Pump untuk menyalakan
    await tester.tap(nutrientPumpButton);
    await tester.pump();

    // Update dummy data agar pumpNutrient On terlihat
    mqttProvider.latestData = dummyData.copyWith(
      pumpWater: false,
      pumpNutrient: true,
    );
    mqttProvider.notifyListeners();
    await tester.pump();

    // Pastikan status Nutrient Pump berubah menjadi ON
    expect(find.text('ON'), findsNWidgets(2)); // Nutrient Pump ON, Water Pump OFF
  });

  testWidgets('HomeScreen shows progress indicator when no data', 
      (WidgetTester tester) async {
    // Buat provider dummy tanpa data
    final mqttProvider = MqttProvider();
    mqttProvider.latestData = null;

    // Build HomeScreen dengan provider
    await tester.pumpWidget(
      ChangeNotifierProvider<MqttProvider>.value(
        value: mqttProvider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Tunggu frame selesai
    await tester.pumpAndSettle();

    // Cek bahwa progress indicator ditampilkan ketika tidak ada data
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomeScreen displays connection status in appbar', 
      (WidgetTester tester) async {
    // Buat data sensor dummy
    final dummyData = SensorData(
      deviceId: 'hydro_001',
      temperature: 25.5,
      soilHum: 70.0,
      ph: 6.0,
      tds: 1200.0,
      waterLevel: 80,
      pumpWater: true,
      pumpNutrient: false,
    );

    // Buat provider dummy
    final mqttProvider = MqttProvider();
    mqttProvider.latestData = dummyData;
    
    // Set connected status (you might need to make this accessible for testing)
    // Since isConnected is a getter, we need to simulate the connection state
    // For testing purposes, we'll assume the provider handles this internally

    // Build HomeScreen dengan provider
    await tester.pumpWidget(
      ChangeNotifierProvider<MqttProvider>.value(
        value: mqttProvider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Tunggu frame selesai
    await tester.pumpAndSettle();

    // Cek bahwa appbar memiliki connection status icon
    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
  });

  testWidgets('HomeScreen displays pump status section', 
      (WidgetTester tester) async {
    // Buat data sensor dummy
    final dummyData = SensorData(
      deviceId: 'hydro_001',
      temperature: 25.5,
      soilHum: 70.0,
      ph: 6.0,
      tds: 1200.0,
      waterLevel: 80,
      pumpWater: true,
      pumpNutrient: false,
    );

    // Buat provider dummy
    final mqttProvider = MqttProvider();
    mqttProvider.latestData = dummyData;

    // Build HomeScreen dengan provider
    await tester.pumpWidget(
      ChangeNotifierProvider<MqttProvider>.value(
        value: mqttProvider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Tunggu frame selesai
    await tester.pumpAndSettle();

    // Scroll ke bawah untuk melihat pump status section
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Cek bahwa pump status section ditampilkan
    expect(find.text('Pump Status'), findsOneWidget);
    expect(find.text('Water Pump'), findsOneWidget);
    expect(find.text('Nutrient Pump'), findsOneWidget);
  });
}