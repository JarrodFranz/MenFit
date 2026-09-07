# Emulator: every HTTPS request fails ("We couldn't connect") — Avast interception (2026-09-05)

**Symptom.** On `emulator-5554` (Pixel 6 Pro API 36) every network feature of
the app fails instantly with its generic "couldn't connect" copy: online
food search, barcode lookup, route suggestions. `dumpsys connectivity` says
the wifi network is `VALIDATED`; the host reaches the same URLs fine.

**Root cause (measured).** Avast "Web/Mail Shield" HTTPS scanning on the dev
PC intercepts the emulator's traffic too, because the emulator's user-mode
NAT goes out through the host TCP stack. The emulator's trust store does not
contain Avast's root, so every TLS handshake fails. Proof:

- Chrome *inside the emulator* shows `NET::ERR_CERT_AUTHORITY_INVALID` for
  both `https://34.27.29.29.sslip.io/health` (the FatSecret proxy VM) and
  `https://world.openfoodfacts.org/`.
- From the host, `openssl s_client` against either host prints
  `issuer=... CN=Avast Web/Mail Shield Root` — the same interception that
  broke Gradle downloads (`android_build.md`).

Not a cause, checked and ruled out: the release APK does carry
`android.permission.INTERNET` (`aapt dump permissions`); the VM proxy answers
`200` to a real `foods.search` from the host; ICMP `ping` from the emulator
always fails through the NAT and proves nothing either way.

**Fix (owner-side, security setting — an agent must not change it).** In
Avast, exclude the emulator process from HTTPS scanning: Menu → Settings →
Protection → Core Shields → Web Shield → "Configure shield settings" →
disable "Enable HTTPS scanning", or add an exception for
`%LOCALAPPDATA%\Android\Sdk\emulator\qemu\windows-x86_64\qemu-system-x86_64.exe`.
Then restart the emulator. Until that is done, **no HTTPS behaviour can be
verified on the emulator**; verify network features on a physical phone (a
tester build from Firebase App Distribution is fine) or on Chrome
(`flutter run -d chrome`), which trusts the Windows certificate store.

**Do not** work around this in the app (user-CA trust in
`network_security_config`, disabled certificate checks, HTTP fallbacks).
Testers' phones are not behind Avast; the interception exists only on this
PC.

Also seen while diagnosing: after the host sleeps or changes network, the
emulator sometimes loses its route entirely (`connect: Network is
unreachable`, no `0.0.0.0/0` route). `adb emu kill` and relaunch
(`emulator -avd Pixel_6_Pro_API_36 -dns-server 8.8.8.8,1.1.1.1`) restores it;
toggling wifi with `svc wifi disable/enable` does not.
