import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';

class LocationDataSource {
  Future<List<dynamic>> getAllLocationsOnCallFunction() async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'getAllLocationsOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call();

      dynamic dataList = response.data['locations'];
      return dataList;
    } on FirebaseFunctionsException catch (error) {
      print('Firebase Functions Exception:');
      print('Code: ${error.code}');
      print('Details: ${error.details}');
      print('Message: ${error.message}');
      return <dynamic>[]; // 또는 return [];
    }
  }
}






