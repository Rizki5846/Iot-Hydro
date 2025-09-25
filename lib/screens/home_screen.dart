import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mqtt_provider.dart';
import '../widgets/sensor_chart.dart';
import '../widgets/sensor_card.dart';
import '../models/sensor_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<SensorData> history = [];

  @override
  Widget build(BuildContext context) {
    final mqttProvider = Provider.of<MqttProvider>(context);
    final data = mqttProvider.latestData;

    if (data != null) {
      if (history.length >= 20) history.removeAt(0);
      history.add(data);
    }

    final tempHistory = history.map((e) => e.temperature).toList();
    final humHistory = history.map((e) => e.humidity).toList();
    final phHistory = history.map((e) => e.ph).toList();
    final ecHistory = history.map((e) => e.ec).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Hidroponik Dashboard"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        leading: const Icon(Icons.eco),
      ),
      body: data == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Device: ${data.deviceId}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      SensorCard(
                        label: "Temperature",
                        value: "${data.temperature} °C",
                        color: Colors.red,
                        icon: Icons.thermostat,
                      ),
                      SensorCard(
                        label: "Humidity",
                        value: "${data.humidity} %",
                        color: Colors.blue,
                        icon: Icons.water_drop,
                      ),
                      SensorCard(
                        label: "pH",
                        value: "${data.ph}",
                        color: Colors.green,
                        icon: Icons.science,
                      ),
                      SensorCard(
                        label: "EC",
                        value: "${data.ec} mS/cm",
                        color: Colors.orange,
                        icon: Icons.bolt,
                      ),
                      SensorCard(
                        label: "Water Level",
                        value: "${data.waterLevel} %",
                        progress: data.waterLevel / 100,
                        color: data.waterLevel < 30 ? Colors.red : Colors.green,
                      ),
                      SensorCard(
                        label: "Pump",
                        value: data.pumpOn ? "ON" : "OFF",
                        isOn: data.pumpOn,
                        icon: Icons.power,
                        color: data.pumpOn ? Colors.green : Colors.grey, // <--- tambahkan ini
                        onPressed: () {
                          mqttProvider.sendPumpCommand(!data.pumpOn);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SensorChart(
                    label: "Temperature History",
                    data: tempHistory,
                    color: Colors.red,
                  ),
                  SensorChart(
                    label: "Humidity History",
                    data: humHistory,
                    color: Colors.blue,
                  ),
                  SensorChart(
                    label: "pH History",
                    data: phHistory,
                    color: Colors.green,
                  ),
                  SensorChart(
                    label: "EC History",
                    data: ecHistory,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
    );
  }
}
