
const functions = require('firebase-functions');

var admin = require("firebase-admin");

var serviceAccount = require("./aloha-dev-firebase-adminsdk-k5no5-be14dec376.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://aloha-dev.firebaseio.com",
  storageBucket: "gs://aloha-dev.appspot.com"
});



// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

exports.deleteUser = functions.auth.user().onDelete(event => {
  // Get the uid of the deleted user.

  const user = event.data;
  const uid = user.uid;

  admin.database().ref("following").child(uid).orderByValue().equalTo(true).on('value', function(snapshot) {
      var values = snapshot.val();
  		for(var key in values) {
        if (values.hasOwnProperty(key)) {
          console.log(key) 
        }
			 admin.database().ref("followers").child(key).child(uid).remove();
  		}
      console.log("Deleting " + uid);
  		admin.database().ref("users").child(uid).remove();
  		admin.database().ref("snaps").child(uid).remove();
  		admin.database().ref("followers").child(uid).remove();
      admin.database().ref("following").child(uid).remove();
  });
});

exports.wipeDB = functions.https.onRequest((request, response) => {
	wipeDatabase();
});

   // Wipe the database by removing the root node
    function wipeDatabase() {
        console.log("Wiping database... ");
        admin.database().ref().remove()
            .then( () => {
                console.log('DONE!');
                process.exit();
            })
            .catch( e => {
                console.log(e.message);
                process.exit();
            });

            admin.storage().ref('user').remove()
                .then( () => {
                    console.log('Removed all files!');
                    process.exit();
                })
                .catch( e => {
                    console.log(e.message);
                    process.exit();
                })
    };
