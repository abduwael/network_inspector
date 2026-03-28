# Changelog

All notable changes to this package will be documented in this file.

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
