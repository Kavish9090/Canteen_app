const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onOrderStatusUpdate = functions.firestore
    .document("orders/{orderId}")
    .onUpdate(async (change, context) => {
      const newData = change.after.data();
      const oldData = change.before.data();

      // Only trigger if status has changed
      if (newData.status === oldData.status) {
        return null;
      }

      const studentId = newData.studentId;
      const orderId = context.params.orderId;
      const status = newData.status;

      // Get student's FCM token from users collection
      const userDoc = await admin.firestore().collection("users").doc(studentId).get();
      if (!userDoc.exists) {
        console.log(`User ${studentId} does not exist`);
        return null;
      }

      const fcmToken = userDoc.data().fcmToken;
      if (!fcmToken) {
        console.log(`No FCM token for user ${studentId}`);
        return null;
      }

      let title = "Order Update";
      let body = `Your order status is now: ${status}`;

      if (status === "Ready") {
        title = "Order Ready! 🍔";
        body = `Your order #${newData.tokenNumber} is ready for pickup at the counter.`;
      } else if (status === "Accepted") {
        title = "Order Accepted";
        body = "The kitchen has started preparing your delicious meal.";
      }

      const message = {
        notification: {
          title: title,
          body: body,
        },
        data: {
          orderId: orderId,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        token: fcmToken,
      };

      try {
        const response = await admin.messaging().send(message);
        console.log("Successfully sent message:", response);
        return response;
      } catch (error) {
        console.log("Error sending message:", error);
        return null;
      }
    });
