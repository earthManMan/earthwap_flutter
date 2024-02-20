class LoginModel {
  String email = '';
  String password = '';
  bool rememberEmail = false;
  bool autoLogin = false;

  void claerModel() {
    email = "";
    password = "";
    rememberEmail = false;
    autoLogin = false;
  }
}
