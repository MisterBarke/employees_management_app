import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Employee {
  final String userId;
  final String id;
  final String nom;
  final int phone;
  final String company;
  final String region;
  final String salary;
  final String picture;

  Employee(
      {required this.nom,
      required this.phone,
      required this.company,
      required this.region,
      required this.picture,
      required this.salary,
      required this.userId,
      required this.id});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      userId: json['_userId'],
      id: json['_id'],
      nom: json['nom'],
      phone: json['phone'],
      salary: json['salary'],
      company: json['company'],
      region: json['region'],
      picture: json['picture'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_userId': userId,
      '_id': id,
      'nom': nom,
      'salary': salary,
      'phone': phone,
      'company': company,
      'region': region,
      'picture': picture
    };
  }
}

class Clients {
  final String userId;
  final String client;
  final int salary;
  final String id;

  Clients(
      {required this.client,
      required this.salary,
      required this.id,
      required this.userId});

  factory Clients.fromJson(Map<String, dynamic> json) {
    return Clients(
        userId: json['_userId'],
        salary: json['salary'],
        client: json['client'],
        id: json['_id']);
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'salary': salary, 'client': client, '_userId': userId};
  }
}

class Users {
  final String userName;
  final String userEmail;
  final String userId;
  final String userPicture;

  Users(
      {required this.userName,
      required this.userEmail,
      required this.userId,
      required this.userPicture});

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userName: json['userName'],
      userEmail: json['userEmail'],
      userId: json['_userId'],
      userPicture: json['userPicture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'userPicture': userPicture
    };
  }
}

class ApiService {
  final String url;

  ApiService(this.url);

  Future<dynamic> fetchData(String userId) async {
    try {
      final response = await get(Uri.parse('$url/employees/$userId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      throw Exception('Network error');
    }
  }

  Future<dynamic> postEmployee(Employee employee) async {
    try {
      final response = await post(Uri.parse('$url/employees'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(employee.toJson()));
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      throw Exception('Network error');
    }
  }

  /* Future<void> deleteEmployee(String employeeId) async {
    final response = await delete(Uri.parse('$url/employee/$employeeId'));

    if (response.statusCode == 204) {
      print('Employee deleted successfully');
      // Suppression réussie, pas de contenu dans la réponse (204 No Content)
    } else {
      throw Exception('Failed to delete employee');
    }
  } */
  Future<bool> deleteEmployee(String employeeId) async {
    try {
      final response = await delete(Uri.parse('$url/employees/$employeeId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{'_id': employeeId}));

      if (response.statusCode == 200) {
        print('Employee deleted successfully');
        return true;
      } else {
        print('Failed to delete employee');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> editEmployee(String employeeId, Employee employee) async {
    try {
      final response = await put(
        Uri.parse('$url/employees/$employeeId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(employee.toJson()),
      );

      if (response.statusCode == 200) {
        print('Employee updated successfully');
      } else {
        throw Exception('Failed to update employee');
      }
    } catch (err) {
      throw Exception('Error updating employee: $err');
    }
  }

  Future<dynamic> fetchClients(String userId) async {
    try {
      final response = await get(Uri.parse('$url/clients/$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        print('Clients not found');
      } else {
        print('Something went wrong');
      }
    } catch (err) {
      throw Exception('Check your network connexion');
    }
  }

  Future<dynamic> postClient(Clients clients) async {
    try {
      final response = await post(Uri.parse('$url/clients'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(clients.toJson()));
      print(response.statusCode);
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Failed to post data');
      }
    } catch (e) {
      throw Exception('Something went wrong, check your network');
    }
  }

  Future<dynamic> fetchTotalSalary(String userId) async {
    try {
      final response = await get(Uri.parse('$url/clients/$userId/totalSalary'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Network issue');
    }
  }

  Future<dynamic> deleteClient(String clientId) async {
    try {
      final response = await delete(Uri.parse('$url/clients/$clientId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{'_id': clientId}));

      if (response.statusCode == 200) {
        print('Client deleted successfully');
        return true;
      } else {
        print('Failed to delete client');
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> editClient(String clientId, Clients client) async {
    try {
      final response = await put(
        Uri.parse('$url/clients/$clientId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(client.toJson()),
      );

      if (response.statusCode == 200) {
        print('Client updated successfully');
        return true;
      } else {
        return false;
      }
    } catch (err) {
      print('Error updating client: $err');
      return false;
    }
  }

  Future<dynamic> createUser(Users user) async {
    try {
      final response = await post(Uri.parse('$url/user'),
          headers: {'content-Type': 'application/json'},
          body: jsonEncode(user.toJson()));
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return;
      }
    } catch (e) {
      print('an error has occured');
    }
  }
}
