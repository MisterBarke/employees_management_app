import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:managing_app/api/apiService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:managing_app/widgets/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditDialogForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController companyController;
  final TextEditingController regionController;
  final TextEditingController salaryController;
  final picture;
  final Employee employee;
  final Function(Employee) onUpdate;
  const EditDialogForm(
      {super.key,
      required this.companyController,
      required this.phoneController,
      required this.salaryController,
      required this.regionController,
      required this.nameController,
      required this.employee,
      required this.picture,
      required this.onUpdate});

  @override
  State<EditDialogForm> createState() => _EditDialogFormState();
}

class _EditDialogFormState extends State<EditDialogForm> {
  File? _image;
  String _imageUrl = '';
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedImage == null) {
        // User canceled image picking
        return;
      }

      Reference storageReference =
          _storage.ref().child('employees/${DateTime.now()}.png');
      UploadTask uploadTask = storageReference.putFile(File(pickedImage.path));

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() async {
        // Retrieve the download URL of the image
        String downloadUrl = await storageReference.getDownloadURL();

        setState(() {
          _image = File(pickedImage.path);
          _imageUrl = downloadUrl;
          // Store the image URL in _imageUrl
        });
      });
//Download URL: ${taskSnapshot.ref.getDownloadURL()} to get the image url in the console
      print('Image uploaded successfully.');
    } catch (error) {
      print('Error uploading image: $error');
      // Handle the error, show a message to the user, or log it for further investigation
    }
  }

  Future<String> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cachedUserId = prefs.getString('cachedUserId');
    if (cachedUserId != null) {
      return cachedUserId;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: 'Modifier l\'agent',
      dialogContent: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20),
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFF3086D7),
                      width: 4.0,
                      style: BorderStyle.solid),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: _image == null
                  ? const Text('No image Selected')
                  : Image.file(_image!),
            ),
            IconButton(
                onPressed: () {
                  _pickImage();
                },
                icon: Icon(
                  Icons.edit,
                  color: Colors.red,
                )),
            TextField(
              controller: widget.nameController,
              decoration: InputDecoration(labelText: 'Nouveau nom'),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: widget.phoneController,
              decoration:
                  const InputDecoration(labelText: "Nouveau numero de l'agent"),
              validator: (value) {
                RegExp regex = RegExp(r'^[0-9]+$');
                if (value != null && !regex.hasMatch(value)) {
                  return 'Veuillez entrer le salaire';
                }
                return null;
              },
            ),
            TextField(
              controller: widget.companyController,
              decoration: InputDecoration(labelText: 'Nouvelle entreprise'),
            ),
            TextField(
              controller: widget.regionController,
              decoration: InputDecoration(labelText: 'Nouvelle région'),
            ),
            TextField(
              controller: widget.salaryController,
              decoration: InputDecoration(labelText: 'Nouveau salaire'),
            ),
          ],
        ),
      ),
      textBtnChild1: 'Annuler',
      textBtnChild2: 'Enregistrer',
      onPressed1: () {
        Navigator.of(context).pop();
      },
      onPressed2: () async {
        int newPhone;
        String newSalary;
        String newName;
        String newCompany;
        String newRegion;
        String newPicture;
        RegExp regex = RegExp(r'^[0-9]+$');
        if (widget.phoneController.text.isEmpty ||
            !regex.hasMatch(widget.phoneController.text)) {
          newPhone = widget.employee.phone;
        } else {
          newPhone = int.parse(widget.phoneController.text);
        }
        if (widget.salaryController.text.isEmpty) {
          newSalary = widget.employee.salary;
        } else {
          newSalary = widget.salaryController.text;
        }
        if (widget.regionController.text.isEmpty) {
          newRegion = widget.employee.region;
        } else {
          newRegion = widget.regionController.text;
        }
        if (widget.nameController.text.isEmpty) {
          newName = widget.employee.nom;
        } else {
          newName = widget.nameController.text;
        }
        if (widget.companyController.text.isEmpty) {
          newCompany = widget.employee.company;
        } else {
          newCompany = widget.companyController.text;
        }
        if (_imageUrl == '') {
          newPicture = widget.employee.picture;
        } else {
          newPicture = _imageUrl;
        }

        // Effectuez la mise à jour côté serveur
        final updatedEmployee = Employee(
          userId: await getUserId(),
          id: widget.employee.id,
          salary: newSalary,
          nom: newName,
          phone: newPhone,
          company: newCompany,
          region: newRegion,
          picture: newPicture,
          // Ajoutez les autres champs à mettre à jour
        );
        widget.onUpdate(updatedEmployee);

        // Fermez la boîte de dialogue
        Navigator.of(context).pop();
      },
    );
  }
}
