\# 🏗️ System Architecture (Full Flow)



```mermaid

flowchart LR



User\["👤 User Mobile"] --> App\["📱 Flutter App"]



subgraph AppLayer

App --> UI\["UI Screens"]

App --> Provider\["State Management (Provider)"]

end



subgraph Firebase

Auth\["🔥 Firebase Auth"]

DB\["📂 Firestore DB"]

Storage\["🖼️ Firebase Storage"]

FCM\["🔔 Firebase Messaging"]

end



subgraph Services

Notif\["📢 Local Notifications"]

Prayer\["🕌 Prayer Engine"]

Quran\["📖 Quran Service"]

Gallery\["🖼️ Gallery Service"]

end



UI --> Provider



Provider --> Auth

Provider --> DB

Provider --> Storage

Provider --> FCM



Provider --> Quran

Provider --> Prayer

Provider --> Gallery



FCM --> Notif

Prayer --> Notif



DB --> Gallery

Storage --> Gallery



Gallery --> UI

Quran --> UI

Prayer --> UI



Notif --> User





\---



\# 💥 RESULT



👉 This shows:

\- full architecture

\- real understanding

\- system thinking



👉 Recruiter sees → \*\*“this guy understands systems”\*\*



\---



\# 🚀 STEP 2 — ADD TO README (IMPORTANT)



Open your `README.md`



👉 Add THIS section under Architecture:



```md

\## 🧠 System Architecture



See full architecture:



👉 \[View System Diagram](docs/system-architecture.md)

