# Driver background location (Step 15)

## Approach

Use a **foreground-service** location stream (Android `foregroundServiceType=location`) and iOS **When In Use** + `UIBackgroundModes: location`. That avoids `ACCESS_BACKGROUND_LOCATION` and Google Play’s stricter background-location review. Verify against current platform docs before store submission — these rules change.

`geolocator_android` declares `GeolocatorLocationService` with `foregroundServiceType="location"`. Confirm in the merged manifest when you can run Gradle:

```bash
cd apps/driver-app/android
./gradlew :app:processDebugManifest
# inspect app/build/intermediates/merged_manifests/debug/processDebugManifest/AndroidManifest.xml
```

## Runtime

- Start tracking only while on shift; stop immediately when the shift ends.
- Interval: **5s** with an active booking/offer, **15s** when idle on shift.
- On app resume: `GET /driver/me/state`; restart the stream if on shift and not running.
- While the socket is down: keep the last **50** pings in memory; flush to `POST /driver/location/batch` (chunks of ≤20) on reconnect.
- Prominent disclosure → `POST /driver/consents` → then OS permission (never the reverse).
- One-time OEM battery help screen; do **not** request ignore-battery-optimizations.
- If the OS kills the process, tracking stops until the driver reopens the app (Day-5 presence sweeper clears stale state).

## Store checklist (Day 10)

- Privacy policy URL
- Play Data safety form + foreground-service declaration (short demo video)
- Apple privacy nutrition label + App Review notes for background location
- In-app account deletion (required when the app supports account creation)
