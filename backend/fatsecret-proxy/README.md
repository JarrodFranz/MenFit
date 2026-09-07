> **Shared infrastructure.** This proxy is deployed once, in FemFit's GCP
> project `femfit-5e600`, and is used by both FemFit and MenFit. Resource
> names below are the real deployed ones and must not be renamed here.

# FemFit FatSecret API Proxy Server

A lightweight, secure API reverse proxy that brokers requests between the
FemFit mobile/web application and the FatSecret Platform REST API. It runs on
a dedicated Google Compute Engine `e2-micro` VM (Always Free tier) so it has a
single, stable static egress IP that can be placed on FatSecret's IP
allowlist.

## Why a VM instead of Cloud Run

Cloud Run does not provide a free static egress IP (Cloud NAT, which would
give one, costs roughly $32/month), and FatSecret's IP restriction feature
rejects wide-open ranges like `0.0.0.0/0`. A Compute Engine VM can be given a
reserved static IPv4 address at no extra cost while attached to a running
instance, so the proxy was moved off Cloud Run onto a VM. **The original Cloud
Run service (`femfit-fatsecret-proxy` in `us-central1`) has been deleted.**
There is no Cloud Run deployment for this proxy any more.

## Features

- **Protects secrets:** the mobile/web client never receives or embeds the
  `FATSECRET_CLIENT_SECRET`.
- **Automatic OAuth 2.0 management:** acquires, caches, and refreshes FatSecret
  OAuth tokens in memory (`server.js`, `getAccessToken`).
- **Stable static IP:** reserved static IPv4 address `34.27.29.29`, usable in
  FatSecret's IP allowlist instead of an open CIDR range.
- **Automatic HTTPS:** Caddy reverse-proxies the Node service and obtains a
  Let's Encrypt certificate for `34.27.29.29.sslip.io` with no domain
  purchase required.
- **App protection:** optional `X-FemFit-Key` header (`PROXY_API_KEY`) that
  the proxy checks on every `/rest/server.api` request.

## Current deployment

- Project: `femfit-5e600`, region/zone: `us-central1`.
- Static IP: `femfit-proxy-ip` (`34.27.29.29`), reserved separately from the
  instance so it survives an instance rebuild.
- Firewall rule `allow-femfit-proxy`: inbound TCP 80, 443, 8080.
- Instance: `femfit-proxy-vm` (`e2-micro`, 30 GB pd-standard, Debian 12,
  Always Free tier), provisioned with the startup script in this directory
  (`startup-script.sh`).
- Public endpoint: `https://34.27.29.29.sslip.io/rest/server.api`.
- Health check: `https://34.27.29.29.sslip.io/health`.

## How `startup-script.sh` provisions the VM

The script is passed to `gcloud compute instances create` as
`--metadata-from-file startup-script=startup-script.sh` (or pasted into the
instance's startup-script metadata for an existing instance). On boot it:

1. Installs Node.js 20 via NodeSource.
2. Writes `package.json` and `server.js` into `/opt/femfit-proxy` (the copies
   embedded in the script — keep them in sync with the versions in this
   directory if you change proxy behaviour) and runs `npm install --omit=dev`.
3. Writes a systemd unit, `/etc/systemd/system/femfit-proxy.service`, that
   runs `node server.js` as `root`, with `Restart=always`, listening on the
   port from the `PORT` environment variable (the unit sets `PORT=80`).
4. The FatSecret credentials (`FATSECRET_CLIENT_ID`, `FATSECRET_CLIENT_SECRET`)
   are baked into the systemd unit's `Environment=` lines inside the script
   itself — there is no separate secrets file on the VM. `PROXY_API_KEY` is
   read by `server.js` from the environment but is **not** currently set by
   `startup-script.sh`; add an `Environment=PROXY_API_KEY=...` line to the
   unit (either in the script before provisioning, or directly on the VM,
   see below) if you want the `X-FemFit-Key` gate enforced.
5. Enables and starts `femfit-proxy.service` via `systemctl`.

Caddy (installed separately, not by `startup-script.sh`) reverse-proxies
`34.27.29.29.sslip.io` on ports 80/443 to the Node service and handles the
Let's Encrypt certificate automatically.

## Updating the running proxy

`startup-script.sh` only runs automatically on first boot; it defines no
automated redeploy/update path. To ship a change to `server.js`:

1. Edit `server.js` in this directory (and keep the copy embedded in
   `startup-script.sh` in sync, since a future re-provision of the VM uses the
   script's embedded copy, not this file).
2. SSH to the instance: `gcloud compute ssh femfit-proxy-vm --zone us-central1-<zone>`.
3. Copy the updated `server.js` to `/opt/femfit-proxy/server.js` on the VM
   (e.g. via `gcloud compute scp backend/fatsecret-proxy/server.js femfit-proxy-vm:/opt/femfit-proxy/server.js --zone us-central1-<zone>`).
4. Restart the service: `sudo systemctl restart femfit-proxy`.
5. Verify: `curl https://34.27.29.29.sslip.io/health`.

To change environment variables (e.g. add `PROXY_API_KEY`), edit
`/etc/systemd/system/femfit-proxy.service` on the VM directly, then run
`sudo systemctl daemon-reload && sudo systemctl restart femfit-proxy`.

## The `X-FemFit-Key` gate

`server.js` only enforces the `X-FemFit-Key` header check when `PROXY_API_KEY`
is a non-empty environment variable on the proxy; if it is unset, the
`/rest/server.api` route accepts any caller. On the client side, the FemFit
app only sends the `X-FemFit-Key` header when `FATSECRET_PROXY_KEY` is set in
`env/dev.secrets.json` (or the equivalent `--dart-define`) — see
`lib/core/config/env.dart`. Both sides must agree: set the same value in the
VM's `PROXY_API_KEY` and the client's `FATSECRET_PROXY_KEY` env entry, or
leave both unset.

## CORS

`server.js` calls `app.use(cors())` with no origin restriction, so the proxy
currently allows requests from any origin. This is acceptable because the
route requires a valid `X-FemFit-Key` (when configured) and never exposes the
FatSecret client secret itself, but it means the proxy is not origin-locked.

## Configuring the client app (FemFit or MenFit)

Both apps configure the same way. Set `FATSECRET_PROXY_URL` to the proxy's
`/rest/server.api` path (it must end in `/rest/server.api`) in
`env/dev.secrets.json` or via `--dart-define`:

```json
{
  "FATSECRET_PROXY_URL": "https://34.27.29.29.sslip.io/rest/server.api"
}
```

If the `X-FemFit-Key` gate is enabled on the proxy, also set
`FATSECRET_PROXY_KEY` to the matching value in the same file.

## FatSecret IP allowlist

In the FatSecret Platform developer console (**Manage API Keys** > **IP
Restrictions**), add the VM's static IP `34.27.29.29` (not a wide-open range —
that is the reason this proxy runs on a VM rather than Cloud Run).
