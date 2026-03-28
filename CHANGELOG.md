# Changelog

All notable changes to this package will be documented in this file.

## 1.1.18

- README: use `raw.githubusercontent.com` URLs for screenshot `<img>` tags so images load on pub.dev (relative `doc/screenshots/...` paths in HTML are not resolved on the package page).

## 1.1.17

- Refreshed `doc/screenshots/*.png` from `review_before_pub` (`01`–`05`, including `04_error.png`).

## 1.1.16

- Declare five `screenshots` in `pubspec.yaml` so pub.dev serves them from the package (avoids broken README images from `raw.githubusercontent.com` when GitHub is out of sync or blocks embedding).
- README: replace the wide screenshot table with fixed-width inline previews using paths under `doc/screenshots/`; clarify carousel vs README.
- Published `doc/screenshots/*.png` match `doc/screenshots/review_before_pub/01`–`05` (same files and order: list, POST detail, bodies, error detail, 403 headers/response).

## 1.1.15

- README screenshots normalized to a uniform 738×1600 canvas (from `review_before_pub` order: list, POST detail, bodies, forbidden error, 403 headers/response).

## 1.1.14

- Confirmed README screenshots match `doc/screenshots/review_before_pub` (unaltered PNGs); `review_before_pub` is excluded from the published package via `.pubignore` to avoid duplicate assets.

## 1.1.12

- README screenshots are **unaltered** PNG exports (no blur, resize, or overlays); use sanitized demo data in the captures themselves for pub.dev.

## 1.1.11

- Five README screenshots from your latest captures: solid-fill redaction (no blur), light sharpen, 640px width. Files: `request_list.png`, `request_details.png`, `request_bodies.png`, `request_error.png`, `request_error_403.png`.
- Numbered copies for review: `doc/screenshots/review_before_pub/01`–`05` (same pixels as the five files above, before rename).

## 1.1.10

- README: three pub.dev screenshots (list, success details, error details); full URL and `Authorization` / Bearer values redacted in detail shots.
- Added `doc/screenshots/request_error.png` for the error/403 flow.

## 1.1.9

- README: show screenshots in a compact two-column table (similar layout to other inspector packages on pub.dev).
- Removed the demo video from the README and dropped `doc/demo.mp4` from the published package to keep the page and tarball smaller.

## 1.1.8

- Added README screenshots and a demo video (`doc/screenshots/`, `doc/demo.mp4`).
- Documented pub.dev-friendly image URLs via `raw.githubusercontent.com`.

## 1.1.7

- Simplified `example/` app to focus on the two most common integrations: Dio and `package:http`.
- Removed GetConnect flow from the live example to reduce onboarding complexity.
- Kept logging flow explicit with `logRequest` and `logResponse` so developers can copy and adapt quickly.

## 1.1.6

- Improved README with a stronger quick-start section and clearer developer onboarding.
- Added a top-level AI quick prompt for faster integration.
- Added explicit flavor-based setup examples using `NetworkInspector.init(enabled: AppConfig.isDev)`.
- Simplified real-app integration guidance with a framework-agnostic `MaterialApp` builder pattern.

## 1.1.5

- Publishing prep release for pub.dev.
- Added in-app network inspector dialog with draggable FAB overlay.
- Added GetConnect integration helpers via `onRequest` and `onResponse`.
- Added manual logging APIs for other clients: `logRequest` and `logResponse`.
- Added JSON export and log sharing support.
- Added comprehensive README integration guides and an `example/` app.
