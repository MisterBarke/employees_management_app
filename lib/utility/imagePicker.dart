/*  import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

 
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
  } */