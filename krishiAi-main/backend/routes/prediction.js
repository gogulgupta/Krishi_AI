import express from 'express';
import { analyzeAgriDataAndRecommendFertilizer } from '../services/aiService.js';
import { getLatestTelemetry } from '../services/mqttService.js';

const router = express.Router();

/**
 * POST /api/predict/fertilizer
 * Runs multi-modal Gemini AI analysis on 3-Factor Telemetry Bundle
 */
router.post('/fertilizer', async (req, res) => {
  try {
    const { plantDiseaseData, mqttData, soilData, cropType, apiKey } = req.body;

    // If mqttData not provided by client, use latest cached telemetry from backend HiveMQ broker
    const telemetry = mqttData || getLatestTelemetry();

    const analysisResult = await analyzeAgriDataAndRecommendFertilizer({
      plantDiseaseData,
      mqttData: telemetry,
      soilData,
      cropType,
      apiKey
    });

    return res.json({
      success: true,
      data: analysisResult,
      telemetryUsed: telemetry
    });
  } catch (error) {
    console.error('[Prediction Route Error]:', error);
    return res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * GET /api/predict/latest-telemetry
 * Fetches latest live HiveMQ sensor reading
 */
router.get('/latest-telemetry', (req, res) => {
  const telemetry = getLatestTelemetry();
  return res.json({
    success: true,
    data: telemetry
  });
});

export default router;
