import { sha256, calculateMerkleRoot, createAgriTelemetryProof, verifyBlockIntegrity } from '../utils/hash.js';

export const MST_TESTNET_CONFIG = {
  networkName: process.env.MST_NETWORK_NAME || 'MST Testnet',
  chainId: process.env.MST_CHAIN_ID || '91562037',
  currency: process.env.MST_CURRENCY || 'tMSTC',
  rpcUrl: process.env.MST_RPC_URL || 'https://testnetrpc.mstblockchain.com',
  explorerUrl: process.env.MST_EXPLORER_URL || 'https://testnet.mstscan.com',
  walletAddress: process.env.MST_WALLET_ADDRESS || '0x7Fac28CfC8c26eA704D615B3A64Dc6Ab456aF8aF'
};

class MerkleStateTreeBlockchain {
  constructor() {
    this.chain = [];
    this.pendingRequests = [];
    this.initGenesisBlock();
  }

  initGenesisBlock() {
    const genesisData = {
      index: 0,
      timestamp: 1726000000000,
      blockType: 'GENESIS_BLOCK',
      sender: 'KrishiAI_Root_Consortium',
      receiver: 'Public_Agri_Network',
      data: {
        network: 'MST Testnet (Chain ID: 91562037)',
        standard: 'ERC-Agri-Proof',
        explorer: 'https://testnet.mstscan.com',
        rpc: 'https://testnetrpc.mstblockchain.com',
        nativeToken: 'tMSTC'
      },
      leaves: {
        plantLeafHash: sha256('GENESIS_PLANT_SEED'),
        mqttLeafHash: sha256('GENESIS_MQTT_SEED'),
        soilLeafHash: sha256('GENESIS_SOIL_SEED')
      },
      merkleRoot: calculateMerkleRoot([
        sha256('GENESIS_PLANT_SEED'),
        sha256('GENESIS_MQTT_SEED'),
        sha256('GENESIS_SOIL_SEED')
      ]),
      previousHash: '0x0000000000000000000000000000000000000000000000000000000000000000',
      status: 'FINALIZED',
      hash: ''
    };
    genesisData.hash = sha256(genesisData);
    this.chain.push(genesisData);
  }

  getLatestBlock() {
    return this.chain[this.chain.length - 1];
  }

  /**
   * Farmer creates and submits a 3-Factor Telemetry Bundle block request
   */
  submitFarmerTelemetryBlock({
    farmerId = 'Kisan_007',
    farmerName = 'Rameshwar Sharma',
    location = 'Ghaziabad, UP',
    crop = 'Pearl Millet (Bajra)',
    plantDiseaseData,
    mqttData,
    soilData
  }) {
    const prevBlock = this.getLatestBlock();
    const proof = createAgriTelemetryProof({
      plantDiseaseData,
      mqttData,
      soilData,
      farmerId,
      location
    });

    const newBlockIndex = this.chain.length;
    const block = {
      index: newBlockIndex,
      blockId: `MST-TX-${1000 + newBlockIndex}`,
      timestamp: Date.now(),
      blockType: 'FARMER_TELEMETRY_REQUEST',
      sender: farmerName,
      farmerId,
      location,
      crop,
      data: {
        plantDiseaseData: plantDiseaseData || { disease: 'Leaf Blight', confidence: 0.94 },
        mqttData: mqttData || { moisture: 42, temperature: 28.5, humidity: 62 },
        soilData: soilData || { soilType: 'Alluvial Soil', confidence: 0.92 }
      },
      leaves: proof.leaves,
      merkleRoot: proof.merkleRoot,
      previousHash: prevBlock.hash,
      status: 'PENDING_COMPANY_ANALYSIS',
      companyPrescription: null,
      hash: ''
    };

    block.hash = sha256(block);
    this.chain.push(block);
    this.pendingRequests.push(block);

    return block;
  }

