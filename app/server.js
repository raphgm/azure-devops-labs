// Minimal sample app the rest of this repo deploys — a health-check API,
// deliberately small so the infrastructure and pipeline are what's on display.
const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.get('/', (req, res) => res.json({ service: 'azure-devops-labs', status: 'ok' }));
app.get('/health', (req, res) => res.status(200).send('ok'));

app.listen(PORT, () => console.log(`Listening on ${PORT}`));
