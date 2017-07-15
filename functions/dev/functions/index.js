
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

exports.reportUser = functions.https.onRequest((request, response) => {
	var uid = request.body.uid;
	var reportingType = request.body.reportingType;

	console.log(request.body);
	console.log(uid);
	console.log(reportingType)


	var updates = {};
	updates["type"] = reportingType;
	admin.database().ref("reporting").child(uid).update(updates);

	response.status(200).send("success");
});

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
			 admin.database().ref("following").child(key).child(uid).remove();
  		}
      console.log("Deleting " + uid);
  		
  		admin.database().ref("scans").child(uid).remove();
  		admin.database().ref("followers").child(uid).remove();
      admin.database().ref("following").child(uid).remove();
      admin.database().ref("users").child(uid).remove();
  });
});

exports.wipeDB = functions.https.onRequest((request, response) => {
	wipeDatabase();
});

function wipeDatabase() {
    let user, users = [];
    let usersRef = admin.database().ref('/users');
   
    usersRef.once('value').then( (snapshot) => {
      snapshot.forEach( (childSnapshot) => {
        user = childSnapshot.val();
        users.push(user);
      });

      console.log(users.length + " users retrieved");

      if (users.length > 0) {
        console.log("Deleting users...");

        let promises = users.map(user => deleteUser(user));

        Promise.all(promises)
          .then(clearDatabase)
          .catch( e => console.log(e.message) );
      }else {
        clearDatabase();
      }
    });
}


   // Wipe the database by removing the root node
function deleteUser(user) {
      return new Promise((resolve, reject) => {
          console.log("Delete user: " + user.username + "");
          admin.auth()
              .deleteUser(user.uid)
              .then( () => {
                  console.log(user.uid + " deleted.");
                  resolve(user);
              })
              .catch( e => {
                  console.log([e.message, user.name, "could not be deleted!"].join(' '));
                  resolve(user);
              });
          admin.database().ref("/users").remove();
          admin.database().ref("/usernames").remove();
      });
  }


 // Wipe the database by removing the root node
function clearDatabase() {
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
}
