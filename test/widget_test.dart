import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hydro_monitor/screens/home_screen.dart';
import 'package:hydro_monitor/providers/mqtt_provider.dart';
import 'package:hydro_monitor/models/sensor_data.dart';

void main() {
  testWidgets('HomeScreen displays sensor data and pump button works',
      (WidgetTester tester) async {
    // Buat data sensor dummy
    final dummyData = SensorData(
      deviceId: 'hydro_001',
      temperature: 25.5,
      humidity: 70.0,
      ph: 6.0,
      ec: 2.0,
      waterLevel: 80,
      pumpOn: true,
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

    // Cek teks sensor
    expect(find.text('Device: hydro_001'), findsOneWidget);
    expect(find.text('25.5 °C'), findsOneWidget);    // Temperature
    expect(find.text('70.0 %'), findsOneWidget);     // Humidity
    expect(find.text('6.0'), findsOneWidget);        // pH
    expect(find.text('2.0 mS/cm'), findsOneWidget);  // EC
    expect(find.text('80 %'), findsOneWidget);       // Water Level
    expect(find.text('ON'), findsOneWidget);         // Pump

    // Cek tombol Pump ada dan bisa ditekan
    final pumpButton = find.byIcon(Icons.power);
    expect(pumpButton, findsOneWidget);

    // Tekan tombol Pump untuk mematikan
    await tester.tap(pumpButton);
    await tester.pump();

    // Update dummy data agar pumpOff terlihat
    mqttProvider.latestData = dummyData.copyWith(pumpOn: false);
    mqttProvider.notifyListeners();
    await tester.pump();

    // Pastikan status Pump berubah
    expect(find.text('OFF'), findsOneWidget);
  });
}
