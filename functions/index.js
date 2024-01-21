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

// Scheduled function to delete posts and save them to history
exports.scheduledFunction = pubsub.schedule("every 1 minutes")
    .onRun(async (context) => {
      try {
        const now = new Date().getTime();
        console.log("Scheduled function started.");
        const groupChatsRef = admin.database().ref("groupchats");
        const groupChatsSnapshot = await groupChatsRef.once("value");
        console.log("Fetched group chats.");
        const allPromises = [];

        groupChatsSnapshot.forEach((childSnapshot) => {
          const groupChat = childSnapshot.val();
          const firstPostTime = groupChat.firstPostTime;
          const randomDuration = groupChat.randomDuration;

          if (now >= (firstPostTime + randomDuration)) {
            console.log(`Deleting posts for chat ${childSnapshot.key}.`);
            const postsRef = admin.database().ref(`posts/${childSnapshot.key}`);
            const historyRef = admin.database()
                .ref(`history_posts/${childSnapshot.key}`);

            // Move each post to history before deleting
            const movePostsToHistoryPromise = postsRef.once("value").then(
                (postsSnapshot) => {
                  const postHistoryPromises = [];
                  postsSnapshot.forEach((postSnapshot) => {
                    const post = postSnapshot.val();
                    const postId = postSnapshot.key;
                    const historyPost = {...post, deletedAt: new Date().
                        toISOString()};
                    postHistoryPromises.push(historyRef.child(postId).
                        set(historyPost));
                  });
                  return Promise.all(postHistoryPromises).then(() => postsRef.
                      remove());
                });

            allPromises.push(movePostsToHistoryPromise);

            // Update chat and send notifications
            const updateChatPromise = groupChatsRef.child(childSnapshot.key)
                .update({
                  firstPostTime: null,
                  randomDuration: null,
                });

            const participantIds = groupChat.participantIds || [];
            for (const userId of participantIds) {
              const userRef = admin.database().ref(`profile/${userId}`);
              const sendNotificationPromise = userRef.once("value").then(
                  (userSnapshot) => {
                    const userData = userSnapshot.val();
                    if (userData && userData.fcmToken) {
                      console.log(`Sending notification to user ${userId}.`);
                      const message = {
                        token: userData.fcmToken,
                        notification: {
                          title: "keepUp",
                          body: "What are you up to? Time to keepUp",
                        },
                        data: {
                          click_action: "FLUTTER_NOTIFICATION_CLICK",
                          groupChatId: childSnapshot.key,
                        },
                      };
                      return admin.messaging().send(message);
                    } else {
                      console.
                          warn(`User ${userId} does not have an FCM token.`);
                    }
                  });

              allPromises.push(sendNotificationPromise);
            }

            allPromises.push(updateChatPromise);
          }
        });

        await Promise.all(allPromises);
        console.log("Scheduled function completed.");
        return null;
      } catch (error) {
        console.error("Error in scheduledFunction: ", error);
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
          body: bodymessage,
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
