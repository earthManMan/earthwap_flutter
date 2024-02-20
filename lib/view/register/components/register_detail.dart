import 'package:flutter/material.dart';
import 'package:firebase_login/components/theme.dart';
import 'package:firebase_login/viewModel/registerViewModel.dart';

class AuthEmailLayout extends StatefulWidget {
  final RegisterViewModel _viewModel;

  const AuthEmailLayout({required RegisterViewModel viewmodel, super.key})
      : _viewModel = viewmodel;

  @override
  State<AuthEmailLayout> createState() => _AuthEmailLayoutState();
}

class _AuthEmailLayoutState extends State<AuthEmailLayout> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  bool isCodeInput = false;

  bool _isValidEmail() {
    return _emailTextController.text.length >= 4;
  }

  bool _isValidPassword() {
    return _passwordTextController.text.length >= 4;
  }

  Future<void> emailSendButtonPressed(BuildContext context) async {
    try {
      final re = await widget._viewModel.EmailSendButtonPressed();

      if (re) {
        setState(() {
          isCodeInput = true;
        });
      } else {
        setState(() {
          isCodeInput = false;
        });
      }
    } catch (error) {
      setState(() {
        isCodeInput = false;
        print("sendEmailVerification failed with error: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/components/background.png'),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Color.fromARGB(255, 240, 244, 248),
          ),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget._viewModel.setAuthCode(false);
              widget._viewModel.setEmail("");
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    "재학중인 대학교의\n이메일을 입력해주세요!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: EmailInput(
                  viewmodel: widget._viewModel,
                  text: _emailTextController,
                ),
              ),
              if (isCodeInput)
                AuthKeyInput(
                  viewmodel: widget._viewModel,
                  text: _passwordTextController,
                ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: isCodeInput
                    ? MediaQuery.of(context).size.height * 0.4
                    : MediaQuery.of(context).size.height * 0.5,
                alignment: Alignment.bottomCenter,
                child: isCodeInput
                    ? AuthButton(
                        viewmodel: widget._viewModel,
                        isEnabled: _isValidPassword(),
                      )
                    : EmailSendButton(
                        isEnabled: _isValidEmail(),
                        onPressed: () => emailSendButtonPressed(context),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailSendButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final bool isEnabled;

  const EmailSendButton({
    super.key,
    required this.onPressed,
    required this.isEnabled,
  });

  @override
  _EmailSendButtonState createState() => _EmailSendButtonState();
}

class _EmailSendButtonState extends State<EmailSendButton> {
  bool isSending = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.08,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorStyles.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: widget.isEnabled ? _onPressed : null,
        child: isSending
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 255, 255, 255),
                ),
              )
            : const Text(
                '인증 메일 받기',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
      ),
    );
  }

  Future<void> _onPressed() async {
    setState(() {
      isSending = true;
    });

    try {
      await widget.onPressed();
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }
}

class EmailInput extends StatefulWidget {
  late final RegisterViewModel _viewmodel;
  late TextEditingController textController;

  EmailInput(
      {required RegisterViewModel viewmodel,
      required TextEditingController text,
      super.key})
      : _viewmodel = viewmodel,
        textController = text;

  @override
  _EmailInputState createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  late bool isvalidDomain;

  @override
  void initState() {
    super.initState();
    isvalidDomain = false;
  }

  String _extractDomainFromEmail(String email) {
    // "@" 문자를 기준으로 문자열을 분할하고, "@" 이후의 부분을 반환합니다.
    List<String> parts = email.split("@");
    if (parts.length == 2) {
      return parts[1];
    } else {
      return ""; // "@" 문자가 없거나 여러 개인 경우 빈 문자열을 반환합니다.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextField(
        enableInteractiveSelection: true,
        onChanged: (email) {
          String domain = _extractDomainFromEmail(email);
          widget._viewmodel.setDomain(domain);
          if (domain.isNotEmpty) {
            widget._viewmodel.isValidDomain(domain).then((value) => {
                  isvalidDomain = value,
                });
          }
          widget._viewmodel.setEmail(email);
        },
        controller:
            widget.textController, // TextEditingController를 사용하여 입력된 텍스트 관리
        enabled: !widget._viewmodel.model.authCode,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelStyle: const TextStyle(
              fontFamily: "SUIT", fontSize: 14, color: ColorStyles.primary),
          errorStyle: const TextStyle(
              fontFamily: "SUIT",
              fontSize: 14,
              color: Color.fromARGB(255, 255, 0, 77)),
          // errorText: isvalidDomain ? null : '대학교 이메일을 체크하세요',
          labelText: '대학교 이메일',
          helperText: '',
          suffixIcon: widget._viewmodel.model.authCode
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear), // 지우기 아이콘
                  onPressed: () {
                    widget.textController.clear(); // 입력된 텍스트 지우기
                  },
                ),
        ),
      ),
    );
  }
}

class AuthKeyInput extends StatelessWidget {
  final TextEditingController _textcontroller;
  final RegisterViewModel _viewmodel;

