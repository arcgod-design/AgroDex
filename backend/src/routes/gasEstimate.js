/**
 * Route module: GET /api/gas-estimate
 *
 * Surfaces a minimal HBAR + USD cost estimate for a planned Hedera batch
 * registration, so the front-end ("minimal gas price for the user" per
 * issue #209) can show the expected cost before the user signs.
 *
 * Query params (all optional):
 *   - batchCount (int, default 1): number of batch registrations to estimate
 *   - safetyMargin (number, default 1.1): multiplier on top of the live fee
 *   - tinybarCeiling (int, default 5000000): hard ceiling for clamp
 *   - usdPerHbar (number): override for the HBAR→USD display rate
 *
 * Response shape (see `estimateBatchGas` for full structure):
 *   {
 *     network: "mainnet",
 *     batchCount: 5,
 *     tinybarsTotal: "12345",
 *     hbarTotal: 0.00012345,
 *     usdEstimate: 0.000012,
 *     perBatchTinybars: "2469",
 *     safetyMargin: 1.1,
 *     tinybarCeiling: "5000000",
 *     capped: false,
 *     source: "live",        // or "fallback" when the mirror node was unreachable
 *     timestamp: "1750000000.000000000"
 *   }
 */
import { Router } from 'express';
import { estimateBatchGas, GasEstimateError } from '../utils/gasEstimate.js';
import { isMainnet } from '../hederaClient.js';

const router = Router();

router.get('/gas-estimate', async (req, res) => {
  try {
    const batchCount = req.query.batchCount !== undefined
      ? Number.parseInt(String(req.query.batchCount), 10)
      : 1;

    const safetyMargin = req.query.safetyMargin !== undefined
      ? Number.parseFloat(String(req.query.safetyMargin))
      : undefined;

    const tinybarCeiling = req.query.tinybarCeiling !== undefined
      ? BigInt(String(req.query.tinybarCeiling))
      : undefined;

    const usdPerHbar = req.query.usdPerHbar !== undefined
      ? Number.parseFloat(String(req.query.usdPerHbar))
      : null;

    const opts = {
      batchCount,
      ...(safetyMargin !== undefined ? { safetyMargin } : {}),
      ...(tinybarCeiling !== undefined ? { tinybarCeiling } : {}),
      ...(usdPerHbar !== null ? { usdPerHbar } : {}),
    };

    const estimate = await estimateBatchGas(opts);

    // Echo back the network mode in a dedicated field so the front-end
    // doesn't need a separate /api/health call to know whether it's about
    // to spend real HBAR.
    return res.json({
      ok: true,
      network: estimate.network,
      isMainnet: isMainnet(),
      batchCount,
      // bigints cross JSON serialization as JSON numbers when typed
      // loosely; we wrap each one in a string to keep precision. The
      // double BigInt("5000000") round-trip is fine for clients that want
      // numeric usage too.
      tinybarsTotal: estimate.tinybarsTotal.toString(),
      hbarTotal: estimate.hbarTotal,
      usdEstimate: estimate.usdEstimate,
      perBatchTinybars: estimate.perBatchTinybars.toString(),
      safetyMargin: estimate.safetyMargin,
      tinybarCeiling: estimate.tinybarCeiling.toString(),
      capped: estimate.capped,
      source: estimate.source,
      timestamp: estimate.timestamp ?? null,
    });
  } catch (err) {
    if (err instanceof GasEstimateError) {
      return res.status(400).json({
        ok: false,
        error: err.message,
        code: 'gas_estimate_invalid_input',
      });
    }
    console.error('GET /api/gas-estimate Error:', err?.message ?? err);
    return res.status(500).json({
      ok: false,
      error: 'Failed to estimate gas',
    });
  }
});

export default router;
