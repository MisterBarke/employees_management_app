// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FormDialog extends StatefulWidget {
  String title;
  String textBtnChild1;
  String textBtnChild2;
  final Widget dialogContent;

  final VoidCallback? onPressed1;
  final VoidCallback? onPressed2;
  FormDialog({
    Key? key,
    required this.title,
    required this.dialogContent,
    required this.textBtnChild1,
    required this.textBtnChild2,
    required this.onPressed1,
    required this.onPressed2,
  }) : super(key: key);

  @override
  State<FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: widget.dialogContent,
      actions: [
        TextButton(
            onPressed: widget.onPressed1, child: Text(widget.textBtnChild1)),
        TextButton(
            onPressed: widget.onPressed2, child: Text(widget.textBtnChild2)),
      ],
    );
  }
}
