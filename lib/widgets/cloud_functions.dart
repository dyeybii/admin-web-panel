import 'package:cloud_functions/cloud_functions.dart';

Future<void> syncDriversAccount(String driverId, Map<String, dynamic> data) async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('syncDriversAccountToFirestore');
  try {
    final result = await callable.call(<String, dynamic>{
      'driverId': driverId,
      'data': data,
    });
    print(result.data);
  } catch (e) {
    print('Error calling function: $e');
  }
}
