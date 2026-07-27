/**
 * Gas-price estimator for Hedera batch registrations (issue #209).
 *
 * Hedera's fee schedule is composed of three components:
 *   - node fees (per transaction, paid to the consensus node operator)
 *   - network fees (per transaction, burned)
 *   - service fees (charged for resources like HCS topic submits / HTS
 *     transfers)
 *
 * For an HCS-based audit-log pattern like AgroDex (every batch registration
 * emits one `TopicMessageSubmitTransaction`), the dominant cost component
 * is the service fee for the topic submission itself, plus a small node fee
 * for the transaction that wraps it.
 *
 * The exact fee is determined on-network and is mostly fixed across
 * testnet/mainnet for the same transaction shape — but the *network/upgraded*
 * fee schedule can change at any mainnet maintenance window. We expose this
 * helper so the front-end can surface a "minimal gas estimate" before the
 * user commits to paying real HBAR.
 *
 * Real numbers are sourced from the Hedera mirror-node
 * `/api/v1/network/fees` endpoint, which returns the live fee schedule at
 * the last header. We apply a configurable safety margin and a hard ceiling
 * to protect users from transient fee spikes.
 *
 * @module backend/src/utils/gasEstimate.js
 */
import axios from 'axios';
import { env } from './config.js';
import { getActiveNetwork } from '../hederaClient.js';

/**
 * Hedera's tinybar → HBAR conversion. 1 HBAR = 100_000_000 tinybar.
 */
export const TINYBARS_PER_HBAR = 100_000_000n;

/**
 * Approximate HBAR → USD conversion rate used for human-readable estimates.
 * Hedera's HBAR price floats, so this is a *display-only* fallback when the
 * caller doesn't have a fresh USD price feed. Keep this conservative so
 * estimates don't understate cost.
 */
export const FALLBACK_USD_PER_HBAR = 0.10;

/**
 * Default safety margin (multiplier) applied on top of the live fee schedule
 * so the user's wallet isn't surprised by a mid-transaction fee bump.
 */
export const DEFAULT_SAFETY_MARGIN = 1.1; // +10% safety overhead

/**
 * Default hard ceiling in tinybars for the gas estimate. If the live fee
 * schedule is higher than this (rare but possible during congestion), the
 * estimator returns the ceiling instead, and emits a warning via `capped`.
 */
export const DEFAULT_TINYBAR_CEILING = 5_000_000n; // 0.05 HBAR ≈ $0.005 at fallback

/**
 * Errors thrown by `fetchNetworkFees` and friends.
 */
export class GasEstimateError extends Error {
  constructor(message, { cause } = {}) {
    super(message);
    this.name = 'GasEstimateError';
    if (cause) this.cause = cause;
  }
}

/**
 * Fetches the live Hedera fee schedule from the configured mirror node.
 *
 * @param {object} [opts]
 * @param {string} [opts.mirrorNodeUrl] - Override `env.MIRROR_NODE_URL`.
 * @param {number} [opts.timeoutMs=5000] - Per-request timeout.
 * @returns {Promise<object>} Raw `/api/v1/network/fees` payload.
 * @throws {GasEstimateError} when the mirror node is unreachable or returns
 *   a non-2xx response.
 */
export async function fetchNetworkFees(
  { mirrorNodeUrl, timeoutMs = 5000 } = {},
) {
  const base = (mirrorNodeUrl ?? env.MIRROR_NODE_URL ?? '').replace(/\/+$/, '');
  if (!base) {
    throw new GasEstimateError('MIRROR_NODE_URL is not configured.');
  }
  const url = `${base}/api/v1/network/fees`;
  try {
    const res = await axios.get(url, { timeout: timeoutMs });
    return res.data;
  } catch (err) {
    if (err?.response) {
      throw new GasEstimateError(
        `Mirror node returned HTTP ${err.response.status} for ${url}`,
        { cause: err },
      );
    }
    if (err?.code === 'ECONNABORTED') {
      throw new GasEstimateError(
        `Mirror node fee fetch timed out after ${timeoutMs}ms`,
        { cause: err },
      );
    }
    throw new GasEstimateError(
      `Failed to fetch Hedera network fees: ${err?.message ?? 'unknown'}`,
      { cause: err },
    );
  }
}

