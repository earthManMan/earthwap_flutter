class PasswordModel {
  String _email = "";
  String _password = "";
  String _authKey = "";
  bool _passwordConfirm = false;
  String _newPassword = "";

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  String get authKey => _authKey;

  set authKey(String value) {
    _authKey = value;
  }

  bool get passwordConfirm => _passwordConfirm;

  set passwordConfirm(bool value) {
    _passwordConfirm = value;
  }

  String get newPassword => _newPassword;

  set newPassword(String value) {
    _newPassword = value;
  }

  void clearmodel() {
    _email = "";
    _password = "";
    _authKey = "";
    _passwordConfirm = false;
    _newPassword = "";
  }
}
