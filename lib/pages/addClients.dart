// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:managing_app/widgets/notificationPopup.dart';
import 'package:uuid/uuid.dart';
import 'package:managing_app/api/apiService.dart';
import 'package:managing_app/widgets/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Client {
  String userId;
  String client;
  String salary;
  String id;
  Client(
      {required this.client,
      required this.salary,
      required this.id,
      required this.userId});
}

class AddClients extends StatefulWidget {
  const AddClients({super.key});

  @override
  State<AddClients> createState() => _AddClientsState();
}

class _AddClientsState extends State<AddClients> {
  final ApiService apiService = ApiService('https://security-bay.vercel.app');
  late List<Clients> clients = [];
  late Client client;
  int total = 0;
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  var uuid = Uuid();

  Future<void> saveToCache(List<Clients> clients) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> clientsJsonList =
        clients.map((client) => jsonEncode(client.toJson())).toList();

    prefs.setStringList('cached_clients', clientsJsonList);
  }

  Future<void> saveTotalToCache(int total) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('cached_total', total);
  }

  Future<int> loadTotalFromCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? cachedTotal = prefs.getInt('cached_total');

    if (cachedTotal != null) {
      return cachedTotal;
    } else {
      return 0; // Default value if total is not found in cache
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

  Future<List<Clients>> loadFromCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? clientsJsonList = prefs.getStringList('cached_clients');

    if (clientsJsonList != null) {
      final List<Clients> cachedClients = clientsJsonList
          .map((clientJson) => Clients.fromJson(jsonDecode(clientJson)))
          .toList();

      return cachedClients;
    } else {
      return [];
    }
  }

  Future<void> fetchClientsData() async {
    try {
      List<Clients> cachedClients = await loadFromCache();
      final data = await apiService.fetchClients(await getUserId());
      final List<dynamic> clientsData = data['clients'];

      setState(() {
        clients = clientsData
            .map((jsonDatas) => Clients.fromJson(jsonDatas))
            .toList();
      });

      saveToCache(clients);
      if (clients.isEmpty && !data) {
        setState(() {
          clients = cachedClients;
        });
      }

      print(clients);
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }

  Future<void> fetchSalary() async {
    try {
      final data = await apiService.fetchTotalSalary(await getUserId());
      print('data herefgfgffg');
      print(data);
      final totalSalary = data['salary'];
      print(totalSalary);
      setState(() {
        total = totalSalary;
        saveTotalToCache(total);
      });
    } catch (error) {
      print('Error fetching clients: $error');
    }
  }

  Future<bool> postClientsData(Client client) async {
    try {
      final createClient = Clients(
          userId: client.userId,
          client: client.client,
          salary: int.parse(client.salary),
          id: client.id);
      await apiService.postClient(createClient);

      return true;
    } catch (e) {
      print('Network Error $e');
      return false;
    }
  }

  Future<bool> deleteClient(Clients clients) async {
    try {
      final clientId = clients.id;
      await apiService.deleteClient(clientId);
      return true;
    } catch (err) {
      print('Error deleting data $err');
      return false;
    }
  }

  Future<void> editClient(Clients client) async {
    try {
      final TextEditingController newClientNameController =
          TextEditingController();
      final TextEditingController newSalaryController = TextEditingController();
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return FormDialog(
                title: 'Moifier un client',
                dialogContent: SizedBox(
                    height: 150,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: newClientNameController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.add_business,
                                color: Color(0xFF3086D7),
                              ),
                              labelText: "Nom du client"),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                          ],
                          controller: newSalaryController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.money,
                                color: Color(0xFF3086D7),
                              ),
                              labelText: "Salaire"),
                        ),
                      ],
                    )),
                textBtnChild1: 'Annuler',
                textBtnChild2: 'Confirmer',
                onPressed1: () {
                  Navigator.pop(context);
                },
                onPressed2: () async {
                  int salary;
                  String clientName;
                  if (newClientNameController.text.isEmpty) {
                    clientName = client.client;
                  } else {
                    clientName = newClientNameController.text;
                  }
                  RegExp regex = RegExp(r'^[0-9]+$');
                  if (newSalaryController.text.isEmpty ||
                      !regex.hasMatch(newSalaryController.text)) {
                    salary = client.salary;
                  } else {
                    salary = int.parse(newSalaryController.text);
                  }
                  client = Clients(
                      client: clientName,
                      salary: salary,
                      id: client.id,
                      userId: await getUserId());
                  await fetchSalary();
                  final editedClient =
                      await apiService.editClient(client.id, client);
                  if (editedClient) {
                    CustomSnackBar.show(
                        context, 'Client supprimer avec succès');
                  } else {
                    CustomSnackBarError.show(context,
                        "Erreur lors de l'edition, verifiez votre connexion internet");
                  }
                  await fetchClientsData();
                  Navigator.of(context).pop();
                });
          });
    } catch (e) {
      CustomSnackBarError.show(context,
          "Erreur lors de l'edition, verifiez votre connexion internet");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (clients.isEmpty) {
      fetchClientsData();
      fetchSalary();
      fetchSalaryFromCache();
    }
  }

  Future<void> fetchSalaryFromCache() async {
    try {
      final int cachedTotal = await loadTotalFromCache();
      setState(() {
        total = cachedTotal;
      });
    } catch (error) {
      print('Error loading total from cache: $error');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // You can also fetch data here if needed
    // This method is called when dependencies of the widget change (e.g., inherited widgets)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Ajouter un client',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return FormDialog(
                          title: 'Ajouter un client',
                          dialogContent: SizedBox(
                              height: 150,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _clientController,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(
                                          Icons.add_business,
                                          color: Color(0xFF3086D7),
                                        ),
                                        labelText: "Nom du client"),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer le salaire';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]'))
                                    ],
                                    controller: _salaryController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(
                                        Icons.money,
                                        color: Color(0xFF3086D7),
                                      ),
                                      labelText: "Salaire",
                                    ),
                                    validator: (value) {
                                      RegExp regex = RegExp(r'^[0-9]+$');
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer le salaire';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              )),
                          textBtnChild1: 'Annuler',
                          textBtnChild2: 'Confirmer',
                          onPressed1: () {
                            Navigator.pop(context);
                          },
                          onPressed2: () async {
                            client = Client(
                                userId: await getUserId(),
                                client: _clientController.text,
                                salary: _salaryController.text,
                                id: uuid.v4());

                            bool postSuccess = await postClientsData(client);
                            print(postSuccess);
                            if (postSuccess) {
                              fetchClientsData();
                              fetchSalary();
                              _clientController.clear();
                              _salaryController.clear();
                              CustomSnackBar.show(
                                  context, 'Client Ajouter avec succès');
                            } else {
                              CustomSnackBarError.show(context,
                                  'Erreur, verifiez votre connexion internet');
                            }
                            Navigator.pop(context);
                          });
                    });
              },
              icon: const Icon(
                Icons.add_rounded,
                color: Colors.blue,
              ),
              iconSize: 28,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Colors.blue,
              ),
              iconSize: 28,
            )
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              height: 50,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(117, 232, 232, 232),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Text(
                'XOF ${total.toString()}',
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                  itemCount: clients.length,
                  itemBuilder: ((context, index) {
                    final client = clients[index];
                    return Column(
                      children: [
                        Card(
                            child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        client.client,
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                            fontSize: 16),
                                      ),
                                      Text(
                                        'XOF ${client.salary.toString()}',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            editClient(client);
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Confirmation'),
                                                  content: Text(
                                                      'Voulez-vous vraiment supprimer cet agent ?'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Annuler'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        final bool
                                                            deletedClient =
                                                            await deleteClient(
                                                                client);
                                                        if (deletedClient) {
                                                          CustomSnackBar.show(
                                                              context,
                                                              'Client supprimer avec succès');
                                                        } else {
                                                          CustomSnackBarError.show(
                                                              context,
                                                              'Client non supprimer, verifiez votre connexion internet');
                                                        }
                                                        setState(() {
                                                          fetchClientsData();
                                                          fetchSalary();
                                                          Navigator.of(context)
                                                              .pop();
                                                        });
                                                      },
                                                      child: Text('Supprimer'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          )),
                                    ],
                                  )
                                ]))),
                      ],
                    );
                  })),
            )
          ],
        ));
  }
}
