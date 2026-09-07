#!/bin/bash
set -euo pipefail

echo "=== Setting up FemFit Proxy on e2-micro ==="

# Install Node.js 20
apt-get update
apt-get install -y curl
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

mkdir -p /opt/femfit-proxy
cd /opt/femfit-proxy

cat << 'EOF' > package.json
{
  "name": "femfit-fatsecret-proxy",
  "version": "1.0.0",
  "type": "module",
  "dependencies": {
    "cors": "^2.8.5",
    "express": "^4.21.2"
  }
}
EOF

npm install --omit=dev

cat << 'EOF' > server.js
import express from 'express';
import cors from 'cors';

const app = express();
const port = parseInt(process.env.PORT || '80', 10);

const clientId = (process.env.FATSECRET_CLIENT_ID || '').trim();
const clientSecret = (process.env.FATSECRET_CLIENT_SECRET || '').trim();
const proxyApiKey = (process.env.PROXY_API_KEY || '').trim();
const tokenUrl = (process.env.FATSECRET_TOKEN_URL || '').trim() ||
  'https://oauth.fatsecret.com/connect/token';
const apiBaseUrl = (process.env.FATSECRET_API_BASE_URL || '').trim() ||
  'https://platform.fatsecret.com/rest/server.api';

app.use(cors());
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

let cachedToken = null;
let tokenExpiresAt = 0;

async function getAccessToken() {
  if (!clientId || !clientSecret) {
    throw new Error('FATSECRET credentials missing');
  }
  const now = Date.now();
  if (cachedToken && now < tokenExpiresAt - 5 * 60 * 1000) {
    return cachedToken;
  }

  const creds = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
  const res = await fetch(tokenUrl, {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${creds}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: 'grant_type=client_credentials&scope=basic'
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`FatSecret auth failed (${res.status}): ${errText}`);
  }

  const data = await res.json();
  const expiresIn = typeof data.expires_in === 'number'
    ? data.expires_in
    : parseInt(data.expires_in, 10) || 86400;

  cachedToken = data.access_token;
  tokenExpiresAt = now + expiresIn * 1000;
  console.log(`[TokenManager] Acquired token; expires in ${expiresIn}s`);
  return cachedToken;
}

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'femfit-fatsecret-proxy',
    configured: Boolean(clientId && clientSecret),
    timestamp: new Date().toISOString()
  });
});

app.get('/', (req, res) => {
  res.json({ status: 'ok', service: 'femfit-fatsecret-proxy' });
});

app.post('/rest/server.api', async (req, res) => {
  if (proxyApiKey && req.headers['x-femfit-key'] !== proxyApiKey) {
    return res.status(401).json({
      error: { code: 401, message: 'Invalid or missing X-FemFit-Key' }
    });
  }

  try {
    const token = await getAccessToken();
    const params = new URLSearchParams();
    for (const [key, value] of Object.entries(req.body)) {
      if (value !== undefined && value !== null) {
        params.append(key, String(value));
      }
    }
    if (!params.has('format')) params.append('format', 'json');

    const upstream = await fetch(apiBaseUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: params.toString()
    });

    const contentType = upstream.headers.get('content-type') || '';
    if (contentType.includes('application/json')) {
      return res.status(upstream.status).json(await upstream.json());
    } else {
      return res.status(upstream.status).send(await upstream.text());
    }
  } catch (err) {
    console.error('[ProxyError]', err.message);
    return res.status(502).json({
      error: { code: 502, message: err.message }
    });
  }
});

app.listen(port, () => {
  console.log(`FemFit FatSecret proxy running on port ${port}`);
});
EOF

cat << 'EOF' > /etc/systemd/system/femfit-proxy.service
[Unit]
Description=FemFit FatSecret Proxy
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/femfit-proxy
Environment=PORT=80
Environment=FATSECRET_CLIENT_ID=0f37b19e58fe453f97f954f302bb2e68
Environment=FATSECRET_CLIENT_SECRET=4d298a5211674ef682cf4c0993a69efd
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable femfit-proxy
systemctl start femfit-proxy

echo "=== FemFit Proxy Service Started on Port 80 ==="
