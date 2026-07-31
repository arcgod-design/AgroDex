import { Client, AccountId, PrivateKey } from '@hashgraph/sdk';
import { env } from './utils/config.js';

let client = null;

/**
 * Robust private key loader that handles multiple formats
 * @param {string} raw - Raw private key string
 * @returns {PrivateKey} Parsed Hedera private key
 */
export function loadPrivateKeyAny(raw) {
  if (!raw) {
    throw new Error('HEDERA_OPERATOR_KEY is required');
  }

  // Remove 0x prefix if present
  const cleanKey = raw.replace(/^0x/, '').trim();

  try {
    // Case 1: DER-encoded key (starts with 302e/3030/3081) - Try first for ECDSA keys
    if (/^(302e|3030|3081)/.test(cleanKey)) {
      console.log('🔑 Detected DER-encoded key...');
      return PrivateKey.fromStringDer(cleanKey);
    }

    // Case 2: 64 hex chars - Try ECDSA first, then ED25519
    if (/^[0-9a-fA-F]{64}$/.test(cleanKey)) {
      console.log('🔑 Detected 64-char hex key, trying ECDSA first...');
      try {
        return PrivateKey.fromStringECDSA(cleanKey);
      } catch (ecdsaError) {
        console.log('🔑 ECDSA failed, trying ED25519...');
        return PrivateKey.fromStringED25519(cleanKey);
      }
    }

    // Case 3: Fallback to generic parser
    console.log('🔑 Using generic key parser...');
    return PrivateKey.fromString(cleanKey);
  } catch (error) {
    throw new Error(
      `Failed to parse HEDERA_OPERATOR_KEY: ${error.message}\n` +
      `Key format: ${cleanKey.length} chars, starts with "${cleanKey.substring(0, 10)}..."\n` +
      `Expected: 64-char hex (ED25519) or DER-encoded hex (starts with 302e/3030/3081)`
    );
  }
}

/**
 * Create and configure a Hedera client for the configured network.
 *
 * Network selection honours `env.HEDERA_NETWORK`:
 *   - `"testnet"` (default, backwards-compatible) → `Client.forTestnet()`
 *   - `"mainnet"` → `Client.forMainnet()`
 *
 * The testnet default preserves all existing callers' behaviour — this PR
 * does not delete the testnet mode, per the issue #209 contract.
 *
 * @param {string} operatorId - Account ID string (e.g., "0.0.12345")
 * @param {string} operatorKey - Private key string (any supported format)
 * @param {("testnet"|"mainnet")} [network] - Override `env.HEDERA_NETWORK`.
 *   Accepts any (?) string for forward-compat with future networks, but
 *   everything other than `"testnet"` / `"mainnet"` throws an explicit
 *   configuration error so an accidental typo doesn't silently route
 *   testnet traffic through mainnet (or vice versa).
 * @returns {Client} Configured Hedera client
 */
export function makeHederaClient(operatorId, operatorKey, network) {
  try {
    const accountId = AccountId.fromString(operatorId);
    const privateKey = loadPrivateKeyAny(operatorKey);

    const selectedNetwork = (network ?? env.HEDERA_NETWORK ?? 'testnet').toLowerCase();
    let client;
    if (selectedNetwork === 'testnet') {
      client = Client.forTestnet();
    } else if (selectedNetwork === 'mainnet') {
      client = Client.forMainnet();
    } else {
      throw new Error(
        `Unknown Hedera network "${selectedNetwork}". ` +
          `Set HEDERA_NETWORK to "testnet" or "mainnet".`,
      );
    }
    client.setOperator(accountId, privateKey);

    console.log(
      `✅ Hedera client initialized for account ${operatorId} on ${selectedNetwork}`,
    );
    return client;
  } catch (error) {
    console.error('❌ Failed to initialize Hedera client:', error.message);
    throw error;
  }
}

/**
 * Returns the network mode the singleton client is (or will be) configured
 * with. Useful for logging / API responses without re-reading `env`.
 *
 * @returns {("testnet"|"mainnet")}
 */
export function getActiveNetwork() {
  const n = (env.HEDERA_NETWORK ?? 'testnet').toLowerCase();
  return n === 'mainnet' ? 'mainnet' : 'testnet';
}

/**
 * Is the singleton client pointed at Hedera mainnet?
 *
 * @returns {boolean}
 */
export function isMainnet() {
  return getActiveNetwork() === 'mainnet';
}

/**
 * Initialize and return Hedera Testnet client (singleton)
 * @returns {Client} Configured Hedera client
 */
export function getHederaClient() {
  if (client) {
    return client;
  }

  try {
    client = makeHederaClient(env.HEDERA_OPERATOR_ID, env.HEDERA_OPERATOR_KEY);
    return client;
  } catch (error) {
    console.error('❌ Failed to initialize Hedera client:', error.message);
    throw new Error(`Hedera client initialization failed: ${error.message}`);
  }
}

/**
 * Close Hedera client connection
 */
export async function closeHederaClient() {
  if (client) {
    await client.close();
    client = null;
    console.log('Hedera client closed');
  }
}
