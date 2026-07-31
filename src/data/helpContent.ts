/**
 * Central Help Content Configuration
 *
 * All contextual help text for the AgroDex application is stored here.
 * Components consume this config via the `HELP` dictionary.
 * Never hardcode help text inside components — always reference this file.
 */

import type { HelpDictionary } from "@/types/help";

export const HELP: HelpDictionary = {
  // ─── Authentication ──────────────────────────────────────────────────────────
  "auth.email": {
    id: "auth.email",
    title: "Email Address",
    description:
      "Enter the email address you want to associate with your AgroDex account. You will use this email to log in.",
    example: "farmer@example.com",
    tips: [
      { text: "Use an active email — you may need to confirm it.", type: "info" },
      { text: "Avoid shared or temporary email addresses.", type: "warning" },
    ],
  },
  "auth.password": {
    id: "auth.password",
    title: "Password Rules",
    description: "Your password protects your AgroDex account and all crop batch records linked to it.",
    tips: [
      { text: "Minimum 8 characters required.", type: "info" },
      { text: "Use a mix of letters, numbers, and symbols for a stronger password.", type: "tip" },
      { text: "Do not reuse passwords from other websites.", type: "warning" },
    ],
  },
  "auth.walletLogin": {
    id: "auth.walletLogin",
    title: "Wallet Login",
    description:
      "Log in using your HashPack or MetaMask wallet instead of a username and password. Your wallet acts as your identity on the Hedera network.",
    tips: [
      { text: "HashPack is the recommended wallet for Hedera-native features.", type: "tip" },
      { text: "Make sure your wallet is connected to Hedera Testnet for development.", type: "warning" },
    ],
  },

  // ─── Batch Registration ──────────────────────────────────────────────────────
  "registration.productName": {
    id: "registration.productName",
    title: "Product Name",
    description:
      "Enter the official name of your harvested crop. This name is embedded permanently in the Hedera Consensus Service (HCS) record and helps buyers find and verify your listing.",
    example: ["Rice", "Organic Arabica Coffee", "Maize", "Robusta Coffee Beans"],
    tips: [
      { text: "Use commonly known market names.", type: "tip" },
      { text: "Avoid abbreviations — write the full crop name.", type: "tip" },
      { text: 'Do not enter generic names like "Crop" or "Product".', type: "warning" },
    ],
  },
  "registration.harvestBatch": {
    id: "registration.harvestBatch",
    title: "Harvest Batch Identifier",
    description:
      "A unique identifier for this specific harvest batch. Used to distinguish between multiple batches of the same crop. This is also logged on the Hedera ledger.",
    example: ["Batch #150", "HB-2026-150", "COFFEE-JUL-001"],
    tips: [
      { text: "Use a consistent numbering system across all your batches.", type: "tip" },
      { text: "Include the year or month in the identifier for easy sorting.", type: "tip" },
    ],
  },
  "registration.quantity": {
    id: "registration.quantity",
    title: "Quantity",
    description:
      "The total harvested quantity for this batch. Gemini AI compares this value against your historical data to detect yield anomalies as part of the fraud detection engine.",
    example: "1000",
    tips: [
      { text: "Enter only numeric values (no commas or units here).", type: "tip" },
      { text: "Unusual quantities may trigger a risk flag in the AI audit.", type: "warning" },
    ],
  },
  "registration.unit": {
    id: "registration.unit",
    title: "Unit of Measurement",
    description: "The measurement unit for the quantity field above.",
    example: ["kg", "bags", "tons", "quintals"],
    tips: [
      { text: "Use a consistent unit across all your batches for accurate AI analysis.", type: "tip" },
    ],
  },
  "registration.origin": {
    id: "registration.origin",
    title: "Origin Location",
    description:
      "The specific geographic location where this crop was grown and harvested. Used for regional analytics and fraud detection (regional outlier signal).",
    example: ["Gayo Highlands, Aceh, Indonesia", "Toraja Region, Sulawesi", "Kigali Region, Rwanda"],
    tips: [
      { text: "Be as specific as possible — include district or region.", type: "tip" },
      { text: "Consistent location data improves AI risk assessment accuracy.", type: "info" },
    ],
  },
  "registration.harvestDate": {
    id: "registration.harvestDate",
    title: "Harvest Date",
    description:
      "The date when this crop batch was harvested. Recorded immutably on the Hedera ledger. The AI uses this to detect suspicious batch creation frequency.",
    tips: [
      { text: "Use the actual harvest date, not the submission date.", type: "tip" },
      {
        text: "Creating more than 3 batches with the same date may trigger a fraud flag.",
        type: "warning",
      },
    ],
  },
  "registration.metadata": {
    id: "registration.metadata",
    title: "Additional Product Metadata",
    description:
      "Optional but highly recommended. Any extra information about the crop that adds credibility to your listing: certifications, moisture content, processing method, etc.",
    example: "Certified Fair Trade, Moisture content 12%, Shade-grown, GAP Certified",
    tips: [
      { text: "Include certifications — they boost the AI trust score.", type: "tip" },
      { text: "Add processing details like 'wet-hulled' or 'natural processed'.", type: "tip" },
    ],
  },

  // ─── Dashboard ──────────────────────────────────────────────────────────────
  "dashboard.totalBatches": {
    id: "dashboard.totalBatches",
    title: "Total Batches",
    description:
      "The total number of crop batches you have registered on the Hedera Consensus Service (HCS). Each batch represents a unique, immutable proof of a harvest event.",
    tips: [
      { text: "Each batch registration creates a permanent on-chain record.", type: "info" },
    ],
  },
  "dashboard.totalNfts": {
    id: "dashboard.totalNfts",
    title: "NFTs Minted",
    description:
      "The number of crop batches that have been tokenized as NFTs using Hedera Token Service (HTS). An NFT serves as the final tamper-proof certificate of authenticity for buyers.",
    tips: [
      { text: "Tokenize a batch to give buyers a verifiable digital certificate.", type: "tip" },
      { text: "NFT metadata is permanently linked to the HCS audit trail.", type: "info" },
    ],
  },
  "dashboard.totalVerifications": {
    id: "dashboard.totalVerifications",
    title: "Total Verifications",
    description:
      "The number of times buyers or third parties have scanned a QR code or visited the verify page to authenticate your crop batches.",
  },
  "dashboard.aiVerified": {
    id: "dashboard.aiVerified",
    title: "AI Verified",
    description:
      "The count of batches that have been audited by Gemini AI. The AI analyzes the HCS timeline to produce a 0–100 trust score and a human-readable provenance summary.",
    tips: [
      {
        text: "Higher AI trust scores increase buyer confidence in your listings.",
        type: "tip",
      },
    ],
  },
  "dashboard.auditLog": {
    id: "dashboard.auditLog",
    title: "Audit Log",
    description:
      "A real-time stream of all HCS messages submitted for your batches. Each entry is an immutable record fetched directly from the Hedera Mirror Node — it cannot be altered or deleted.",
    tips: [
      { text: "This data is pulled live from the Hedera Mirror Node.", type: "info" },
    ],
  },

  // ─── Risk Intelligence ───────────────────────────────────────────────────────
  "risk.riskScore": {
    id: "risk.riskScore",
    title: "Risk Score",
    description:
      "A calculated fraud risk score between 0 and 100 based on 7 independent signal detectors. A higher score indicates more suspicious behavior. Gemini AI provides a human-readable explanation for detected signals — but never influences the score itself.",
    tips: [
      { text: "SAFE: 0–19 · LOW: 20–34 · MEDIUM: 35–54 · HIGH: 55–74 · CRITICAL: 75–100", type: "info" },
      { text: "Scores are cached for 1 hour and re-calculated when stale.", type: "info" },
      {
        text: "The scoring is fully deterministic — the same inputs always yield the same score.",
        type: "tip",
      },
    ],
  },
  "risk.yieldAnomaly": {
    id: "risk.yieldAnomaly",
    title: "Yield Anomaly Signal",
    description:
      "Fires when the quantity of a new batch deviates more than 2 standard deviations (±2σ) from the farmer's historical average. This pattern is a common indicator of falsified quantity data.",
    tips: [
      { text: "Weight: +20 points toward total risk score.", type: "info" },
      { text: "Maintaining consistent batch quantities reduces this signal.", type: "tip" },
    ],
  },
  "risk.nftMinting": {
    id: "risk.nftMinting",
    title: "Multiple NFT Minting Attempts",
    description:
      "Fires when more than one NFT token is found for the same HCS transaction ID. Minting multiple NFTs for a single batch is a strong indicator of fraud.",
    tips: [{ text: "Weight: +30 points — the highest-weight signal.", type: "warning" }],
  },

  // ─── Batch Verification ──────────────────────────────────────────────────────
  "verify.trustScore": {
    id: "verify.trustScore",
    title: "Trust Score",
    description:
      "A 0–100 score generated by Gemini AI after parsing the complete HCS event timeline for this batch. It reflects the overall authenticity and completeness of the crop's documented journey.",
    tips: [
      { text: "Scores above 80 indicate a high-confidence authentic batch.", type: "tip" },
      { text: "Scores below 40 suggest missing or suspicious lifecycle events.", type: "warning" },
    ],
  },
  "verify.hcsTimeline": {
    id: "verify.hcsTimeline",
    title: "HCS Event Timeline",
    description:
      "The full chronological history of events for this batch fetched directly from the Hedera Mirror Node. Each event was submitted via the Hedera Consensus Service and is immutable.",
    tips: [
      { text: "These records cannot be altered or deleted by anyone — including AgroDex.", type: "info" },
    ],
  },
  "verify.qrCode": {
    id: "verify.qrCode",
    title: "QR Code Verification",
    description:
      "Scan this QR code using any mobile device to instantly access this batch's full verification page. The QR payload contains the batch ID and the verification URL.",
    tips: [
      { text: "Share this QR with buyers to allow instant on-the-spot verification.", type: "tip" },
    ],
  },

  // ─── Batch Tokenization ──────────────────────────────────────────────────────
  "tokenize.tokenId": {
    id: "tokenize.tokenId",
    title: "Token ID (HTS)",
    description:
      "The unique identifier assigned by Hedera Token Service (HTS) when your batch is minted as an NFT. This ID can be used to look up the token on any Hedera Mirror Node explorer.",
    tips: [
      { text: "The Token ID is permanent and cannot be changed after minting.", type: "info" },
    ],
  },
  "tokenize.serialNumber": {
    id: "tokenize.serialNumber",
    title: "Serial Number",
    description:
      "The unique serial number of the NFT within its token class. Combined with the Token ID, it uniquely identifies this specific crop certificate on the Hedera network.",
  },

  // ─── Profile / Settings ──────────────────────────────────────────────────────
  "profile.farmName": {
    id: "profile.farmName",
    title: "Farm Name",
    description:
      "The official name of your farm or agricultural operation. This name appears on all batch records and buyer-facing verification pages.",
    example: "Gayo Highland Organic Farm",
    tips: [
      { text: "Use your registered business name if applicable.", type: "tip" },
    ],
  },
  "profile.hederaAccountId": {
    id: "profile.hederaAccountId",
    title: "Hedera Account ID",
    description:
      "Your Hedera network account identifier (e.g., 0.0.7127337). This is used to associate your on-chain transactions with your AgroDex profile.",
    tips: [
      { text: "This is read-only and linked to your connected wallet.", type: "info" },
    ],
  },
};
