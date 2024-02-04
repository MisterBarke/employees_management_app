import 'dart:async';
import 'dart:convert';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:managing_app/api/apiService.dart';
import 'package:managing_app/pages/loginScreen.dart';
import 'package:managing_app/widgets/dialogs.dart';
import 'package:managing_app/widgets/editDialogForm.dart';
import 'package:managing_app/widgets/employeeCard.dart';
import 'package:managing_app/widgets/notificationPopup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgentList extends StatefulWidget {
  const AgentList({
    Key? key,
  });
  @override
  State<AgentList> createState() => _AgentListState();
}

class _AgentListState extends State<AgentList> {
  String searchValue = '';
  final List<String> _suggestions = [];
  //var _getAllEmployees = [];
  final ApiService apiService = ApiService('https://security-bay.vercel.app');
  late List<Employee> employees = [];

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
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

  // final url = "https://jsonplaceholder.typicode.com/posts";
  Future<void> fetchEmployees() async {
    try {
      final data = await apiService.fetchData(await getUserId());

      if (data != null) {
        final List<dynamic> employeesData = data["employees"];
        setState(() {
          employees =
              employeesData.map((json) => Employee.fromJson(json)).toList();
          _cacheData(employees);
          print(data);
        });
      } else {
        throw Exception("Data is not in the expected format");
      }
    } catch (error) {
      print('Error fetching employees: $error');
    }
  }

  Future<bool> deleteEmployee(Employee employees) async {
    try {
      final employeeId = employees.id;
      final deleted = await apiService.deleteEmployee(employeeId);
      print(deleted);
      if (deleted) {
        print('data deleted bro');

        CustomSnackBar.show(context, 'Agent supprimer avec succès');
        return true;
      } else {
        print('check your network connexion');
        CustomSnackBar.show(context,
            'Erreur lors de la suppression, vérifiez votre connexion internet!');
        return false;
      }
    } catch (err) {
      CustomSnackBar.show(context,
          'Erreur lors de la suppression, vérifiez votre connexion internet!');
      print('Error deleting data $err');
      return false;
    }
  }

  Future<void> editEmployee(Employee employee) async {
    final TextEditingController newNameController = TextEditingController();
    final TextEditingController newPhoneController = TextEditingController();
    final TextEditingController newCompanyController = TextEditingController();
    final TextEditingController newRegionController = TextEditingController();
    final TextEditingController newSalaryController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDialogForm(
            companyController: newCompanyController,
            phoneController: newPhoneController,
            salaryController: newSalaryController,
            regionController: newRegionController,
            nameController: newNameController,
            picture: employee.picture,
            employee: employee,
            onUpdate: (updatedEmployee) async {
              try {
                await apiService.editEmployee(employee.id, updatedEmployee);
                await fetchEmployees();
                CustomSnackBar.show(context, 'Agent modifier avec succès');
              } catch (e) {
                CustomSnackBar.show(
                    context, "Une erreur est survenue lors de l'éditiondd.");
              } finally {
                // Close the dialog after the asynchronous operations complete
                Navigator.of(context).pop();
              }
            });
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (employees.isEmpty) {
      fetchEmployees();
      _loadCachedData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // You can also fetch data here if needed
    // This method is called when dependencies of the widget change (e.g., inherited widgets)
  }

  Future<void> _loadCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cachedData = prefs.getString('cached_data') ?? '';
    if (cachedData.isNotEmpty) {
      List<dynamic> cachedEmployeesData = json.decode(cachedData);
      setState(() {
        employees =
            cachedEmployeesData.map((json) => Employee.fromJson(json)).toList();
      });
    }
  }

  Future<void> _cacheData(List<Employee> employees) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cached_data', json.encode(employees));
  }

  @override
  Widget build(BuildContext context) {
    //var appState = Provider.of<AppState>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: EasySearchBar(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF3086D7),
        title: const Text('Mes Agents',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xE3FFFFFF))),
        onSearch: (value) => setState(() => searchValue = value),
        suggestions: _suggestions,
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return FormDialog(
                          title: 'Profile',
                          dialogContent: Container(
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  child: Image.network(
                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJtlub9_AAfjJdIO1nkf92yFm5QNhqUbp2ow7GdCLWAgODzCXBgtqObCOeUmRLbftGKh4&usqp=CAU'),
                                ),
                                Text("UserName"),
                                ElevatedButton(
                                    onPressed: () {
                                      signOutFromGoogle();
                                      setState(() {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginScreen()));
                                      });
                                    },
                                    child: Text('Déconnexion'))
                              ],
                            ),
                          ),
                          textBtnChild1: '',
                          textBtnChild2: 'Fermer',
                          onPressed1: () {},
                          onPressed2: () {
                            Navigator.of(context).pop();
                          });
                    });
              },
              icon: Icon(Icons.person_2_outlined))
        ],
      ),
      body: EmployeeCard(
        searchValue: searchValue,
        deleteEmployeeFunc: deleteEmployee,
        fetchEmployeeFunc: fetchEmployees,
        editEmployeeFunc: editEmployee,
        employees: employees,
      ),
    );
  }
}