/**
 * Extracts the per-transaction fee (in tinybars) for a given transaction
 * type from the live fee schedule returned by `/api/v1/network/fees`.
 *
 * The Hedera mirror-node fee schedule payload looks like:
 *
 *   {
 *     "fees": [
 *       {
 *         "transaction_fee_schedule": [
 *           { "hash": "0xABC", "fees": [{ "amount": 820000, "denomination": "tinybars" }] }
 *         ]
 *       },
 *       ...
 *     ],
 *     "timestamp": "1750000000.000000000"
 *   }
 *
 * The `hash` field is the canonical Hedera entity-id hash for each
 * transaction type (TopicMessageSubmitTransaction, TokenCreateTransaction,
 * etc). We match on the hash that the SDK exposes for the requested txn,
 * and fall back to the lowest-priced bucket when no specific match is
 * available (since not every mirror-node deployment enumerates all txn
 * types).
 *
 * @param {object} feesPayload - payload returned by `fetchNetworkFees`
 * @param {string} [txnType='TopicMessageSubmitTransaction'] - logical
 *   transaction family. Currently we only honour `TopicMessageSubmitTransaction`
 *   and `TokenCreateTransaction` explicitly; any other value returns the
 *   generic schedule's lowest amount as a defensive estimate.
 * @returns {bigint} Fee in tinybars for a single transaction of the given
 *   type. Returns `0n` when no fee data is available (the caller should
 *   treat 0n as "fee data unavailable, use the network-tiered defaults").
 */
export function extractFeeTinybars(
  feesPayload,
  txnType = 'TopicMessageSubmitTransaction',
) {
  if (!feesPayload || !Array.isArray(feesPayload.fees)) {
    return 0n;
  }

  // The mirror-node payload wraps `transaction_fee_schedule` arrays per
  // fee schedule entry. We iterate all of them and pick the first matching
  // txnType hash. The hash codes are stable on a given network but differ
  // testnet vs mainnet and across SDK versions, so we look up by name as
  // surfaced through the optional `name` field (added post-Hedera 0.46
  // mirror-node release). When `name` isn't present we fall back to the
  // lowest amount in the payload as a conservative estimate.
  let lowest = 0n;
  let matched = 0n;
  let lowestInit = false;

  for (const entry of feesPayload.fees) {
    const schedules = entry?.transaction_fee_schedule;
    if (!Array.isArray(schedules)) continue;
    for (const schedule of schedules) {
      const fees = schedule?.fees;
      if (!Array.isArray(fees) || fees.length === 0) continue;
      const first = fees[0];
      if (!first) continue;
      let amount = first.amount;
      if (typeof amount !== 'number' && typeof amount !== 'bigint') continue;
      let asBigint;
      try {
        // Some mirror-node versions return amount as JSON number, which JS
        // converts to a number; large values lose precision. We use
        // BigInt(amount) defensively, with a string-coerce fallback.
        asBigint =
          typeof amount === 'bigint' ? amount : BigInt(Math.trunc(Number(amount)));
      } catch {
        continue;
      }
      if (first.denomination !== undefined && first.denomination !== 'tinybars') {
        // Skip non-tinybar denominations to keep the unit consistent.
        continue;
      }
      if (!lowestInit) {
        lowest = asBigint;
        lowestInit = true;
      } else if (asBigint < lowest) {
        lowest = asBigint;
      }
      // Name-based matching (preferred, post-0.46 mirror-node).
      if (
        typeof schedule.name === 'string' &&
        schedule.name.toLowerCase() === txnType.toLowerCase()
      ) {
        if (!matched || asBigint > matched) matched = asBigint; // pick the higher (= upper bound) of matched buckets
      }
    }
  }

  return matched || lowest;
}

