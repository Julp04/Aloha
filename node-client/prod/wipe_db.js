var admin = require("firebase-admin");

var serviceAccount = require("./aloha-e64b7-firebase-adminsdk-g6sua-d973f90f08");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://aloha-e64b7.firebaseio.com"
});


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
		.then(wipeDatabase)
		.catch( e => console.log(e.message) );
}else {
	wipeDatabase();
}


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
            admin.database().ref("/people").remove();
        });
    }


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

            admin.storage().ref().remove()
                .then( () => {
                    console.log('Removed all files!');
                    process.exit();
                })
                .catch( e => {
                    console.log(e.message);
                    process.exit();
                })
    }
});

