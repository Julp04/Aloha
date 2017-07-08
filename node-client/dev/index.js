const functions = require('firebase-functions');

var admin = require("firebase-admin");

var serviceAccount = require("./qnect-dev-firebase-adminsdk-7lc1z-25a92056a9.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://qnect-dev.firebaseio.com"
});


exports.removeUserFromDatabase = functions.auth.user().onDelete(function(event) {
  // Get the uid of the deleted user.
  var uid = event.data.uid;

  // Remove the user from your Realtime Database's /users node.
  return admin.database().ref("/users/" + uid).remove();
});