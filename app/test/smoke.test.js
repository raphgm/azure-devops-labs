// Smoke test: confirms the deployed service answers before the CI pipeline
// promotes an image to production. Run against a live URL:
//   TARGET_URL=https://<your-app> node test/smoke.test.js
const http = require('http');
const https = require('https');

const target = process.env.TARGET_URL || 'http://localhost:8080/health';
const client = target.startsWith('https') ? https : http;

client
  .get(target, (res) => {
    if (res.statusCode !== 200) {
      console.error(`FAIL: ${target} returned ${res.statusCode}`);
      process.exit(1);
    }
    console.log(`OK: ${target} returned 200`);
    process.exit(0);
  })
  .on('error', (err) => {
    console.error(`FAIL: ${err.message}`);
    process.exit(1);
  });
