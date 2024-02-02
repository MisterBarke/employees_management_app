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

class AlertPopup extends StatefulWidget {
  final Widget alertContent;
  String title;
  AlertPopup({super.key, required this.alertContent, required this.title});

  @override
  State<AlertPopup> createState() => _AlertPopupState();
}

class _AlertPopupState extends State<AlertPopup> {
  void initState() {
    super.initState();
    // Appeler la fonction pour supprimer l'alerte après 3 secondes
    _removeAfterDelay();
  }

  // Fonction pour supprimer l'alerte après 3 secondes
  void _removeAfterDelay() async {
    await Future.delayed(Duration(seconds: 3));
    // Vérifier si le widget est toujours monté avant de le supprimer
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 8,
        left: 20,
        child: AlertDialog(
          title: Text(widget.title),
          content: widget.alertContent,
        ));
  }
}
