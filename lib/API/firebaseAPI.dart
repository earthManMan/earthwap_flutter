import 'dart:io';
import 'package:firebase_login/viewModel/sellViewModel.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum UploadType {
  cover,
  other,
  community,
  profile,
}

enum EmailType {
  Verification,
  ChangePassword,
}

class FirebaseAPI {
  Color hexStringToColor(String hexColor) {
    if (hexColor == 'null') return Colors.red;
    // HEX 색상 코드에서 # 기호를 제거하고 앞에 0xFF를 추가합니다.
    final hexCode = hexColor.replaceAll('#', '0xFF');

    // int.tryParse를 사용하여 HEX 코드를 정수로 변환하고 오류를 처리합니다.
    final intColor = int.tryParse(hexCode);

    if (intColor != null) {
      // 정상적으로 정수로 변환된 경우 Color 객체로 반환합니다.
      return Color(intColor);
    } else {
      // 오류 처리 또는 기본 값 설정 등을 수행할 수 있습니다.
      // 예를 들어, 빨간색을 기본 값으로 설정:
      return Colors.red;
    }
  }

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<UserCredential?> loginWithEmail(String email, String Password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: Password);
      return credential; // 로그인에 성공한 경우 UserCredential 반환
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return null; // 에러가 발생한 경우 null 반환
    }
  }

  // Logout API
  Future<void> logout() async {
    try {
      print('sign out complete');
      return await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('sign out failed');
      print(e.toString());
      return;
    }
  }

  // Logout API
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // 이메일을 통해 비밀번호 재설정 링크가 전송됨
    } catch (e) {
      // 오류 처리
      print("비밀번호 재설정 오류: $e");
    }
  }

  Future<bool> addDeviceTokenOnCallFunction(
      String uid, String deviceToken) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'addDeviceTokenOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'device_token': deviceToken,
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  Future<bool> removeDeviceTokenOnCallFunction(
      String uid, String deviceToken) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'removeDeviceTokenOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'device_token': deviceToken,
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // User 정보를 등록 하는 API
  Future<bool> registerUserOnCallFunction(
      String email, String password, bool verified, String university) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'registerUserOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );
      callable.call(<String, dynamic>{
        'email': email,
        'password': password,
        'email_verified': true,
        'university': university,
        'device_token': "test",
        'nickname': "닉네임을 지정해주세요.",
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // User 정보 가져오는 API
  Future<dynamic> getUserInfoOnCallFunction(String uid) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'getUserInfoOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{'uid': uid});

      dynamic data = response.data; // 결과 데이터 가져오기
      return data;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return null;
    }
  }

  // 대학교 List 정보를 가져오는 API
  Future<List<Map<String, String>>> getAllUniversitiesOnCallFunction() async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'getAllUniversitiesOnCallFunction',
        options: HttpsCallableOptions(
          limitedUseAppCheckToken: true,
          timeout: const Duration(seconds: 20),
        ),
      );
      final response = await callable.call();
      List<Map<String, String>> data = [];

      for (dynamic item in response.data['universities']) {
        String id = item["id"];
        String domain = item["domain"];
        data.add({"id": id, "domain": domain});
      }
      return data;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return [];
    }
  }

  // Email로 인증 코드 보내는 API
  Future<String> sendEmailVerification(String emaiil) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'sendVerificationEmailOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'email': emaiil,
      });
      String keyString = response.data;
      return keyString;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);

      return "";
    }
  }

  // Email로 인증 코드 보내는 API
  Future<String> sendEmailOnCallFunction(EmailType Type, String emaiil) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'sendEmailOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );
      String type = "";
      if (Type == EmailType.Verification) {
        type = "Verification";
      } else {
        type = "ChangePassword";
      }
      final response = await callable.call(<String, dynamic>{
        'email': emaiil,
        'email_type': type,
      });
      String keyString = response.data;
      return keyString;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);

      return "";
    }
  }

  // 대학교 도메인 검증 API
  Future<bool> verifyUniversityDomainOnCallFunction(String domain) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'verifyUniversityDomainOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'domain': domain,
      });
      dynamic data = response.data; // 결과 데이터 가져오기
      bool valid = data["is_uni"]; // "items" 키에 해당하는 값을 추출

      return valid;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  Future<String> getUniversityInfoOnCallFunction(String uni) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'getUniversityInfoOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );
      final response = await callable.call(<String, dynamic>{
        'id': uni,
      });

      dynamic dy = response.data['university'];
      String str = dy['communities'].toString();
      print(str);
      // 대괄호 "["와 "]"를 제거하고 공백을 제거한 문자열을 얻습니다.
      str = str.replaceAll('[', '').replaceAll(']', '').trim();
      print(str);
      return str;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return "";
    }
  }

  // 특정 item ID와 매치되는 itemList 가져오는 API
  Future<dynamic> readRecommendedItemsOnCallFunction(
      String id, List<String> category, List<String> exclude) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'readRecommendedItemsOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'id': id,
        'interest_categories': category,
        'limit': 50,
        'exclude_items': exclude,
      });
      return response.data['items'];
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return null;
    }
  }

  // Item card info를 가져오는 API
  Future<dynamic> readItemInfoOnCallFunction(String id) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'readItemInfoOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'id': id,
      });
      return response;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return null;
    }
  }

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

  // User Profile Image 업데이트 함수
  Future<bool> updateProfilePictureOnCallFunction(
      String uid, String url) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'updateProfilePictureOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'profile_picture_url': url,
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // User 자기소개 업데이트 함수
  Future<bool> updateDescriptionOnCallFunction(
      String uid, String description) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'updateDescriptionOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'description': description,
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // user Nickname 업데이트 함수
  Future<bool> updateNicknameOnCallFunction(String uid, String nickName) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'updateNicknameOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'nickname': nickName,
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 보여 준 Item Like하기
  Future<bool> likeItemOnCallFunction(
      String uid, String ownerID, String itemID) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'likeItemOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'user_id': uid,
        'my_item_id': ownerID,
        'liked_item_id': itemID,
      });

      print("$uid : $ownerID like $itemID");

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 보여 준 Item DisLike하기
  Future<bool> dislikeItemOnCallFunction(
      String uid, String ownerID, String itemID) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'dislikeItemOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'user_id': uid,
        'my_item_id': ownerID,
        'liked_item_id': itemID,
      });

      print("$uid : $ownerID like $itemID");

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 커뮤니티 게시글 가져오는 API
  Future<List<dynamic>> listContentsOnCallFunction(
      DateTime since, DateTime till, String communityId) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'listContentsOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'community_id': communityId,
        //'since': oneMonthAgo.millisecondsSinceEpoch,
        //'till': now.millisecondsSinceEpoch,
        'since': since.millisecondsSinceEpoch,
        'till': till.millisecondsSinceEpoch,
        'index_since': "0",
        'limit': "30"
      });

      dynamic map = response.data['contents'];
      List<dynamic> dataList = map['contents'] as List<dynamic>;

      return dataList;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return List.empty();
    }
  }

  // 내 물건을 등록하는 API
  Future<String> createContentOnCallFunction(String uid, String communityId,
      String body, String title, String images) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'createContentOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );
      // Todo : community_id 가져오는 방법이 필요함.title
      final response = await callable.call(<String, dynamic>{
        'user_id': uid,
        'community_id': communityId,
        'body': body,
        'title': title,
        'images': images,
      });

      String str = response.data['id'].toString(); // 결과 데이터 가져오기
      print(str);
      return str;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return "";
    }
  }

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

  // 커뮤니티 게시글 가져오는 API
  Future<dynamic> readContentOnCallFunction(
      String communityId, String contentId) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'readContentOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );
      DateTime now = DateTime.now();
      DateTime oneMonthAgo =
          now.subtract(const Duration(days: 30)); // 30일 전으로 설정

      final response = await callable.call(<String, dynamic>{
        'community_id': communityId,
        'content_id': contentId,
      });

      dynamic dataList = response.data['content'];

      return dataList;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return List.empty();
    }
  }

  // 등록된 Cover Image의 info 정보를 가져오는 API
  Future<bool> getImageDataFromDatabase(
      String imageUrl, SellViewModel viewmodel) async {
    final firebaseApp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
        app: firebaseApp,
        databaseURL: 'https://earthuswap-dev-inference.firebaseio.com/');

    Completer<bool> completer = Completer<bool>();

    try {
      DatabaseReference reference = rtdb
          .ref("inference-images")
          .child(imageUrl)
          .child("inference_result");

      reference.onValue.listen((event) {
        if (completer.isCompleted) {
          return;
        }

        if (event.snapshot.value == null) {
          print("Null");
        } else {
          Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          print(data);

          //TODO : AI 추가 되어야 함.
          //viewmodel.model.setcategory(data["category"].toString());
          //viewmodel.model.setprice_start(data["priceStart"]);
          //viewmodel.model.setprice_end(data["priceEnd"]);
          viewmodel.model
              .setmain_color(hexStringToColor(data["main_color"].toString()));
          viewmodel.model
              .setsub_color(hexStringToColor(data["sub_color"].toString()));

          completer.complete(true);
        }
      });

      return completer.future;
    } catch (error) {
      print('Error fetching data from the database: $error');
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      return completer.future;
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

  // Match info 가져오기
  Future<dynamic> getMatchInfoOnCallFunction(String id, String ownerId) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'getMatchInfoOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'id': id,
        'owner_id': ownerId,
      });

      return response;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return null;
    }
  }

  // chat info 가져오기
  Future<dynamic> readChatOnCallFunction(String chatid, String uid) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-southeast1')
          .httpsCallable(
        'readChatOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'chat_id': chatid,
        'uid': uid,
      });

      return response;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return null;
    }
  }

  // 채팅방 제거 하는 API
  Future<bool> leaveChatOnCallFunction(String chatId, String uid) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'leaveChatOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response =
          await callable.call(<String, dynamic>{'chat_id': chatId, 'uid': uid});

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 신고하기
  Future<bool> reportOnCallFunction(
      String uid, String reportId, String report) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'reportOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'report_uid': reportId,
        'report_type': {'type': "spam", 'description': "ssssss"},
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 팔로우 하는 API
  Future<bool> followUserOnCallFunction(
      String onwerUid, String followUid) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'followUserOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable
          .call(<String, dynamic>{'uid': onwerUid, 'follow_uid': followUid});

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 언팔로우 하는 API
  Future<bool> unfollowUserOnCallFunction(
      String onwerUid, String followUid) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'unfollowUserOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable
          .call(<String, dynamic>{'uid': onwerUid, 'unfollow_uid': followUid});

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 게시글 좋아요 하는 API
  Future<bool> likeContentOnCallFunction(
      String userId, String communityId, String contentId) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'likeContentOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'user_id': userId,
        'community_id': communityId,
        'content_id': contentId
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 채팅 message 보내는 API
  Future<bool> sendMessageOnCallFunction(
      String chatId, String Message, String From, String to) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-southeast1')
          .httpsCallable(
        'sendMessageOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'chat_id': chatId,
        'msg': Message,
        'from': From,
        'to': to
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 내가 등록한 Item 삭제하기
  Future<bool> deleteItemOnCallFunction(String uid, String itemId) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'deleteItemOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'id': itemId,
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 내가 등록한 Item 업데이트
  Future<bool> updateItemInfoOnCallFunction(
      String uid, String itemId, Map<String, dynamic> update) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'updateItemInfoOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable
          .call(<String, dynamic>{'uid': uid, 'id': itemId, 'update': update});

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 내가 등록한 Content 업데이트
  Future<bool> updateContentOnCallFunction(String uid, String communityId,
      String contentId, Map<String, dynamic> update) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'updateContentOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'user_id': uid,
        'community_id': communityId,
        'content_id': contentId,
        'update': update
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 내가 등록한 게시글 삭제하기
  Future<bool> deleteContentOnCallFunction(
      String uid, String communityId, String contentId) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'deleteContentOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'user_id': uid,
        'community_id': communityId,
        'content_id': contentId,
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 결제 정보 가져오기
  Future<bool> getPaymentsOnCallFunction(String orderId) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'getPaymentsOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'order_id': orderId,
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // view 업 카운트
  Future<bool> incrementViewsOnCallFunction(
      String communityId, String contentId) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'incrementViewsOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'community_id': communityId,
        'content_id': contentId,
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  Future<bool> getPaymentOnCallFunction(String uid, String orderID) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'getPaymentsOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'order_id': orderID,
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  Future<bool> createPickupOnCallFunction(
      String uid,
      String orderID,
      String address,
      String addressDetail,
      String door,
      String contents,
      String date,
      String phoneNumber) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'createPickupOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'payment_id': orderID,
        'base_address': address,
        'detail_address': addressDetail,
        'door_password': door,
        'contents': contents,
        'date': date,
        'phone_number': phoneNumber,
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  Future<dynamic> readPickupOnCallFunction(String uid, String pickup) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'readPickupOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'pickup_id': pickup,
      });

      dynamic data = response.data; // 결과 데이터 가져오기

      return data;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return null;
    }
  }

  Future<String> writeCommentOnCallFunction(String uid, String comunityId,
      String contentId, String commentId, String body) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'writeCommentOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );
      if (commentId.isEmpty) {
        final response = await callable.call(<String, dynamic>{
          'user_id': uid,
          'community_id': comunityId,
          'content_id': contentId,
          'body': body,
        });

        dynamic data = response.data; // 결과 데이터 가져오기

        return data['id'];
      } else {
        final response = await callable.call(<String, dynamic>{
          'user_id': uid,
          'community_id': comunityId,
          'content_id': contentId,
          'comment_id': commentId,
          'body': body,
        });

        dynamic data = response.data; // 결과 데이터 가져오기

        return data['id'];
      }
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return "";
    }
  }

  Future<bool> deleteCommentOnCallFunction(String uid, String communityId,
      String contentId, String commentId, String secondLevelCommentId) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'deleteCommentOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'user_id': uid,
        'community_id': communityId,
        'content_id': contentId,
        'comment_id': commentId,
        'second_level_comment_id': secondLevelCommentId,
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 탈퇴하기
  Future<bool> deregisterUserOnCallFunction(String uid) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'deregisterUserOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{'uid': uid});

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // 탈퇴하기
  Future<bool> cancelPaymentOnCallFunction(
      String uid, String orderId, String cancelReason) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'cancelPaymentOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'order_id': orderId,
        'cancel_reason': cancelReason
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }
}
