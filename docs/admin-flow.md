# Admin Flow

```mermaid
flowchart TD
AdminLogin --> AdminDashboard
AdminDashboard --> UploadMedia
UploadMedia --> Firestore
Firestore --> Users
AdminDashboard --> PostAnnouncement
PostAnnouncement --> Notifications

