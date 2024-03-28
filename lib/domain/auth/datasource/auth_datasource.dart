import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthDataSource {
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

  // SMS Code인증을 통한 Phone Auth 체크 
  Future<UserCredential?> checkSMSCode(
      String verificationId, String smsCode) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // 인증코드 확인
      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return result;
    } catch (e) {
      // 오류 처리
      print('Error during SMS code verification: $e');
      return null;
    }
  }

  // Phone으로 SMS 코드 보내기
  Future<void> verifyPhoneNumber(
      String phoneNumber, Function(String, int?) callback) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          // 인증이 자동으로 완료되었을 때 실행되는 코드
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification Failed: ${e.message}');
        },
        codeSent: callback,
        codeAutoRetrievalTimeout: (String verificationId) {
          // 자동으로 검색 시간이 초과되었을 때 실행되는 코드
        },
      );
    } catch (e) {
      print('Error during phone number verification: $e');
    }
  }

  // phone으로 user 생성 
  Future<bool> registerUserWithPhone(
      String uid, String phone, String device_token) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'registerUserWithPhoneOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'phone': phone,
        'device_token': device_token,
        'nickname': "",
      });

      print(response.data.toString());
      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // Phone Auth 삭제 
  Future<bool> deleteUserFromPhnoeAuth(String uid, String phone) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'deleteUserFromAuthOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );

      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'phone': phone,
      });

      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  // phone auth로 로그인 하면 Custom Token 부여받음
  Future<String> loginwithPhone(String uid, String phoneNumber) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable(
        'loginWithPhoneOnCallFunction',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      );
      final response = await callable.call(<String, dynamic>{
        'uid': uid,
        'phone': phoneNumber,
      });
      String token = response.data;
      print(token);
      return token;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return "";
    }
  }

  // 부여받은 Token으로 로그인 
  Future<UserCredential?> loginWithToken(String token) async {
    try {
      final credential =
          await FirebaseAuth.instance.signInWithCustomToken(token);
      return credential; // 로그인에 성공한 경우 UserCredential 반환
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return null; // 에러가 발생한 경우 null 반환
    }
  }
}
