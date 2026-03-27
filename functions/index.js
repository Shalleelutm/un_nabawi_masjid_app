const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.broadcastAnnouncement = functions.firestore
  .document("announcements/{announcementId}")
  .onCreate(async (snap) => {

    const data = snap.data() || {};

    const title = data.title || "Masjid Announcement";
    const body = data.message || "";
    const isImportant = data.isImportant === true;

    const message = {
      topic: "members",
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: "announcement",
        title: title,
        body: body,
        important: String(isImportant)
      },
      android: {
        priority: "high",
        notification: {
          channelId: "general_notifications"
        }
      }
    };

    await admin.messaging().send(message);

    return null;
  });
