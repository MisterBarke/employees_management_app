import 'package:flutter/material.dart';
import 'package:managing_app/widgets/dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactAppLauncher extends StatelessWidget {
  final String phoneNumberUrl;
  const ContactAppLauncher({super.key, required this.phoneNumberUrl});

  Future<dynamic> launchPhoneCall() async {
    String telUri = 'tel:$phoneNumberUrl';
    if (await canLaunchUrl(telUri as Uri)) {
      await launchUrl(telUri as Uri);
    } else {
      throw "Impossible de contacter ce numéro";
    }
  }

  Future<dynamic> launchWhatsapp() async {
    String whatsappUri = 'whatsapp://send?phone=$phoneNumberUrl';
    if (await canLaunchUrl(whatsappUri as Uri)) {
      await launchUrl(whatsappUri as Uri);
    } else {
      throw "Impossible de contacter ce numéro";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
        title: 'Contacter via',
        dialogContent: Container(
          child: Row(
            children: [
              ListTile(
                  title: IconButton(
                      onPressed: () {
                        launchPhoneCall();
                      },
                      icon: const Icon(Icons.call)),
                  subtitle: const Text('téléphone')),
              ListTile(
                  title: IconButton(
                      onPressed: () {
                        launchWhatsapp();
                      },
                      icon: const Icon(Icons.call)),
                  subtitle: const Text('Whatsapp')),
            ],
          ),
        ),
        textBtnChild1: '',
        textBtnChild2: '',
        onPressed1: () {},
        onPressed2: () {});
  }
}