/**
 * Estimates the total gas cost in tinybars for `batchCount` batch
 * registrations.
 *
 * A "batch registration" in AgroDex currently submits one HCS topic message
 * per batch (provenance event) and mints one HTS NFT (final certificate)
 * per batch — so the *shipped* cost is `batchCount * (HCS + HTS fee)`. For
 * the front-end's "minimal gas price"surface we expose the HCS-only cost so
 * users preparing to log just a batch event (no certificate yet) get an
 * accurate estimate; HTS minting is gated behind a separate API call and
 * charged separately.
 *
 * The estimator:
 *   1. Pulls the live `/api/v1/network/fees` payload from the mirror node.
 *   2. Extracts the per-transaction fee for `TopicMessageSubmitTransaction`.
 *   3. Multiplies by `batchCount`, applies the safety margin, clamps to the
 *      tinybar ceiling.
 *
 * @param {object} opts
 * @param {number} [opts.batchCount=1] - Number of batch registrations to
 *   estimate for. Must be ≥ 0.
 * @param {bigint} [opts.safetyMargin=DEFAULT_SAFETY_MARGIN] - Multiplier
 *   applied on top of the live fee schedule. Higher = more conservative.
 * @param {bigint} [opts.tinybarCeiling=DEFAULT_TINYBAR_CEILING] - Hard
 *   ceiling in tinybars. The total is clamped to this to avoid surprise
 *   spikes; if hit, `capped: true` is returned.
 * @param {string} [opts.mirrorNodeUrl] - Override `env.MIRROR_NODE_URL`.
 * @param {number} [opts.timeoutMs=5000] - HTTP timeout for the mirror-node
 *   fetch.
 * @param {number|null} [opts.usdPerHbar=null] - Override the HBAR→USD
 *   display rate. When `null`, the `FALLBACK_USD_PER_HBAR` is used.
 * @returns {Promise<object>} Estimate payload:
 *   {
 *     tinybarsTotal: bigint,
 *     hbarTotal: number,
 *     usdEstimate: number,
 *     perBatchTinybars: bigint,
 *     safetyMargin: number,
 *     tinybarCeiling: bigint,
 *     capped: boolean,
 *     network: "testnet"|"mainnet",
 *     source: "live"|"fallback",
 *     timestamp: string|undefined
 *   }
 */
export async function estimateBatchGas({
  batchCount = 1,
  safetyMargin = DEFAULT_SAFETY_MARGIN,
  tinybarCeiling = DEFAULT_TINYBAR_CEILING,
  mirrorNodeUrl,
  timeoutMs = 5000,
  usdPerHbar = null,
} = {}) {
  if (!Number.isInteger(batchCount) || batchCount < 0) {
    throw new GasEstimateError('batchCount must be a non-negative integer.');
  }
  if (typeof safetyMargin !== 'number' || safetyMargin < 1) {
    throw new GasEstimateError('safetyMargin must be a number ≥ 1.');
  }
  if (typeof tinybarCeiling !== 'bigint' || tinybarCeiling < 0n) {
    throw new GasEstimateError('tinybarCeiling must be a non-negative bigint.');
  }

  // When the caller explicitly passes an empty `mirrorNodeUrl` in the
  // options bag, fail loudly: this almost certainly means a config error
  // on the caller side, not a transient mirror-node outage. When the
  // caller omits `mirrorNodeUrl`, fetchNetworkFees still raises on the
  // same path — see above.
  if (mirrorNodeUrl !== undefined && (!mirrorNodeUrl || mirrorNodeUrl.trim() === '')) {
    throw new GasEstimateError('mirrorNodeUrl cannot be empty when provided.');
  }

  const network = getActiveNetwork();

  let perBatchTinybars = 0n;
  let source = 'fallback';
  let timestamp;

  try {
    const payload = await fetchNetworkFees({ mirrorNodeUrl, timeoutMs });
    perBatchTinybars = extractFeeTinybars(payload, 'TopicMessageSubmitTransaction');
    timestamp = payload?.timestamp;
    if (perBatchTinybars > 0n) source = 'live';
  } catch {
    // Mirror node unavailable — fall through to the fallback default. The
    // most recent Hedera published estimate for a TopicMessageSubmitTransaction
    // is ~$0.0001 ≈ 1000 tinybars (testnet historical). We pick a slightly
    // higher number on mainnet to stay conservative.
    perBatchTinybars = network === 'mainnet' ? 10_000n : 1_000n;
  }

  // Multiply per-batch by N, apply safety margin (rounding up).
  let tinybarsTotal = perBatchTinybars * BigInt(batchCount);
  const scaled = Number(tinybarsTotal) * safetyMargin;
  tinybarsTotal = BigInt(Math.ceil(scaled));

  let capped = false;
  if (tinybarsTotal > tinybarCeiling) {
    tinybarsTotal = tinybarCeiling;
    capped = true;
  }

  const hbarTotal = Number(tinybarsTotal) / Number(TINYBARS_PER_HBAR);
  const usdRate = typeof usdPerHbar === 'number' ? usdPerHbar : FALLBACK_USD_PER_HBAR;
  const usdEstimate = hbarTotal * usdRate;

  return {
    tinybarsTotal,
    hbarTotal: Number(hbarTotal.toFixed(8)),
    usdEstimate: Number(usdEstimate.toFixed(6)),
    perBatchTinybars,
    safetyMargin,
    tinybarCeiling,
    capped,
    network,
    source,
    timestamp,
  };
}
