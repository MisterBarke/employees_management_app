// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'package:managing_app/widgets/dialogs.dart';
import 'package:managing_app/widgets/notificationPopup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:managing_app/api/apiService.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:managing_app/pages/agentList.dart';
import 'package:provider/provider.dart';

class Person {
  String name;
  String salary;
  String office;
  String number;
  String picture;
  String region;
  String userId;

  Person(
      {required this.name,
      required this.salary,
      required this.number,
      required this.office,
      required this.picture,
      required this.userId,
      required this.region});
}

//class AppState extends ChangeNotifier {
/*   Person person = Person(
      name: "John Doe", salary: '2332f', number: '323333', office: 'Tahoua'); */
// List<Person> people = [];

// void addPerson(Person newPerson) {
//   people.add(newPerson);
//   notifyListeners();
//  }
//}

class AddAgentForm extends StatefulWidget {
  const AddAgentForm({Key? key}) : super(key: key);

  @override
  State<AddAgentForm> createState() => _AddAgentFormState();
}

class _AddAgentFormState extends State<AddAgentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _officeController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final ApiService apiService = ApiService('https://security-bay.vercel.app');
  //List<Person> people = [];
  var uuid = Uuid();
  String? _selectedLocation;
  late Person person;
  late List<Clients> clients = [];
  File? _image;
  String _imageUrl = '';
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  var pickedImg;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        pickedImg = pickedImage;
      });

      if (pickedImage == null) {
        // User canceled image picking
        return;
      }
      setState(() {
        _image = File(pickedImage.path);
      });

//Download URL: ${taskSnapshot.ref.getDownloadURL()} to get the image url in the console
      print('Image uploaded successfully.');
    } catch (error) {
      print('Error uploading image: $error');
      // Handle the error, show a message to the user, or log it for further investigation
    }
  }

  Future<void> uploadImage(pickedImg) async {
    setState(() {
      _isLoading = true;
    });
    try {
      Reference storageReference =
          _storage.ref().child('employees/${DateTime.now()}.png');
      UploadTask uploadTask = storageReference.putFile(File(pickedImg.path));

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() async {
        // Retrieve the download URL of the image

        String downloadUrl = await storageReference.getDownloadURL();
        setState(() {
          _imageUrl = downloadUrl;
          _isLoading = false;
        });
      });
    } catch (e) {
      print('Something went wrongwhen uploading');
      print(e);
    } finally {
      _isLoading = false;
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

  Future<bool> postEmployee(Person person) async {
    try {
      final employee = Employee(
        userId: await getUserId(),
        nom: person.name,
        phone: int.parse(person.number),
        company: person.office,
        region: person.region,
        salary: person.salary,
        id: uuid.v4(),
        picture: person.picture,
      );
      // modifier
      final postedEmployee = await apiService.postEmployee(employee);
      if (postedEmployee) {
        CustomSnackBar.show(context, "Agent ajouter avec succès");
        return true;
      } else {
        CustomSnackBar.show(context, "Agent ajouter avec succès");
      }
      return true;
    } catch (err) {
      print('Error posting data $err');
      return false;
    }
  }

  Future<void> fetchClientsData() async {
    try {
      final data = await apiService.fetchClients(await getUserId());
      final List<dynamic> clientsData = data['clients'];

      setState(() {
        clients = clientsData
            .map((jsonDatas) => Clients.fromJson(jsonDatas))
            .toList();
        print(clients);
      });
    } catch (e) {
      print('check your network');
      CustomSnackBarError.show(context,
          'Impossible de chargé la liste des clients, verifiez votre connexion internet');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (clients.isEmpty) {
      fetchClientsData();
    }
  }

  Widget build(BuildContext context) {
    //var appState = Provider.of<AppState>(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: const Color(0xFF3086D7),
          title: const Text(
            'Ajoutez un agent',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Stack(children: [
          Container(
            height: 1000,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xFF3086D7),
                          width: 4.0,
                          style: BorderStyle.solid),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: _image == null
                      ? const Text('No image Selected')
                      : Image.file(_image!),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                    onPressed: () {
                      _pickImage();
                    },
                    child: const Text(
                      'Choose a picture',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    )),
                Container(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Color(0xFF3086D7),
                                ),
                                labelText: "Nom de l'agent"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le nom';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: _regionController,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.place,
                                  color: Color(0xFF3086D7),
                                ),
                                labelText: "Region de l'agent"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer la region';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _numberController,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: Color(0xFF3086D7),
                                ),
                                labelText: "Numero de l'agent"),
                            validator: (value) {
                              RegExp regex = RegExp(r'^[0-9]+$');
                              if (value == null ||
                                  value.isEmpty ||
                                  !regex.hasMatch(value)) {
                                return 'Veuillez entrer le numero de tel';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 5),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.work,
                                color: Color(0xFF3086D7),
                              ),
                              labelText: "Lieu de garde de l'agent",
                            ),
                            value:
                                _selectedLocation, // Assurez-vous de définir _selectedLocation dans l'état de votre widget
                            items: clients.map((client) {
                              return DropdownMenuItem<String>(
                                value: client
                                    .client, // Assurez-vous que votre modèle Client a une propriété "nom" ou similaire
                                child: Text(client
                                    .client), // Assurez-vous que votre modèle Client a une propriété "nom" ou similaire
                              );
                            }).toList(),
                            onChanged: (value) {
                              // Mettez à jour l'état avec la valeur sélectionnée
                              setState(() {
                                _selectedLocation = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez sélectionner un lieu';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _salaryController,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.money_sharp,
                                  color: Color(0xFF3086D7),
                                ),
                                labelText: "Salaire de l'agent"),
                            validator: (value) {
                              RegExp regex = RegExp(r'^[0-9]+$');
                              if (value == null ||
                                  value.isEmpty ||
                                  !regex.hasMatch(value)) {
                                return 'Veuillez entrer le salaire';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                              onPressed: () async {
                                //edited
                                await uploadImage(pickedImg);
                                if (_formKey.currentState!.validate()) {
                                  person = Person(
                                      userId: await getUserId(),
                                      name: _nameController.text,
                                      salary: _salaryController.text,
                                      number: _numberController.text,
                                      office: _selectedLocation as String,
                                      picture: _imageUrl,
                                      region: _regionController.text);
                                  // people.add(person);
                                  //appState.addPerson(person);

                                  _nameController.clear();
                                  _numberController.clear();
                                  _salaryController.clear();
                                  _officeController.clear();
                                  _regionController.clear();

                                  await postEmployee(person);
                                }
                              },
                              child: const Text('Valider',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold))),
                          const SizedBox(height: 70)
                        ],
                      ),
                    )),
              ],
            ),
          ),
          if (_isLoading)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 20,
              left: MediaQuery.of(context).size.width / 2 - 20,
              child: const CircularProgressIndicator(),
            ),
        ])));
  }
}
