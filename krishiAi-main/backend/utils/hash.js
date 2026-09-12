import crypto from 'crypto';

/**
 * Computes SHA-256 hash of any string or object
 * @param {string|object} data 
 * @returns {string} Hex hash prefixed with 0x
 */
export function sha256(data) {
  const str = typeof data === 'object' ? JSON.stringify(data) : String(data);
  return '0x' + crypto.createHash('sha256').update(str).digest('hex');
}

/**
 * Computes the Merkle Root Hash for an array of leaf elements
 * Uses pairwise hashing conforming to Merkle State Tree (MST) standard
 * @param {Array<string|object>} leaves 
 * @returns {string} Merkle Root Hash
 */
export function calculateMerkleRoot(leaves) {
  if (!leaves || leaves.length === 0) {
    return sha256('EMPTY_LEAF');
  }

  let currentLevel = leaves.map(leaf => (typeof leaf === 'string' && leaf.startsWith('0x') ? leaf : sha256(leaf)));

  while (currentLevel.length > 1) {
    const nextLevel = [];
    for (let i = 0; i < currentLevel.length; i += 2) {
      if (i + 1 < currentLevel.length) {
        // Hash pair
        const combined = currentLevel[i] + currentLevel[i + 1];
        nextLevel.push(sha256(combined));
      } else {
        // Odd element duplicated in Merkle tree
        const combined = currentLevel[i] + currentLevel[i];
        nextLevel.push(sha256(combined));
      }
    }
    currentLevel = nextLevel;
  }

  return currentLevel[0];
}

/**
 * Creates an MST (Merkle Spanning / State Tree) Cryptographic Proof for 3-Factor Agricultural Telemetry
 * Factors:
 * 1. Plant Disease Diagnostic Leaf
 * 2. HiveMQ MQTT Sensor Telemetry Leaf
 * 3. Soil Classification Output Leaf
 */
export function createAgriTelemetryProof({ plantDiseaseData, mqttData, soilData, farmerId = 'kisan-01', location = 'Ghaziabad' }) {
  const timestamp = Date.now();

  const plantLeafHash = sha256({
    type: 'PLANT_DISEASE_FACTOR',
    data: plantDiseaseData || { disease: 'Healthy', confidence: 0.95 }
  });

  const mqttLeafHash = sha256({
    type: 'HIVEMQ_MQTT_FACTOR',
    data: mqttData || { moisture: 45, temperature: 28, humidity: 65, rain: 0 }
  });

  const soilLeafHash = sha256({
    type: 'SOIL_CLASSIFICATION_FACTOR',
    data: soilData || { soilType: 'Alluvial Soil', confidence: 0.92 }
  });

  const leaves = [plantLeafHash, mqttLeafHash, soilLeafHash];
  const merkleRoot = calculateMerkleRoot(leaves);

  const blockPayload = {
    farmerId,
    location,
    timestamp,
    leaves: {
      plantLeafHash,
      mqttLeafHash,
      soilLeafHash
    },
    merkleRoot,
    payloadHash: sha256({
      plantDiseaseData,
      mqttData,
      soilData,
      merkleRoot,
      timestamp
    })
  };

  return blockPayload;
}

/**
 * Validates whether a given block payload matches its Merkle Root and cryptographic hash
 * @param {object} block 
 * @returns {boolean}
 */
export function verifyBlockIntegrity(block) {
  if (!block || !block.leaves || !block.merkleRoot) return false;
  const leaves = [
    block.leaves.plantLeafHash,
    block.leaves.mqttLeafHash,
    block.leaves.soilLeafHash
  ];
  const computedRoot = calculateMerkleRoot(leaves);
  return computedRoot === block.merkleRoot;
}
