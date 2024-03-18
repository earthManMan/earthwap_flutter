enum LoginStatus {
  cretedtoken, // loginwithPhone 실패 (Token 발생 x)
  deleted, // Phone User 삭제 실패 
  logined, // loginWithToken 실패 
  success,
}

class LoginModel {
  String email = '';
  String password = '';
  bool rememberEmail = false;
  bool autoLogin = false;
  String phone = '';
  String smscode = '';
  String verificationId = '';
  String uid = '';
  String loginToken = "";
  
  void claerModel() {
    email = "";
    password = "";
    phone = '';
    smscode = '';
    verificationId = '';
    uid = '';
    loginToken = "";

    rememberEmail = false;
    autoLogin = false;
  }
}
