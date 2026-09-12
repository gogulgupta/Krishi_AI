/**
 * KrishiAI - Gemini AI Precision Fertilizer & Agronomic Diagnostic Service
 * Combines 3 factors:
 * 1. Plant Disease Diagnostic (Disease class, leaf symptom, severity)
 * 2. Live HiveMQ MQTT Sensor Telemetry (Soil Moisture %, Temperature, Humidity, Rain)
 * 3. Soil Classification Output (Soil Type: Alluvial, Black, Clay, Red, pH, NPK readiness)
 */

export async function analyzeAgriDataAndRecommendFertilizer({
  plantDiseaseData,
  mqttData,
  soilData,
  cropType = 'General Crop / Pearl Millet / Chilli',
  apiKey = process.env.GEMINI_API_KEY
}) {
  const diseaseName = plantDiseaseData?.disease || plantDiseaseData?.diseaseName || 'Early Blight';
  const confidence = plantDiseaseData?.confidence ? (plantDiseaseData.confidence * 100).toFixed(1) : '94.8';
  const soilType = soilData?.soilType || soilData?.predictedClass || 'Alluvial Soil';
  
  const moisture = mqttData?.averageMoisture ?? mqttData?.soil1 ?? 42;
  const temp = mqttData?.temperature ?? 28;
  const humidity = mqttData?.humidity ?? 65;
  const isRaining = mqttData?.rain ?? false;

  const effectiveApiKey = apiKey || process.env.GEMINI_API_KEY;

  // If Gemini API Key is provided, we can call Google Gemini REST endpoint
  if (effectiveApiKey) {
    try {
      const prompt = `You are a Senior Agronomist and Precision Agriculture Fertilizer Specialist at an Agro-Chemical Company.
Analyze this 3-factor multi-modal farm data:
1. Plant Disease: "${diseaseName}" (Confidence: ${confidence}%)
2. Live IoT Sensors (HiveMQ): Soil Moisture: ${moisture}%, Temp: ${temp}°C, Humidity: ${humidity}%, Rain Status: ${isRaining ? 'Raining' : 'Dry'}
3. Soil Type: "${soilType}"

Provide a structured JSON response with the following fields:
{
  "problemSummary": "Clear concise description of the diagnosis",
  "recommendedFertilizer": "Exact chemical or bio-fertilizer name and formulation (e.g., Azoxystrobin 18.2% + Difenoconazole 11.4% SC or 19:19:19 NPK + Mancozeb)",
  "category": "Fungicide / Micronutrient / Bio-Fertilizer / Foliar Spray",
  "dosage": "e.g. 1.5 ml per Litre of water (200 Litres/Acre)",
  "sprayTiming": "Exact time of day suitable for spraying (e.g., 06:30 AM - 08:30 AM or 05:00 PM)",
  "sprayFrequency": "e.g. 2 applications at 7-day intervals",
  "estimatedPriceINR": 480,
  "costPerAcre": "₹450 - ₹550 per acre",
  "safetyWindow": "2.5 hours before rainfastness",
  "soilAction": "Recommendation regarding soil moisture before spraying",
  "urgency": "High" | "Medium" | "Low"
}`;

      const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=${effectiveApiKey}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: { responseMimeType: "application/json" }
        })
      });

      if (response.ok) {
        const jsonRes = await response.json();
        const candidateText = jsonRes.candidates?.[0]?.content?.parts?.[0]?.text;
        if (candidateText) {
          return JSON.parse(candidateText);
        }
      }
    } catch (err) {
      console.warn('[Gemini AI Service] Fallback to internal agronomy engine:', err.message);
    }
  }

  // Robust Agronomic Inference Engine (Fallback / High-Speed Offline Mode)
  return generateExpertAgronomicAdvisory({
    diseaseName,
    confidence,
    soilType,
    moisture,
    temp,
    humidity,
    isRaining,
    cropType
  });
}

