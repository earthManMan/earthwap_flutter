import 'package:firebase_login/presentation/sell/sellViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class KeyWordPopup extends Dialog {
  const KeyWordPopup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ViewModel = Provider.of<SellViewModel>(context, listen: false);

    // TODO: implement build
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 8, 8, 8).withOpacity(0.1),
      insetPadding: EdgeInsets.zero,
      child: AlertDialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: const Color.fromARGB(255, 8, 8, 8).withOpacity(0.1),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100.0),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 20, 20, 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  animationDuration: Duration.zero,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: const Text('TIP', style: TextStyle(color: Colors.white)),
                onPressed: () {},
              ),
              const SizedBox(height: 24.0),
              Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Text(
                    ViewModel.model.getKeywordDescription().toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: ColorStyles.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          color: Color.fromARGB(255, 240, 244, 248),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextButton(
                      child: const Text('오늘 그만 보기',
                          style: TextStyle(
                            color: Color.fromARGB(255, 240, 244, 248),
                          )),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('isKeywordPopup', true);

                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAlertDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool? visibleConfirm;
  final bool? visibleCancel;

  CustomAlertDialog({
    Key? key,
    required this.message,
    this.onConfirm,
    this.onCancel,
    this.visibleConfirm = true,
    this.visibleCancel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformAlertDialog(
      actions: _buildActions(context),
      title: Text(
        message,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    List<Widget> actions = [];
    if (visibleConfirm!) {
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onConfirm != null) {
              onConfirm!();
            }
          },
          child: Text(
            '확인',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    if (visibleCancel!) {
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onCancel != null) {
              onCancel!();
            }
          },
          child: Text(
            '취소',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return actions;
  }
}
