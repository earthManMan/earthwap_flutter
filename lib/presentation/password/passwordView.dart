import 'package:flutter/material.dart';
import 'package:firebase_login/presentation/password/passwordViewModel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:firebase_login/presentation/components/popup_widget.dart';
import 'package:firebase_login/presentation/common/widgets/custom_popup_widget.dart';

class PasswordView extends StatefulWidget {
  const PasswordView({super.key});

  @override
  _PasswordViewState createState() => _PasswordViewState();
}

class _PasswordViewState extends State<PasswordView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController authCodeController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  bool emailVerified = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<PasswordViewModel>(
      builder: (context, passwordviewmodel, child) {
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
            resizeToAvoidBottomInset: false,

            body: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    readOnly: emailVerified,
                    enableInteractiveSelection: true,
                    onChanged: (value) {
                      setState(() {
                        passwordviewmodel.model.email = value;
                      });
                    },
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "이메일 주소",
                      suffixIcon:
                          emailController.text.isNotEmpty && !emailVerified
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      emailController.clear();
                                    });
                                  },
                                )
                              : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!emailVerified)
                    ElevatedButton(
                        onPressed: emailController.text.isNotEmpty
                            ? () async {
                                passwordviewmodel
                                    .resetPassword()
                                    .then((value) => {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CustomAlertDialog(
                                                message: "이메일을 통해 비밀번호를 변경해주세요",
                                                onConfirm: () => {
                                                  Navigator.of(context).pop()
                                                },
                                                visibleCancel: false,
                                                visibleConfirm: true,
                                              );
                                            },
                                          )
                                        });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorStyles.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 20,
                          height: 50,
                          child: const Center(
                              child: Text(
                            "비밀번호 변경",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        )),
                  /*if (emailVerified)
                    TextField(
                      enableInteractiveSelection: true,
                      controller: authCodeController,
                      decoration: const InputDecoration(labelText: "인증 코드"),
                    ),*/
                  /*if (emailVerified)
                    TextField(
                      enableInteractiveSelection: true,
                      controller: newPasswordController,
                      decoration: const InputDecoration(labelText: "새로운 비밀번호"),
                    ),*/
                  if (emailVerified)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorStyles.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {
                        passwordviewmodel.resetPassword();
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 20,
                        height: 50,
                        child: const Center(
                          child: Text(
                            "비밀번호 변경",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
