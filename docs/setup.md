# Cora setup guide

## 1) Build Android APK in GitHub Actions
1. Push commits to `main`.
2. Open **Actions** → **Android APK** workflow run.
3. Download `cora-debug-apk` artifact.
4. Install the APK on Android:
   - Allow installs from unknown sources for your file manager.
   - Transfer APK to phone and open it.

## 2) Run Matrix + Cora API locally
```bash
cd infra/matrix
docker compose up -d

cd ../cora-api
docker build -t cora-api .
docker run --rm -p 8080:8080 cora-api
```

Matrix Synapse serves on `http://localhost:8008` and API on `http://localhost:8080`.

## 3) Run Flutter client
```bash
cd client
flutter pub get
flutter run
```
