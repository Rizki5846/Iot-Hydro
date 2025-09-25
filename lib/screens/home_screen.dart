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
    final soilHumHistory = history.map((e) => e.soilHum).toList();
    final phHistory = history.map((e) => e.ph).toList();
    final tdsHistory = history.map((e) => e.tds).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("🌱 Hidroponik Dashboard"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              mqttProvider.isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: Colors.white,
            ),
            onPressed: () {
              if (!mqttProvider.isConnected) {
                mqttProvider.initializeMQTT();
              }
            },
          ),
        ],
      ),
      body: data == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                if (!mqttProvider.isConnected) {
                  await mqttProvider.initializeMQTT();
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                          value: "${data.temperature.toStringAsFixed(1)} °C",
                          color: Colors.red,
                          icon: Icons.thermostat,
                        ),
                        SensorCard(
                          label: "Soil Humidity",
                          value: "${data.soilHum.toStringAsFixed(1)} %",
                          color: Colors.blue,
                          icon: Icons.water_drop,
                        ),
                        SensorCard(
                          label: "pH",
                          value: data.ph.toStringAsFixed(1),
                          color: Colors.green,
                          icon: Icons.science,
                        ),
                        SensorCard(
                          label: "TDS",
                          value: "${data.tds.toInt()} ppm",
                          color: Colors.orange,
                          icon: Icons.electrical_services,
                        ),
                        SensorCard(
                          label: "Water Level",
                          value: "${data.waterLevel} %",
                          progress: data.waterLevel / 100,
                          color: data.waterLevel < 30
                              ? Colors.red
                              : Colors.green,
                          icon: Icons.water_damage,
                        ),
                        // Water Pump
                        SensorCard(
                          label: "Water Pump",
                          value: data.pumpWater ? "ON" : "OFF",
                          isOn: data.pumpWater,
                          icon: Icons.water,
                          color: Colors.blue,
                          onPressed: () {
                            mqttProvider.sendWaterPumpCommand(!data.pumpWater);
                          },
                        ),
                        // Nutrient Pump
                        SensorCard(
                          label: "Nutrient Pump",
                          value: data.pumpNutrient ? "ON" : "OFF",
                          isOn: data.pumpNutrient,
                          icon: Icons.eco,
                          color: Colors.green,
                          onPressed: () {
                            mqttProvider
                                .sendNutrientPumpCommand(!data.pumpNutrient);
                          },
                          useMaterialButton: true, // pakai tombol Material
                        ),
                        // Combined Control
                        SensorCard(
                          label: "Both Pumps",
                          value: "${data.pumpWater && data.pumpNutrient ? 'BOTH ON' : data.pumpWater ? 'WATER ONLY' : data.pumpNutrient ? 'NUTRIENT ONLY' : 'BOTH OFF'}",
                          isOn: data.pumpWater || data.pumpNutrient,
                          icon: Icons.settings,
                          color: Colors.purple,
                          onPressed: () {
                            mqttProvider.sendPumpCommands(
                              pumpWater: !data.pumpWater,
                              pumpNutrient: !data.pumpNutrient,
                            );
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
                      label: "Soil Humidity History",
                      data: soilHumHistory,
                      color: Colors.blue,
                    ),
                    SensorChart(
                      label: "pH History",
                      data: phHistory,
                      color: Colors.green,
                    ),
                    SensorChart(
                      label: "TDS History",
                      data: tdsHistory,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
