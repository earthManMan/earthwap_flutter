class AuthModel {
  bool autoLogin;
  String phone;
  String smsCode;
  String verificationId;
  String uid;
  String phone_uid;

  String token;
  String device_token;

  AuthModel({
    this.autoLogin = false,
    this.phone = '',
    this.phone_uid = '',
    this.smsCode = '',
    this.verificationId = '',
    this.uid = '',
    this.token = '',
    this.device_token = '',
  });
}
