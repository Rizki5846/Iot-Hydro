import 'package:typed_data/typed_buffers.dart';
import 'dart:convert';
import 'dart:io';
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

  Future<void> initializeMQTT() async {
    client = MqttServerClient.withPort(broker, 'flutter_client', port);
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
        .withClientIdentifier('flutter_client')
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
    client.updates!.listen((messages) {
      final recMess = messages[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      try {
        latestData = SensorData.fromJson(jsonDecode(payload));
        notifyListeners();
      } catch (e) {
        print("JSON parse error: $e");
      }
    });
  }

void sendPumpCommand(bool on) {
  final msg = jsonEncode({'pump': on});
  final buffer = Uint8Buffer();       // buat buffer baru
  buffer.addAll(msg.codeUnits);       // tambahkan byte pesan
  client.publishMessage(commandTopic, MqttQos.atMostOnce, buffer);
}

  void onConnected() => print("MQTT connected with TLS");
  void onDisconnected() => print("MQTT disconnected");
  void onSubscribed(String topic) => print("Subscribed to $topic");
}
