import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:managing_app/api/apiService.dart';
import 'package:managing_app/utility/urlCallLauncher.dart';
import 'package:managing_app/widgets/notificationPopup.dart';

class EmployeeCard extends StatefulWidget {
  final searchValue;
  final void Function(Employee employee) deleteEmployeeFunc;
  final void Function() fetchEmployeeFunc;
  final void Function(Employee employee) editEmployeeFunc;
  final List<Employee> employees;

  const EmployeeCard(
      {super.key,
      required this.searchValue,
      required this.deleteEmployeeFunc,
      required this.fetchEmployeeFunc,
      required this.editEmployeeFunc,
      required this.employees});

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.employees.length, //appState.people.length,
        itemBuilder: (context, index) {
          //Person person = appState.people[index];
          final employee = widget.employees[index];
          if (employee.nom
                  .toLowerCase()
                  .contains(widget.searchValue.toLowerCase()) ||
              employee.region
                  .toLowerCase()
                  .contains(widget.searchValue.toLowerCase())) {
            return Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(20),
                    child: Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                employee.nom,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xE42C6CB5)),
                              ),
                            ],
                          ),
                          subtitle: Column(children: [
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Client: ${employee.company}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    Text('Salaire: XOF ${employee.salary}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    Row(
                                      children: [
                                        Icon(Icons.phone,
                                            color: Color(0xE42C6CB5)),
                                        TextButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return ContactAppLauncher(
                                                        phoneNumberUrl:
                                                            '+227 ${employee.phone.toString()}');
                                                  });
                                            },
                                            child: Text(
                                                '+227 ${employee.phone.toString()}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xE42C6CB5),
                                                  fontWeight: FontWeight.bold,
                                                ))),
                                      ],
                                    )
                                  ],
                                ),
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xE42C6CB5),
                                        width: 4.0,
                                        style: BorderStyle.solid),
                                  ),
                                  child: employee.picture.isNotEmpty
                                      ? Image.network(
                                          employee.picture,
                                        )
                                      : Image.network(
                                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJtlub9_AAfjJdIO1nkf92yFm5QNhqUbp2ow7GdCLWAgODzCXBgtqObCOeUmRLbftGKh4&usqp=CAU', // chemin vers votre image par défaut
                                        ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                    color: const Color(0xE42C6CB5),
                                    onPressed: () {
                                      widget.editEmployeeFunc(employee);
                                    },
                                    icon: const Icon(Icons.edit)),
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xE42C6CB5),
                                        width: 4.0,
                                        style: BorderStyle.solid),
                                  ),
                                  child: Text(
                                    employee.region,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                    color: Colors.red,
                                    onPressed: () {
                                      {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Confirmation'),
                                              content: Text(
                                                  'Voulez-vous vraiment supprimer cet agent ?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Annuler'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();

                                                    widget.deleteEmployeeFunc(
                                                        employee);
                                                    setState(() {
                                                      widget
                                                          .fetchEmployeeFunc();
                                                    });
                                                  },
                                                  child: Text('Supprimer'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.delete))
                              ],
                            )
                          ]),
                        )))
              ],
            );
          } else {
            return Container();
          }
        });
  }
}
