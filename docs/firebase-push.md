# Firebase push setup (Steps 13–14)

One-time console work. Client wiring lives in `bridgecabs_core` (`push/`) and each app’s `main.dart` / `firebase_options.dart`.

## 1. Firebase project

1. Create a **dev** Firebase project (use a separate project for production later).
2. Add Android apps:
   - Driver: `com.bridgecabs.driver_app`
   - Passenger: `com.bridgecabs.passenger_app`
3. Add iOS apps:
   - Driver: `com.bridgecabs.driverApp`
   - Passenger: `com.bridgecabs.passengerApp`

## 2. FlutterFire CLI (per app)

```bash
dart pub global activate flutterfire_cli

cd apps/driver-app
flutterfire configure

cd ../passenger-app
flutterfire configure
```

This overwrites `lib/firebase_options.dart`, writes `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist`.

Placeholder `projectId: bridgecabs-unconfigured` in the checked-in stubs skips Firebase init until you configure.

## 3. iOS (paid Apple Developer Program)

1. In Xcode → Signing & Capabilities: enable **Push Notifications** and **Background Modes → Remote notifications** (Info.plist already includes `UIBackgroundModes` / `remote-notification`; entitlements files are wired).
2. Apple Developer → Keys → create an **APNs Auth Key** (`.p8`).
3. Upload the `.p8` in Firebase → Project settings → Cloud Messaging.
4. Push testing needs a **physical iPhone** (simulator cannot receive FCM).

## 4. Secrets vs client config

| File | Commit? |
|------|---------|
| Firebase **service account** JSON (Admin SDK) | **Never** — keep on the API host / secrets manager only |
| `google-services.json` / `GoogleService-Info.plist` | OK to commit for private repos; still **restrict API keys** in Google Cloud Console |
| `firebase_options.dart` | Same as client config |

Server env: `FIREBASE_SERVICE_ACCOUNT_JSON` (or path) for `firebase-admin` in the Nest API — do not put that JSON in git.

## 5. Runtime behaviour (already wired)

- **Driver**: request notification permission after login; if denied, home shows a persistent banner.
- **Passenger**: request after the first successful booking.
- **Register**: `POST /devices` after permission + on `onTokenRefresh`.
- **Logout**: `DELETE /devices/:token` then `FirebaseMessaging.instance.deleteToken()`.
- **Foreground**: no system notification; if the socket is down, refresh state over REST.
- **Tap / cold start**: `onMessageOpenedApp` / `getInitialMessage` → `refreshState()`; go_router redirects from snapshot state.
- **Android 13+**: `POST_NOTIFICATIONS` in the manifest; runtime prompt via `requestPermission`.
- Do **not** rely on full-screen intents (Android 14+ limits `USE_FULL_SCREEN_INTENT`). Use the high-importance `offers` channel with sound.
