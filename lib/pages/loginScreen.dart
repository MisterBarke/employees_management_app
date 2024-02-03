import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:managing_app/api/apiService.dart';
import 'package:managing_app/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfos {
  final String userName;
  final String userEmail;
  final String userId;
  final String userPicture;

  UserInfos(
      {required this.userName,
      required this.userEmail,
      required this.userId,
      required this.userPicture});
}

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService apiService = ApiService('http://192.168.88.201:3000');
/*   Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      print('exception->$e');
    }
  } */

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> checkCurrentUser() async {
    return _auth.currentUser;
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<void> saveUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cachedUserId', userId);
  }

  Future<bool> postClient(UserInfos infos) async {
    try {
      final createUsers = Users(
          userEmail: infos.userEmail,
          userPicture: infos.userPicture,
          userId: infos.userId,
          userName: infos.userName);
      await apiService.createUser(createUsers);
      return true;
    } catch (e) {
      print('Network Error $e');
      return false;
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }
      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      print('credentials $credential');
      await _auth.signInWithCredential(credential);
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        final String displayName = currentUser.displayName as String;
        final String email = currentUser.email as String;
        //userId may not remain the same after another session
        final String userId = currentUser.uid;
        final String photoURL = currentUser.photoURL as String;

        UserInfos userInfos = UserInfos(
          userName: displayName,
          userEmail: email,
          userId: userId,
          userPicture: photoURL,
        );

        // Envoi des informations au serveur
        await postClient(userInfos);
        //userId may not remain the same after another session
        setState(() {
          saveUserId(userId);
        });

        print('User Display Name: $displayName');
        print('User Email: $email');
        print('User ID: $userId');
        print('User Photo URL: $photoURL');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  ValueNotifier userCredential = ValueNotifier('');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User?>(
        future: checkCurrentUser(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              // User is already authenticated
              return HomePage();
            } else {
              // User is not authenticated, show login button
              return Center(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    iconSize: 40,
                    icon: Icon(Icons.golf_course),
                    onPressed: () async {
                      signInWithGoogle(context); // Pass the context
                    },
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
