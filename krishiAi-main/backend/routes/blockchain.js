import express from 'express';
import { blockchainInstance } from '../services/blockchainService.js';
import { getLatestTelemetry } from '../services/mqttService.js';
import { sha256, calculateMerkleRoot } from '../utils/hash.js';

const router = express.Router();

/**
 * GET /api/blockchain/chain
 * Retrieves full ledger blocks
 */
router.get('/chain', (req, res) => {
  const chain = blockchainInstance.getChain();
  const validity = blockchainInstance.isChainValid();
  res.json({
    success: true,
    chainLength: chain.length,
    validity,
    blocks: chain
  });
});

/**
 * GET /api/blockchain/pending
 * Retrieves all pending farmer requests awaiting company solution
 */
router.get('/pending', (req, res) => {
  const pending = blockchainInstance.getPendingRequests();
  res.json({
    success: true,
    count: pending.length,
    requests: pending
  });
});

/**
 * POST /api/blockchain/submit-farmer-request
 * Farmer bundles 3-factor telemetry and mints request block
 */
router.post('/submit-farmer-request', (req, res) => {
  try {
    const {
      farmerId,
      farmerName,
      location,
      crop,
      plantDiseaseData,
      mqttData,
      soilData
    } = req.body;

    // Use passed MQTT or latest live HiveMQ reading
    const telemetry = mqttData || getLatestTelemetry();

    const block = blockchainInstance.submitFarmerTelemetryBlock({
      farmerId: farmerId || 'KISAN-7829',
      farmerName: farmerName || 'Rameshwar Sharma',
      location: location || 'Ghaziabad, UP',
      crop: crop || 'Pearl Millet (Bajra)',
      plantDiseaseData,
      mqttData: telemetry,
      soilData
    });

    res.json({
      success: true,
      message: 'Farmer telemetry bundled and mined to MST Blockchain successfully!',
      block
    });
  } catch (err) {
    console.error('[Blockchain Submit Error]:', err);
    res.status(500).json({ success: false, error: err.message });
  }
});

/**
 * POST /api/blockchain/commit-company-solution
 * Fertilizer company analyzes via Gemini and mints response block
 */
router.post('/commit-company-solution', (req, res) => {
  try {
    const {
      blockIndex,
      companyId,
      companyName,
      prescription,
      officerNotes
    } = req.body;

    if (!prescription) {
      return res.status(400).json({ success: false, error: 'Prescription payload is required' });
    }

    const result = blockchainInstance.commitFertilizerSolutionBlock({
      blockIndex,
      companyId: companyId || 'IFFCO_AgroChem_01',
      companyName: companyName || 'IFFCO Agri-Bio Chemicals Ltd.',
      prescription,
      officerNotes
    });

    res.json({
      success: true,
      message: 'Fertilizer Prescription verified and committed onto MST Blockchain!',
      result
    });
  } catch (err) {
    console.error('[Blockchain Solution Commit Error]:', err);
    res.status(500).json({ success: false, error: err.message });
  }
});

/**
 * POST /api/blockchain/verify-hash
 * Verifies any hash / Merkle root against the blockchain
 */
router.post('/verify-hash', (req, res) => {
  const { hash, merkleRoot } = req.body;
  const chain = blockchainInstance.getChain();

  const matchingBlock = chain.find(b => 
    b.hash === hash || 
    b.merkleRoot === merkleRoot || 
    b.merkleRoot === hash ||
    b.leaves?.plantLeafHash === hash ||
    b.leaves?.mqttLeafHash === hash ||
    b.leaves?.soilLeafHash === hash
  );

  if (matchingBlock) {
    res.json({
      success: true,
      verified: true,
      blockIndex: matchingBlock.index,
      blockId: matchingBlock.blockId,
      blockType: matchingBlock.blockType,
      timestamp: matchingBlock.timestamp,
      status: matchingBlock.status,
      block: matchingBlock
    });
  } else {
    res.json({
      success: true,
      verified: false,
      message: 'No matching transaction hash or Merkle Root found in MST ledger.'
    });
  }
});

export default router;
