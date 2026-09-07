import express from 'express';
import cors from 'cors';

const app = express();
const port = parseInt(process.env.PORT || '8080', 10);

const clientId = (process.env.FATSECRET_CLIENT_ID || '').trim();
const clientSecret = (process.env.FATSECRET_CLIENT_SECRET || '').trim();
const proxyApiKey = (process.env.PROXY_API_KEY || '').trim();
const tokenUrl =
  (process.env.FATSECRET_TOKEN_URL || '').trim() ||
  'https://oauth.fatsecret.com/connect/token';
const apiBaseUrl =
  (process.env.FATSECRET_API_BASE_URL || '').trim() ||
  'https://platform.fatsecret.com/rest/server.api';

app.use(cors());
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// In-memory OAuth2 token cache
let cachedToken = null;
let tokenExpiresAt = 0;

async function getAccessToken() {
  if (!clientId || !clientSecret) {
    throw new Error('FATSECRET credentials are not configured on the proxy.');
  }

  const now = Date.now();
  // Reuse token if valid for at least 5 more minutes
  if (cachedToken && now < tokenExpiresAt - 5 * 60 * 1000) {
    return cachedToken;
  }

  const rawCreds = `${clientId}:${clientSecret}`;
  const base64Creds = Buffer.from(rawCreds).toString('base64');
  const response = await fetch(tokenUrl, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${base64Creds}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: 'grant_type=client_credentials&scope=basic',
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(
      `FatSecret token exchange failed (${response.status}): ${errorText}`,
    );
  }

  const data = await response.json();
  if (!data.access_token) {
    throw new Error('No access_token returned by FatSecret auth endpoint.');
  }

  const expiresIn =
    typeof data.expires_in === 'number'
      ? data.expires_in
      : parseInt(data.expires_in, 10) || 86400;

  cachedToken = data.access_token;
  tokenExpiresAt = now + expiresIn * 1000;
  console.log(`[TokenManager] Acquired token; expires in ${expiresIn}s`);
  return cachedToken;
}

// Health check endpoint (used by Caddy/uptime checks)
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'femfit-fatsecret-proxy',
    configured: Boolean(clientId && clientSecret),
    timestamp: new Date().toISOString(),
  });
});

app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    service: 'femfit-fatsecret-proxy',
    version: '1.0.0',
  });
});

// Proxy route for FatSecret REST API
app.post('/rest/server.api', async (req, res) => {
  if (proxyApiKey) {
    const headerKey = req.headers['x-femfit-key'];
    if (headerKey !== proxyApiKey) {
      return res.status(401).json({
        error: { code: 401, message: 'Invalid or missing X-FemFit-Key' },
      });
    }
  }

  try {
    const token = await getAccessToken();

    const params = new URLSearchParams();
    for (const [key, value] of Object.entries(req.body)) {
      if (value !== undefined && value !== null) {
        params.append(key, String(value));
      }
    }

    if (!params.has('format')) {
      params.append('format', 'json');
    }

    const upstreamResponse = await fetch(apiBaseUrl, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: params.toString(),
    });

    const contentType = upstreamResponse.headers.get('content-type') || '';
    if (contentType.includes('application/json')) {
      const data = await upstreamResponse.json();
      return res.status(upstreamResponse.status).json(data);
    } else {
      const text = await upstreamResponse.text();
      return res.status(upstreamResponse.status).send(text);
    }
  } catch (err) {
    console.error('[ProxyError]', err.message);
    return res.status(502).json({
      error: {
        code: 502,
        message: err.message || 'Proxy error contacting FatSecret',
      },
    });
  }
});

app.listen(port, () => {
  console.log(`FemFit FatSecret proxy running on port ${port}`);
});
