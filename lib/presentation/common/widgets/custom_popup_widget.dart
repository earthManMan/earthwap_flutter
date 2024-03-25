import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
