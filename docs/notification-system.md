# Notification System

The app uses Firebase Cloud Messaging and local notifications.

## Notification Flow

```mermaid
flowchart TD
Admin --> Firestore
Firestore --> FCM
FCM --> Device
Device --> LocalNotification
LocalNotification --> User
Triggers
Prayer time reminders
Admin announcements
Community updates
