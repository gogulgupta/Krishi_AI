import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import predictionRoutes from './routes/prediction.js';
import blockchainRoutes from './routes/blockchain.js';
import { initMqttService } from './services/mqttService.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5003;

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Initialize HiveMQ MQTT Background Subscriber
initMqttService();

// Routes
app.use('/api/prediction', predictionRoutes);
app.use('/api/blockchain', blockchainRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'KrishiAI MST Blockchain & Agronomic Engine',
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(`🌾 KrishiAI Blockchain & Agro-Company Backend Running!`);
  console.log(`📡 URL: http://localhost:${PORT}`);
  console.log(`🔗 Blockchain API: http://localhost:${PORT}/api/blockchain/chain`);
  console.log(`🤖 AI Prediction API: http://localhost:${PORT}/api/prediction/fertilizer`);
  console.log(`====================================================`);
});
