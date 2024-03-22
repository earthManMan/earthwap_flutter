import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CategoryDataSource {
  Future<List<dynamic>> getAllCategoriesOnCallFunction() async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'getAllCategoriesOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call();

      dynamic dataList = response.data['categories'];
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
