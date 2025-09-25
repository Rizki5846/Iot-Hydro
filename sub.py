import paho.mqtt.client as mqtt
import json
from flask import Flask, jsonify
from flask_cors import CORS

# Konfigurasi HiveMQ
MQTT_BROKER = "7f3eea43ad1a4407aa48fc59f0e33909.s1.eu.hivemq.cloud"
MQTT_PORT = 8883
MQTT_USER = "flutter_user"
MQTT_PASS = "Hydro12345!"
MQTT_TOPIC = "iot/hydroponik"

latest_data = {}

# Flask API
app = Flask(__name__)
CORS(app)

@app.route("/data", methods=["GET"])
def get_data():
    return jsonify(latest_data)

# MQTT Callbacks
def on_connect(client, userdata, flags, rc):
    print("Connected to MQTT with result code " + str(rc))
    client.subscribe(MQTT_TOPIC)

def on_message(client, userdata, msg):
    global latest_data
    payload = msg.payload.decode("utf-8")
    try:
        latest_data = json.loads(payload)
        print("Received:", latest_data)
    except Exception as e:
        print("Error parsing JSON:", e)

# Setup MQTT
client = mqtt.Client()
client.username_pw_set(MQTT_USER, MQTT_PASS)
client.tls_set()  # TLS
client.on_connect = on_connect
client.on_message = on_message
client.connect(MQTT_BROKER, MQTT_PORT, 60)

# Jalankan MQTT loop di background
client.loop_start()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
