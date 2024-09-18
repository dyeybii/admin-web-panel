const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const firestore = admin.firestore();

exports.syncDriversAccountToFirestore = functions.database
    .ref("/driversAccount/{driverId}")
    .onWrite(async (change, context) => {
      const driverId = context.params.driverId;
      const data = change.after.val();

      if (!data) {
        // If data is deleted from Realtime Database, delete it from Firestore
        await firestore.collection("driversAccount").doc(driverId).delete();
        return null;
      }

      // Sync data fields from Realtime Database to Firestore
      const driverData = {
        firstName: data.firstName || "",
        lastName: data.lastName || "",
        phoneNumber: data.phoneNumber || "",
        birthdate: data.birthdate || "",
        bodyNumber: data.bodyNumber || "",
        deviceToken: data.deviceToken || "",
        driverPhoto: data.driver_photos || "",  // Updated field name
        email: data.email || "",
        uid: data.uid || "",
      };

      await firestore.collection("driversAccount").doc(driverId).set(driverData);

      // Set custom claims for the driver
      try {
        await admin.auth().setCustomUserClaims(driverId, {driver: true});
        console.log(`Custom claims set for driver ${driverId}`);
      } catch (error) {
        console.error("Error setting custom claims:", error);
      }

      return null;
    });
