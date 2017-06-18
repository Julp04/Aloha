var admin = require("firebase-admin");

var serviceAccount = require("./qnect-dev-firebase-adminsdk-7lc1z-25a92056a9.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://qnect-dev.firebaseio.com"
});




admin.auth().deleteUser("xXYL9dqzGQhw8gTcdmr6nHMVjWl2")
	.then(function(){
		console.log("Succesfully deleted user");
	})
	.catch(function(error) {
		console.log("Error deleteing user: ", error);
	});