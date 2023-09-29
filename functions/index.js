const {onRequest} = require("firebase-functions/v2/https");
const {database, pubsub} = require("firebase-functions");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

admin.initializeApp();


// Trigger when a new post is created
exports.onNewPost = database.ref("posts/{groupChatId}/{postId}")
    .onCreate(async (snapshot, context) => {
      try {
        const groupChatId = context.params.groupChatId;
        const groupChatRef = admin.database().ref(`groupchats/${groupChatId}`);

        const groupChatSnapshot = await groupChatRef.once("value");
        const groupChatData = groupChatSnapshot.val();

        if (!groupChatData.firstPostTime) {
          const now = new Date().getTime();
          const randomDuration = Math.floor(Math.random() *
          (900000 - 600000) + 600000);

          await groupChatRef.update({
            firstPostTime: now,
            randomDuration: randomDuration,
          });
        }
      } catch (error) {
        logger.error("Error in onNewPost: ", error);
      }
    });

// Scheduled function to delete posts
exports.scheduledFunction = pubsub.schedule("every 1 minutes")
    .onRun(async (context) => {
      try {
        const now = new Date().getTime();
        const groupChatsRef = admin.database().ref("groupchats");

        const groupChatsSnapshot = await groupChatsRef.once("value");

        const allPromises = [];
        groupChatsSnapshot.forEach((childSnapshot) => {
          const groupChat = childSnapshot.val();
          const firstPostTime = groupChat.firstPostTime;
          const randomDuration = groupChat.randomDuration;

          if (now >= (firstPostTime + randomDuration)) {
            const postsRef = admin.database().ref(`posts/${childSnapshot.key}`);
            const deletePostsPromise = postsRef.remove();

            const updateChatPromise = groupChatsRef.child(childSnapshot.key)
                .update({
                  firstPostTime: null,
                  randomDuration: null,
                });

            allPromises.push(deletePostsPromise, updateChatPromise);
          }
        });

        await Promise.all(allPromises);
        return null;
      } catch (error) {
        logger.error("Error in scheduledFunction: ", error);
      }
    });


exports.sendNotificationToUser = onRequest(async (request, response) => {
  try {
    const userId = request.body.userId; // Get the user ID from the request body
    const userRef = admin.database().ref(`profile/${userId}`);
    const userSnapshot = await userRef.once("value");
    const userData = userSnapshot.val();
    const bodymessage = `Hello, ${userData.displayName}! Tap to keepUp.`;

    if (userData && userData.fcmToken) {
      const message = {
        token: userData.fcmToken,
        notification: {
          title: "keepUp",
          body: bodymessage
          ,
        },
      };

      // Send the FCM notification
      await admin.messaging().send(message);
      response.status(200).send("Notification sent successfully!");
    } else {
      response.status(400).send("User does not have an FCM token.");
    }
  } catch (error) {
    logger.error("Error in sendNotificationToUser: ", error);
    response.status(500).send("Error sending notification.");
  }
});