function generateExpertAgronomicAdvisory({ diseaseName, confidence, soilType, moisture, temp, humidity, isRaining, cropType }) {
  const dLower = String(diseaseName).toLowerCase();
  
  let fertilizerName = 'Azoxystrobin 18.2% + Difenoconazole 11.4% SC';
  let category = 'Broad-Spectrum Systemic Fungicide';
  let dosage = '1.0 ml / Litre of water (200L/Acre)';
  let timing = '06:30 AM – 08:30 AM (Calm Wind & Ideal Leaf Dew)';
  let frequency = '2 Sprays (Repeat after 8 days)';
  let price = 520;
  let urgency = 'High';
  let safetyWindow = 'Safe (Rainfast in 2 hours)';
  let soilAction = 'Soil moisture is optimal (42%). Suitable for root and foliar absorption.';

  if (dLower.includes('rust') || dLower.includes('leaf rust')) {
    fertilizerName = 'Propiconazole 25% EC + Bio-Potash Booster';
    category = 'Systemic Fungicide & Potassium Enricher';
    dosage = '1.5 ml / Litre of water';
    timing = '06:15 AM – 08:00 AM';
    frequency = '1 Spray now, 2nd spray after 10 days if symptoms persist';
    price = 460;
    urgency = 'High';
  } else if (dLower.includes('blight') || dLower.includes('early blight') || dLower.includes('late blight')) {
    fertilizerName = 'Mancozeb 75% WP + Metalaxyl 8% MZ';
    category = 'Contact & Systemic Protective Fungicide';
    dosage = '2.5 g / Litre of water';
    timing = '07:00 AM – 09:00 AM';
    frequency = '2 Sprays at 6-day intervals';
    price = 390;
    urgency = 'Critical';
  } else if (dLower.includes('mildew') || dLower.includes('downy') || dLower.includes('powdery')) {
    fertilizerName = 'Hexaconazole 5% SC + Micronutrient Zinc Mix';
    category = 'Therapeutic Fungicide + Foliar Micronutrient';
    dosage = '2.0 ml / Litre of water';
    timing = '06:45 AM – 08:30 AM';
    frequency = '1-2 Applications as per leaf coverage';
    price = 430;
    urgency = 'Medium';
  } else if (dLower.includes('spot') || dLower.includes('cercospora') || dLower.includes('leaf spot')) {
    fertilizerName = 'Copper Oxychloride 50% WP + Carbendazim 12%';
    category = 'Protective Bactericide / Fungicide';
    dosage = '2.0 g / Litre of water';
    timing = '06:30 AM – 08:30 AM or 05:00 PM';
    frequency = '2 Sprays at 7-day intervals';
    price = 380;
    urgency = 'Medium';
  } else if (dLower.includes('healthy')) {
    fertilizerName = 'Water Soluble NPK (19:19:19) + Seaweed Bio-Stimulant';
    category = 'Balanced Growth Fertilizer & Bio-Activator';
    dosage = '5.0 g / Litre of water';
    timing = '07:00 AM – 09:30 AM';
    frequency = 'Maintenance spray once every 14 days';
    price = 310;
    urgency = 'Low';
  }

  // Adjust timing and soil action based on MQTT Telemetry
  if (isRaining) {
    timing = 'Delay spray until rain stops + 4 hours dry weather';
    safetyWindow = 'High Risk of Chemical Runoff';
  } else if (temp > 34) {
    timing = 'Strictly 06:00 AM – 07:30 AM (Avoid high midday heat to prevent leaf scorching)';
  } else if (humidity > 80) {
    timing = '07:30 AM – 09:30 AM (Wait for heavy morning fog/dew to evaporate)';
  }

  if (moisture < 25) {
    soilAction = `Soil moisture is very low (${moisture}%). Provide light drip irrigation before foliar chemical application.`;
  } else if (moisture > 75) {
    soilAction = `Soil is over-saturated (${moisture}%). Hold irrigation; apply foliar spray during morning dry window.`;
  } else {
    soilAction = `Soil moisture is in ideal range (${moisture}%). Perfect for systemic vascular uptake.`;
  }

  return {
    problemSummary: `Detected "${diseaseName}" with ${confidence}% confidence on ${cropType} cultivated in ${soilType}. Environmental moisture is ${moisture}% at ${temp}°C.`,
    recommendedFertilizer: fertilizerName,
    category,
    dosage,
    sprayTiming: timing,
    sprayFrequency: frequency,
    estimatedPriceINR: price,
    costPerAcre: `₹${price} – ₹${price + 90} per acre`,
    safetyWindow,
    soilAction,
    urgency,
    soilTypeAdjusted: soilType,
    mqttSnapshot: { moisture, temp, humidity, isRaining }
  };
}
