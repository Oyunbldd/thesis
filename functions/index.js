const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Triggered when a new document is created in the `notifications` collection.
 * Looks up the target user's FCM token and sends a push notification.
 */
exports.sendMatchNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap) => {
    const data = snap.data();
    const { toUserId, title, body, newItemId, newItemType, matchedItemId } = data;

    if (!toUserId) {
      console.log('ERROR: toUserId is missing');
      return null;
    }

    // Get the target user's FCM token
    const userDoc = await admin.firestore().collection('users').doc(toUserId).get();
    const fcmToken = userDoc.data()?.fcmToken;
    console.log('toUserId:', toUserId);
    console.log('userDoc exists:', userDoc.exists);
    console.log('fcmToken:', fcmToken ? 'found' : 'NOT FOUND');

    if (!fcmToken) {
      console.log('ERROR: fcmToken is null or missing for user', toUserId);
      return null;
    }

    // Send the push notification
    await admin.messaging().send({
      token: fcmToken,
      notification: { title, body },
      data: {
        newItemId: newItemId ?? '',
        newItemType: newItemType ?? '',
        matchedItemId: matchedItemId ?? '',
      },
      android: {
        notification: { channelId: 'matches' },
      },
      apns: {
        payload: {
          aps: { sound: 'default' },
        },
      },
    });

    return null;
  });
