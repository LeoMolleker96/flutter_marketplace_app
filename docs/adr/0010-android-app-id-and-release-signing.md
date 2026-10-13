# ADR-0010: Real application ID and Android release signing with an owner-held upload key

- **Status:** Accepted
- **Date:** 2026-10-13
- **Milestone:** v0.1

## Context

The Flutter template left two things unfit for publishing:

- The IDs were still `com.example.*` (`com.example.marketplace_app` on Android, `com.example.marketplaceApp` on iOS). Stores reject `com.example`, and an application ID cannot be changed once an app is published.
- `android/app/build.gradle.kts` signed the **release** build with the debug key. The debug key is public knowledge (every developer has the same kind of key), so a build signed with it cannot be uploaded to Google Play, and nothing signed that way can ever be updated by the real key later.

The signing key is a secret. It must never be created by an agent, appear in the repository, or be seen by tooling that logs output.

## Decision

- The application ID (Android `namespace` and `applicationId`) and the iOS bundle identifier are **`com.leonardomolleker.marketplace`**. The iOS test target uses `com.leonardomolleker.marketplace.RunnerTests`. `MainActivity.kt` moved to the matching package directory.
- Android release builds are signed with an **upload keystore created by the owner** with `keytool`, stored **outside the repository**:

  ```bash
  keytool -genkey -v -keystore ~/keys/marketplace-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```

- The keystore and its passwords are **backed up in the owner's password manager**. Losing the upload key blocks updates until Google resets it; leaking it lets someone publish as us. Enrolling in **Play App Signing** mitigates the loss case: Google holds the real app-signing key, and the upload key can be replaced through support.
- `android/key.properties` (keys `storeFile`, `storePassword`, `keyPassword`, `keyAlias`, Flutter's documented convention) tells Gradle where the keystore is. It is **untracked** (`android/.gitignore` ignores `key.properties`, `*.jks`, `*.keystore`); `android/key.properties.example` documents the shape with placeholders.
- A release build **fails** with an explicit message when `key.properties` is missing, instead of silently falling back to the debug key. The check runs once the task graph is known (`gradle.taskGraph.whenReady`), and only if a `*Release*` task is going to run, so debug builds keep working on a fresh clone.
- **iOS** has no keystore: signing goes through the Apple Developer account and Xcode (certificates and provisioning profiles). Only the bundle ID changed here; team and signing settings are out of scope until publishing.
- At **v0.7**, CI will receive the keystore (base64) and the passwords as repository secrets and write `key.properties` at build time.

## Alternatives considered

### Keep signing release with the debug key

- What it would have looked like: leave the template's `signingConfigs.getByName("debug")`, so `flutter run --release` works everywhere.
- Rejected: Google Play rejects debug-signed bundles, and an app first distributed that way cannot be updated by builds signed with the real key. It also hides the problem until release day.

### Commit the keystore (or its passwords)

- What it would have looked like: a `.jks` in the repo so any clone can produce a signed release.
- Rejected: it publishes the credential that proves "this is our app". Git history keeps it forever, so removing it later does not undo the leak.

### Environment variables only

- What it would have looked like: Gradle reads `KEYSTORE_PATH`, `KEYSTORE_PASSWORD`, etc. from the environment, with no `key.properties`.
- Rejected for local work: less discoverable (nothing in the repo shows what to set) and harder to keep per project. Nothing prevents adding an environment fallback later for CI.

## Consequences

**Positive** — the app has a publishable identity; release signing uses a key only the owner holds; a missing key fails loudly with a message pointing at the fix; debug builds and fresh clones are unaffected.

**Negative** — nobody (including CI, until v0.7) can build a signed release without the owner's local setup, and `flutter run --release` on a machine without `key.properties` no longer works. The application ID is now effectively permanent once the app is published. The owner is responsible for the key's backup.

**Revisit when** — CI is introduced (v0.7: inject secrets), flavors are introduced (v0.6: per-flavor IDs such as a `.dev` suffix and signing configs), or the owner enrols in Play App Signing and wants to rotate the upload key.
