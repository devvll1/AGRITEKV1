/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const functions = require("firebase-functions");
// const admin = require("firebase-admin");
// admin.initializeApp();

// exports.sendNotification = functions.firestore
//     .document("notifications/{userId}/userNotifications/{notificationId}")
//     .onCreate(async (snapshot, context) => {
//       const notificationData = snapshot.data();
//       const userId = context.params.userId;

//       // Get the user's FCM token
//       const userDoc = await admin.firestore()
//           .collection("users")
//           .doc(userId)
//           .get();
//       const fcmToken = userDoc.data().fcmToken;

//       if (fcmToken) {
//         const payload = {
//           notification: {
//             title: notificationData.type === "like"?"New Like":"New Comment",
//             body: `${notificationData.senderName} ${
//               notificationData.type === "like" ? "liked": "commented on"
//             } your post.`,
//           },
//         };

//         // Send the notification
//         await admin.messaging().sendToDevice(fcmToken, payload);
//       }
//     });const functions = require('firebase-functions');