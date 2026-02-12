# Cora (AGPLv3)

Cora is a private-first cross-platform chat app built with Flutter (Android-first), Matrix Synapse, and a lightweight companion API for friend-code lookups.

> **License:** GNU AGPLv3 (existing repository license retained).

## Repository layout
- `client/` — Flutter client with liquid-glass UI scaffolding and core screens.
- `infra/matrix/` — Docker Compose for Synapse + Postgres, federation disabled.
- `infra/cora-api/` — FastAPI service for email/password signup/login and friend code mapping.
- `docs/` — setup and threat model.

## Android APK (GitHub Actions)
On every push to `main`, the workflow `.github/workflows/android-apk.yml` will:
1. Setup Java 17.
2. Setup Flutter stable with cache.
3. Run `flutter pub get` in `client/`.
4. Build `flutter build apk --debug`.
5. Upload `client/build/app/outputs/flutter-apk/app-debug.apk` as artifact `cora-debug-apk`.

### How to download and install APK
1. Push or merge to `main`.
2. Open the repo **Actions** tab.
3. Open the latest **Android APK** run.
4. Download artifact **cora-debug-apk**.
5. Install `app-debug.apk` on your Android device.

## Run the backend locally
```bash
# Matrix
cd infra/matrix
docker compose up -d

# Companion API
cd ../cora-api
docker build -t cora-api .
docker run --rm -p 8080:8080 cora-api
```

## Auth hashing note
- `cora-api` now stores password hashes using Argon2 (`passlib[argon2]`) instead of raw SHA-256.
- Existing users in a previously-created dev SQLite DB may not be able to log in until those accounts are recreated (or the DB is reset).

## Core feature coverage (v1.0 scaffold)
- Email/password signup and login via Cora UI and `cora-api`.
- Generated unique 5-char friend codes using unambiguous charset (`A-Z` + `2-9`, excluding `I/O/1/0`).
- Friend code lookup endpoint + friend request endpoints.
- DM/group chat screens and invite-only group creation screens.
- Profile/settings screens with display name/avatar/bio fields.
- Runtime-configurable Cora API base URL in Settings (defaults to `http://10.0.2.2:8080` for Android emulator).
- About/Legal screen includes AGPL notice and source code link.
- E2EE expectation documented as Matrix-default for DMs/private groups when supported by SDK/device setup.

## What the server can see
- **Visible metadata:** account email, friend code, Matrix IDs, room membership, connection times, and social graph metadata.
- **Not visible with E2EE enabled:** message body content and encrypted attachments in DMs/private groups.

See `docs/threat-model.md` for a fuller model.
