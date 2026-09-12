import mqtt from 'mqtt';

export const MQTT_BROKER_CONFIG = {
  host: process.env.MQTT_HOST || 'fc1c2174ffcb47ca88aa28238dab2eac.s1.eu.hivemq.cloud',
  port: parseInt(process.env.MQTT_PORT || '8883', 10), // TLS Port
  protocol: 'mqtts',
  username: process.env.MQTT_USERNAME || 'gogulgupta',
  password: process.env.MQTT_PASSWORD || 'Gogul12345678',
  dataTopic: process.env.MQTT_DATA_TOPIC || 'gogul/agriculture/data',
  statusTopic: process.env.MQTT_STATUS_TOPIC || 'gogul/agriculture/status',
  controlTopic: process.env.MQTT_CONTROL_TOPIC || 'gogul/agriculture/control'
};

let mqttClient = null;
let latestTelemetry = {
  soil1: 42,
  soil2: 45,
  soil3: 38,
  soil4: 48,
  averageMoisture: 43.25,
  temperature: 28.5,
  humidity: 62.0,
  pressure: 1012,
  rain: false,
  counter: 0,
  timestamp: Date.now(),
  source: 'simulated_fallback'
};
let isConnected = false;

export function initMqttService() {
  try {
    const connectUrl = `${MQTT_BROKER_CONFIG.protocol}://${MQTT_BROKER_CONFIG.host}:${MQTT_BROKER_CONFIG.port}`;
    console.log(`[HiveMQ Backend] Connecting to ${connectUrl}...`);

    mqttClient = mqtt.connect(connectUrl, {
      username: MQTT_BROKER_CONFIG.username,
      password: MQTT_BROKER_CONFIG.password,
      rejectUnauthorized: false,
      reconnectPeriod: 5000,
      connectTimeout: 30 * 1000,
    });

    mqttClient.on('connect', () => {
      isConnected = true;
      console.log(`[HiveMQ Backend] Connected successfully! Subscribing to ${MQTT_BROKER_CONFIG.dataTopic}`);
      mqttClient.subscribe(MQTT_BROKER_CONFIG.dataTopic, (err) => {
        if (err) {
          console.error(`[HiveMQ Backend] Subscription error:`, err);
        } else {
          console.log(`[HiveMQ Backend] Subscribed to ${MQTT_BROKER_CONFIG.dataTopic}`);
        }
      });
    });

    mqttClient.on('message', (topic, message) => {
      try {
        const payloadStr = message.toString();
        const data = JSON.parse(payloadStr);

        // Normalize telemetry
        const s1 = Number(data.soil1 ?? data.moisture1 ?? 40);
        const s2 = Number(data.soil2 ?? data.moisture2 ?? 40);
        const s3 = Number(data.soil3 ?? data.moisture3 ?? 40);
        const s4 = Number(data.soil4 ?? data.moisture4 ?? 40);
        const avgM = parseFloat(((s1 + s2 + s3 + s4) / 4).toFixed(2));

        latestTelemetry = {
          soil1: s1,
          soil2: s2,
          soil3: s3,
          soil4: s4,
          averageMoisture: avgM,
          temperature: Number(data.temperature ?? data.temp ?? 27.5),
          humidity: Number(data.humidity ?? data.hum ?? 65),
          pressure: Number(data.pressure ?? 1013),
          rain: Boolean(data.rain === true || data.rain === 1 || data.rain === '1'),
          counter: Number(data.counter ?? latestTelemetry.counter + 1),
          timestamp: Date.now(),
          source: 'live_hivemq_stream',
          raw: data
        };

        // console.log(`[HiveMQ Backend] Updated Telemetry Packet #${latestTelemetry.counter}: Avg Moisture ${avgM}%`);
      } catch (err) {
        console.warn(`[HiveMQ Backend] Parse error on ${topic}:`, err.message);
      }
    });

    mqttClient.on('error', (err) => {
      isConnected = false;
      console.error(`[HiveMQ Backend] Client error:`, err.message);
    });

    mqttClient.on('close', () => {
      isConnected = false;
      // console.log(`[HiveMQ Backend] Connection closed`);
    });

  } catch (error) {
    console.error(`[HiveMQ Backend] Initialization exception:`, error);
  }
}

/**
 * Returns latest cached telemetry data from HiveMQ
 */
export function getLatestTelemetry() {
  return latestTelemetry;
}

/**
 * Publishes relay or control command to ESP32
 */
export function sendControlCommand(cmd) {
  if (mqttClient && isConnected) {
    const msg = typeof cmd === 'object' ? JSON.stringify(cmd) : String(cmd);
    mqttClient.publish(MQTT_BROKER_CONFIG.controlTopic, msg);
    return true;
  }
  return false;
}
