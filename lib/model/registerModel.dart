enum RegistrationStatus {
  registered, // user 생성 실패 
  deleted, // Phone User 삭제 실패 
  success,
}

class RegisterModel {
  String _university = "";
  String _domain = "";
  String _email = "";
  String _password = "";
  String _passwordConfirm = "";
  String _authKey = "";
  String _verificationId = "";
  String _authKeyConfirm = "";
  String _phoneNumber = "";
  String _uid = "";

  bool _authCode = false;
  List<Map<String, String>> _universityList = [];

  // Domain
  List<Map<String, String>> get universityList => _universityList;
  set universityList(List<Map<String, String>> value) {
    _universityList = value;
  }

  // University
  String get university => _university;
  set university(String value) {
    _university = value;
  }

  // Domain
  String get domain => _domain;
  set domain(String value) {
    _domain = value;
  }

  // Email
  String get email => _email;
  set email(String value) {
    _email = value;
  }

  // Password
  String get password => _password;
  set password(String value) {
    _password = value;
  }

  // Password Confirmation
  String get passwordConfirm => _passwordConfirm;
  set passwordConfirm(String value) {
    _passwordConfirm = value;
  }
  String get verificationId => _verificationId;
  set verificationId(String value) {
    _verificationId = value;
  }

  // Auth Key
  String get authKey => _authKey;
  set authKey(String value) {
    _authKey = value;
  }

  // Auth Key Confirmation
  String get authKeyConfirm => _authKeyConfirm;
  set authKeyConfirm(String value) {
    _authKeyConfirm = value;
  }

  // Auth Code
  bool get authCode => _authCode;
  set authCode(bool value) {
    _authCode = value;
  }

  String get phone => _phoneNumber;
  set phone(String value) {
    _phoneNumber = value;
  }

  String get uid => _uid;
  set uid(String value) {
    _uid = value;
  }

  void clearModel() {
    _university = "";
    _domain = "";
    _email = "";
    _password = "";
    _passwordConfirm = "";
    _verificationId = "";
    _authKey = "";
    _authKeyConfirm = "";
    _authCode = false;
    phone = "";
    uid = "";

    _universityList = [];
  }
}
