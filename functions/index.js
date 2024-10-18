const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.setDriverIdOnCreate = functions.firestore
    .document('driversAccount/{driverId}')
    .onCreate(async (snapshot, context) => {
        const driverId = context.params.driverId;
        const driverData = snapshot.data();

        if (!driverData.driverId || driverData.driverId === "") {
            await admin.firestore().collection('driversAccount').doc(driverId).update({
                driverId: driverId
            });
        }
    });
