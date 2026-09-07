# 011 — Native sharing via share_plus

- **Status:** Accepted
- **Date:** 2026-09-02

## Context

Five surfaces (`workout_share_dialog.dart`, `challenge_celebration_sheet.dart`,
`challenge_code_panel.dart`, `cycle_screen.dart`, `recap_share_sheet.dart`) only
call `Clipboard.setData`. The app needs the OS share sheet on iOS/Android, the
Web Share API on web, and the Windows Share UI, for two kinds of content: (a) a
rendered workout share card as PNG bytes plus text, and (b) plain text
(challenge codes, recap summaries). All four platforms are first-class.

## Options considered

- **share_plus** (fluttercommunity) — all four platforms, 13.3.0 released Jul
  2026, monthly releases, 150 pub points, 4,020 likes, BSD-3, verified
  publisher.
- **share_handler** — receive-only, not applicable to this use case.
- **flutter_share** — discontinued by its author in favour of share_plus.
- **social_share** / **esys_flutter_share** — dead, mobile-only; the latter is
  also Dart-3-incompatible.
- **Owned platform code** — roughly 100-150 lines each for iOS/Android/Web, but
  Windows needs WinRT/COM interop via `IDataTransferManagerInterop` —
  materially more work, duplicating what `share_plus_windows` already does.

## Decision

Adopt **share_plus 13.3.0, pinned exactly**, reached only through a
`SharingAdapter` in `core/platform/` (same pattern as `HealthAdapter` /
`NotificationsAdapter`), exposing:

- `shareImage(pngBytes, fileName, text?, sharePositionOrigin?)`
- `shareText(text, sharePositionOrigin?)`

Both return a `ShareOutcome` — `{success, dismissed, unavailable,
fellBackToDownload, fellBackToClipboard}` — plus a `supportsShareResult` flag
(`false` on Windows).

## Reasons

- The only maintained all-four-platform option.
- No codegen/analyzer-touching transitive deps — safe for the analyzer-13
  window.
- `win32 ^6.0.1` is already satisfied by our locked `win32 6.4.0`.
- Flutter `>=3.38.1` / Dart `>=3.10` sit inside our `3.47.2` / `3.13.2`.
- `XFile.fromData(bytes, name:, mimeType:)` shares in-memory PNG bytes without
  a temp file.
- Web fallback (download/mailto when the Web Share API is absent, e.g. desktop
  Firefox) is built in.
- Windows is a real `DataTransferManager` implementation, not a stub.

## Consequences

- Copy stays first-class at every surface (not fallback-only) because Windows
  has edition-specific failures (plus_plugins #3687, Windows 11 Home, closed
  but not fixed; #3619, open) and desktop Firefox has no Web Share API.
- UI must never claim confirmed delivery on Windows — `supportsShareResult` is
  `false` there and `ShareOutcome` is always `unavailable`.
- iPad requires `sharePositionOrigin`.
- Web requires a user gesture and HTTPS.
- The `RepaintBoundary` → PNG capture for the workout share card is new work
  this ADR enables but does not itself deliver.
- **Windows behaviour must be verified on the dev machine before it is
  trusted.**

## Rejected alternatives

- **share_handler** — receive-only; does not send.
- **flutter_share** — discontinued by its own author, who now points users at
  share_plus.
- **social_share / esys_flutter_share** — both effectively dead; mobile-only,
  and esys_flutter_share is Dart-3-incompatible.
- **Owned platform code** — plausible for iOS/Android/Web at ~100-150 lines
  each, but Windows would need hand-written WinRT/COM interop via
  `IDataTransferManagerInterop`, duplicating `share_plus_windows` for no
  benefit.

## Revisit triggers

- No share_plus release in over 9 months, or a further unfixed Windows
  regression.
- A Flutter bump that moves the `win32` floor outside `^6.0.1`.
- A product decision to drop native Windows sharing in favour of Save/Copy
  only.