  /**
   * Fertilizer Company commits verified Gemini AI prescription block
   */
  commitFertilizerSolutionBlock({
    blockIndex,
    companyId = 'IFFCO_AgroChemicals_Ltd',
    companyName = 'IFFCO Precision Bio-Fertilizers',
    prescription,
    officerNotes = 'Gemini AI Multi-Modal Diagnosis Verified by Agronomist'
  }) {
    let targetBlock = this.chain.find(b => b.index === Number(blockIndex) || b.blockId === blockIndex);
    if (!targetBlock) {
      targetBlock = {
        blockId: String(blockIndex || 'MST-TX-7829'),
        farmerId: 'KISAN-7829',
        sender: 'Rameshwar Sharma (KISAN-7829)',
        location: 'Ghaziabad, UP'
      };
    }

    const prevBlock = this.getLatestBlock();
    const solutionBlockIndex = this.chain.length;

    const solutionBlock = {
      index: solutionBlockIndex,
      blockId: `MST-SOL-${2000 + solutionBlockIndex}`,
      referenceRequestBlockId: targetBlock.blockId,
      timestamp: Date.now(),
      blockType: 'FERTILIZER_PRESCRIPTION_SETTLED',
      sender: companyName,
      companyId,
      receiverFarmerId: targetBlock.farmerId,
      receiverFarmerName: targetBlock.sender,
      location: targetBlock.location,
      prescription: {
        problemSummary: prescription.problemSummary,
        recommendedFertilizer: prescription.recommendedFertilizer,
        category: prescription.category,
        dosage: prescription.dosage,
        sprayTiming: prescription.sprayTiming,
        sprayFrequency: prescription.sprayFrequency,
        estimatedPriceINR: prescription.estimatedPriceINR,
        costPerAcre: prescription.costPerAcre,
        safetyWindow: prescription.safetyWindow,
        soilAction: prescription.soilAction,
        officerNotes
      },
      leaves: {
        requestMerkleRoot: targetBlock.merkleRoot,
        companySignatureHash: sha256(`${companyId}_${Date.now()}`),
        prescriptionHash: sha256(prescription)
      },
      merkleRoot: calculateMerkleRoot([
        targetBlock.merkleRoot,
        sha256(`${companyId}_${Date.now()}`),
        sha256(prescription)
      ]),
      previousHash: prevBlock.hash,
      status: 'VERIFIED_AND_MINTED',
      hash: ''
    };

    solutionBlock.hash = sha256(solutionBlock);
    this.chain.push(solutionBlock);

    // Update target request status
    targetBlock.status = 'SOLVED_AND_PRESCRIBED';
    targetBlock.companyPrescription = solutionBlock;
    targetBlock.solutionBlockHash = solutionBlock.hash;

    // Remove from pending
    this.pendingRequests = this.pendingRequests.filter(b => b.blockId !== targetBlock.blockId);

    return {
      targetBlock,
      solutionBlock
    };
  }

  /**
   * Get all chain blocks
   */
  getChain() {
    return this.chain;
  }

  /**
   * Get pending farmer blocks awaiting fertilizer company response
   */
  getPendingRequests() {
    return this.chain.filter(b => b.blockType === 'FARMER_TELEMETRY_REQUEST' && b.status === 'PENDING_COMPANY_ANALYSIS');
  }

  /**
   * Validates whole blockchain integrity
   */
  isChainValid() {
    for (let i = 1; i < this.chain.length; i++) {
      const current = this.chain[i];
      const previous = this.chain[i - 1];

      if (current.previousHash !== previous.hash) {
        return { valid: false, reason: `Previous hash mismatch at Block #${current.index}` };
      }

      // Recompute block hash
      const copy = { ...current, hash: '' };
      const computedHash = sha256(copy);
      if (current.hash !== computedHash) {
        return { valid: false, reason: `Data tampering detected at Block #${current.index}` };
      }
    }
    return { valid: true, chainLength: this.chain.length };
  }
}

export const blockchainInstance = new MerkleStateTreeBlockchain();
