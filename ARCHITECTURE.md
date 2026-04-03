# 🏗️ App Architecture

## System Architecture
┌─────────────────────────────────────────────────────────────┐
│ FLUTTER UI LAYER │
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ │
│ │ Home │ │Quran │ │Prayer│ │Admin │ │Profile│ │
│ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ │
└─────────────────────────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│ STATE MANAGEMENT │
│ Provider + ChangeNotifier │
└─────────────────────────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│ SERVICE LAYER │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│ │ Prayer │ │ Quran │ │ Auth │ │ Notify │ │
│ │ Service │ │ Service │ │ Service │ │ Service │ │
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │
└─────────────────────────────────────────────────────────────┘
│
┌───────────────────┼───────────────────┐
▼ ▼ ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ LOCAL DATA │ │ FIREBASE │ │ EXTERNAL │
│ SQLite │ │ Auth/Firestore│ │ APIs │
│ SharedPrefs │ │ FCM/Storage │ │ Prayer API │
└─────────────────┘ └─────────────────┘ └─────────────────┘

text

## Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.16.9 |
| State | Provider |
| Local DB | SQLite |
| Backend | Firebase |
| Auth | Firebase Auth |
| Database | Cloud Firestore |
| Push | FCM |
| CI/CD | GitHub Actions |
