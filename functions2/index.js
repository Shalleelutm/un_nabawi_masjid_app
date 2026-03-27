const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/*
ANNOUNCEMENTS
*/

exports.broadcastAnnouncement = functions.firestore
.document("announcements/{announcementId}")
.onCreate(async (snap) => {

  const data = snap.data() || {};

  const title = data.title || "Masjid Announcement";
  const body = data.message || "";

  const message = {
    topic: "members",
    notification: {
      title: title,
      body: body,
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


/*
PRAYER TIME CHANGE NOTIFICATION
*/

exports.notifyPrayerChange = functions.firestore
.document("prayer_timetable_overrides/{date}")
.onWrite(async (change, context) => {

  const after = change.after.data();
  const before = change.before.data();

  if (!after) return null;

  if (JSON.stringify(after) === JSON.stringify(before)) {
    return null;
  }

  const date = context.params.date;

  const payload = {
    topic: "members",
    notification: {
      title: "Prayer Time Updated",
      body: `Prayer timetable updated for ${date}. Please check the app.`,
    },
    android: {
      priority: "high",
      notification: {
        channelId: "general_notifications"
      }
    }
  };

  await admin.messaging().send(payload);

  return null;
});