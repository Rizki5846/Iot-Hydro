import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:typed_data/typed_buffers.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/sensor_data.dart';

class MqttProvider extends ChangeNotifier {
  final String broker = "7f3eea43ad1a4407aa48fc59f0e33909.s1.eu.hivemq.cloud";
  final int port = 8883;
  final String username = "flutter_user";
  final String password = "Hydro12345!";
  final String topic = "iot/hydroponik";
  final String commandTopic = "iot/hydroponik/command";

  late MqttServerClient client;
  SensorData? latestData;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> initializeMQTT() async {
    client = MqttServerClient.withPort(broker, 'flutter_client_${DateTime.now().millisecondsSinceEpoch}', port);
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.secure = true;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.setProtocolV311();
    client.securityContext = SecurityContext.defaultContext;

    final connMessage = MqttConnectMessage()
        .startClean()
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .authenticateAs(username, password)
        .keepAliveFor(20);
    client.connectionMessage = connMessage;

    try {
      print("Connecting to MQTT broker with TLS...");
      await client.connect();
    } catch (e) {
      print("MQTT connect error: $e");
      client.disconnect();
      return;
    }

    client.subscribe(topic, MqttQos.atMostOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final MqttPublishMessage recMessage = messages[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
      
      print("Received message: $payload"); // Debug log
      
      try {
        final jsonData = jsonDecode(payload);
        latestData = SensorData.fromJson(jsonData);
        notifyListeners();
      } catch (e) {
        print("JSON parse error: $e");
        print("Problematic payload: $payload");
      }
    });
  }

  // Method untuk mengontrol pompa air
  void sendWaterPumpCommand(bool on) {
    final msg = jsonEncode({'pumpWater': on});
    _publishMessage(msg);
    print("Sent water pump command: $on");
  }

  // Method untuk mengontrol pompa nutrisi
  void sendNutrientPumpCommand(bool on) {
    final msg = jsonEncode({'pumpNutrient': on});
    _publishMessage(msg);
    print("Sent nutrient pump command: $on");
  }

  // Method untuk mengontrol kedua pompa sekaligus
  void sendPumpCommands({bool? pumpWater, bool? pumpNutrient}) {
    final Map<String, dynamic> command = {};
    if (pumpWater != null) command['pumpWater'] = pumpWater;
    if (pumpNutrient != null) command['pumpNutrient'] = pumpNutrient;
    
    if (command.isNotEmpty) {
      final msg = jsonEncode(command);
      _publishMessage(msg);
      print("Sent pump commands: $command");
    }
  }

  void _publishMessage(String message) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final buffer = Uint8Buffer();
      buffer.addAll(utf8.encode(message));
      client.publishMessage(commandTopic, MqttQos.atLeastOnce, buffer);
    } else {
      print("MQTT client not connected");
    }
  }

  void onConnected() {
    print("MQTT connected with TLS");
    _isConnected = true;
    notifyListeners();
  }

  void onDisconnected() {
    print("MQTT disconnected");
    _isConnected = false;
    notifyListeners();
  }

  void onSubscribed(String topic) => print("Subscribed to $topic");

  void disconnect() {
    client.disconnect();
    _isConnected = false;
    notifyListeners();
  }
}