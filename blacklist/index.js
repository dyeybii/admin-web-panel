const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.blockUser = functions.https.onCall(async (data, context) => {
  const { uid, disable } = data;

  if (!uid || typeof disable !== 'boolean') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'The function must be called with a valid UID and disable value.'
    );
  }

  try {
    // Update user in Firebase Authentication
    await admin.auth().updateUser(uid, { disabled: disable });

    return { message: disable ? 'User blocked successfully' : 'User unblocked successfully' };
  } catch (error) {
    console.error('Error updating user:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Unable to update user',
      error.message
    );
  }
});
