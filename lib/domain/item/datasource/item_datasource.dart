import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_login/app/config/constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'dart:io';

class ItemDatasource {
  // image upload 함수
  Future<dynamic>? uploadImage(UploadType type, String? uid, XFile file) async {
    try {
      String uniqueFileName = "${DateTime.now().millisecondsSinceEpoch}";

      Reference storageReference;
      Reference referenceDirImages;

      switch (type) {
        case UploadType.cover:
          storageReference = FirebaseStorage.instanceFor(
                  bucket: "gs://earthuswap-dev-inference")
              .ref();
          referenceDirImages = storageReference.child('/inference-images/');
          break;
        case UploadType.other:
          storageReference = FirebaseStorage.instanceFor(
                  bucket: "gs://earthuswap-dev.appspot.com")
              .ref();
          referenceDirImages = storageReference.child('/users/${uid!}/');
          break;
        case UploadType.profile:
          storageReference = FirebaseStorage.instanceFor(
                  bucket: "gs://earthuswap-dev.appspot.com")
              .ref();
          referenceDirImages =
              storageReference.child('/users/${uid!}/profile/');
          break;
        case UploadType.community:
          storageReference = FirebaseStorage.instanceFor(
                  bucket: "gs://earthuswap-dev.appspot.com")
              .ref();
          referenceDirImages =
              storageReference.child('/users/${uid!}/community/');
          break;
        default:
          throw Exception("Unsupported UploadType");
      }

      Reference referenceImageToUpload =
          referenceDirImages.child(uniqueFileName);

      final UploadTask uploadTask = referenceImageToUpload.putFile(
          File(file.path),
          SettableMetadata(
            contentType: "image/jpeg",
          ));

      await uploadTask;

      if (uploadTask.snapshot.state == TaskState.success) {
        String url = await referenceImageToUpload.getDownloadURL();
        print('Download URL: $url');

        if (type == UploadType.cover) {
          return {
            'url': url,
            'uniqueFileName': uniqueFileName,
          };
        } else if (type == UploadType.other) {
          return url;
        } else if (type == UploadType.profile) {
          return url;
        } else if (type == UploadType.community) {
          return url;
        }
      } else {
        print('File upload failed');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // 내 물건을 등록하는 API
  Future<String> createItemOnCallFunction(
    String coverImageLocation,
    List<String> otherImagesLocation,
    String categoryId,
    int priceStart,
    int priceEnd,
    String description,
    String ownedBy,
    bool isPremium,
    String mainKeyword,
    String subKeyword,
    String mainColour,
    String subColour,
    String itemLocation,
  ) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'createItemOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'cover_image_location': coverImageLocation,
        'other_images_location': otherImagesLocation,
        'category_id': categoryId,
        'price_start': priceStart,
        'price_end': priceEnd,
        'description': description,
        'owned_by': ownedBy,
        'is_premium': isPremium,
        'main_keyword': mainKeyword,
        'sub_keyword': subKeyword,
        'sub_colour': subColour,
        'main_colour': mainColour,
        'item_location': itemLocation,
      });

      dynamic data = response.data; // 결과 데이터 가져오기
      if (data != null) {
        String id = data['id'].toString();
        return id;
      } else {
        return "";
      }
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return "";
    }
  }

  // 등록된 Cover Image의 info 정보를 가져오는 API
  Future<Map<dynamic, dynamic>?> getImageDataFromDatabase(
      String imageUrl) async {
    final firebaseApp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL: 'https://earthuswap-dev-inference.firebaseio.com/',
    );

    Completer<Map<dynamic, dynamic>?> completer =
        Completer<Map<dynamic, dynamic>?>();

    try {
      DatabaseReference reference = rtdb
          .ref("inference-images")
          .child(imageUrl)
          .child("inference_result");

      final listener = reference.onValue.listen((event) {});

      listener.onData((data) {
        if (data.snapshot.value != null) {
          final val = data.snapshot.value as Map<dynamic, dynamic>;
          completer.complete(val);
          print("data.snapshot.value $val");
          listener.cancel(); // 리스너 취소
        }
      });

      listener.onError((error) {
        print("Error occurred: $error");
        listener.cancel(); // 리스너 취소
      });
      return completer.future;
    } catch (error) {
      print('Error fetching data from the database: $error');
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return completer.future;
    }
  }
}
