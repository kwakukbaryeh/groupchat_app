const {onRequest} = require("firebase-functions/v2/https");
const {database, pubsub} = require("firebase-functions");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

admin.initializeApp();

exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

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