  const AuthKeyInput(
      {required RegisterViewModel viewmodel,
      required TextEditingController text,
      super.key})
      : _viewmodel = viewmodel,
        _textcontroller = text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextField(
        enableInteractiveSelection: true,
        controller: _textcontroller, // TextEditingController를 사용하여 입력된 텍스트 관리
        obscureText: true,
        onChanged: (inputKey) {
          _viewmodel.setAuthKeyConfirm(inputKey);
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: '인증번호',
          helperText: '',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear), // 지우기 아이콘
            onPressed: () {
              _textcontroller.clear(); // 입력된 텍스트 지우기
            },
          ),
          errorText: _viewmodel.model.authKey != _viewmodel.model.authKeyConfirm
              ? '인증번호가 일치하지 않습니다.'
              : null,
        ),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  final bool _isEnabled;
  final RegisterViewModel _viewmodel;

  const AuthButton(
      {required RegisterViewModel viewmodel,
      required bool isEnabled,
      super.key})
      : _viewmodel = viewmodel,
        _isEnabled = isEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.08,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorStyles.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: !_isEnabled
            ? null
            : () async {
                if (_viewmodel.model.authKeyConfirm ==
                    _viewmodel.model.authKey) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PassWordLayout(viewmodel: _viewmodel),
                    ),
                  );
                }
              },
        child: const Text(
          '인증 하기',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
    );
  }
}

class PassWordLayout extends StatefulWidget {
  final RegisterViewModel _viewmodel;

  const PassWordLayout({required RegisterViewModel viewmodel, super.key})
      : _viewmodel = viewmodel;

  @override
  State<PassWordLayout> createState() => _PassWordLayoutState();
}

class _PassWordLayoutState extends State<PassWordLayout> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/components/background.png'), // 배경 이미지
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Color.fromARGB(255, 240, 244, 248), //색변경
          ),
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent, // 배경색을 투명으로 설정
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                    child: Text(
                  "비밀번호를\n입력해주세요!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color.fromARGB(255, 255, 255, 255)),
                )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: PasswordInput(viewmodel: widget._viewmodel),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: PasswordConfirmInput(viewmodel: widget._viewmodel),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.3,
                alignment: Alignment.bottomCenter,
                child: RegisterButton(
                    viewmodel: widget._viewmodel,
                    isEnabled: widget._viewmodel.model.password.isNotEmpty &&
                        widget._viewmodel.model.password ==
                            widget._viewmodel.model.passwordConfirm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordInput extends StatefulWidget {
  final RegisterViewModel _viewmodel;

  const PasswordInput({required RegisterViewModel viewmodel, super.key})
      : _viewmodel = viewmodel;
  @override
  _PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextField(
        enableInteractiveSelection: true,
        controller: _textEditingController,
        onChanged: (password) {
          widget._viewmodel.setPassword(password);
        },
        obscureText: true,
        decoration: InputDecoration(
          labelText: '비밀번호',
          helperText: '',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear), // 지우기 아이콘
            onPressed: () {
              setState(() {
                _textEditingController.clear(); // 입력된 텍스트 지우기
              });
            },
          ),
        ),
      ),
    );
  }
}

class PasswordConfirmInput extends StatefulWidget {
  final RegisterViewModel _viewmodel;

  const PasswordConfirmInput({required RegisterViewModel viewmodel, super.key})
      : _viewmodel = viewmodel;

  @override
  _PasswordConfirmInputState createState() => _PasswordConfirmInputState();
}

class _PasswordConfirmInputState extends State<PasswordConfirmInput> {
  final TextEditingController _textEditingController = TextEditingController();
  bool showError = false;
  bool isConfirmed = false; // Track if the password confirmation is complete

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _checkPasswordConfirmation(BuildContext context, String password) {
    setState(() {
      showError = password != widget._viewmodel.model.password;
      isConfirmed = !showError; // Update isConfirmed based on showError
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextField(
        enableInteractiveSelection: true,
        controller: _textEditingController,
        onChanged: (password) {
          widget._viewmodel.setPasswordConfirm(password);
          setState(() {
            showError = false;
            isConfirmed = false; // Reset isConfirmed when the password changes
          });
        },
        onSubmitted: (password) {
          _checkPasswordConfirmation(context, password);
        },
        obscureText: true,
        decoration: InputDecoration(
          labelText: '비밀번호 확인',
          helperText: '',
          errorText: showError ? '비밀번호가 일치하지 않습니다.' : null,
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear), // 지우기 아이콘
            onPressed: () {
              _textEditingController.clear(); // 입력된 텍스트 지우기
            },
          ),
        ),
      ),
    );
  }
}

class RegisterButton extends StatelessWidget {
  final bool isEnabled;
  final RegisterViewModel _viewmodel;

  const RegisterButton(
      {required RegisterViewModel viewmodel, isEnabled, super.key})
      : _viewmodel = viewmodel,
        isEnabled = isEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.08,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorStyles.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: !isEnabled
            ? null
            : () async {
                await _viewmodel.registerUser().then((Status) {
                  if (Status == true) {
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {}
                });
              },
        child: const Text(
          '계정 생성하기',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
    );
  }
}
