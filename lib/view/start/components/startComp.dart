import 'package:flutter/material.dart';
import 'package:firebase_login/components/theme.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.05,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          const Text('이미 계정이 있으신가요? 바로',
              style: TextStyle(color: ColorStyles.text)),
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TextButton(
                onPressed: () {
                  // Login Page로 이동
                  Navigator.of(context).pushNamed('/login');
                },
                child: const Text('로그인하세요',
                    style: TextStyle(
                        fontFamily: "SUIT",
                        fontWeight: FontWeight.bold,
                        color: ColorStyles.primary))),
          )
        ]));
  }
}
