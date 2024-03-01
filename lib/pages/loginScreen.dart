import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:managing_app/api/apiService.dart';
import 'package:managing_app/home.dart';
import 'package:managing_app/widgets/notificationPopup.dart';
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
  final ApiService apiService = ApiService('https://security-bay.vercel.app');
  FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

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

  Future<void> saveUserName(String userName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cachedUserName', userName);
  }

  Future<void> saveUserPhoto(String userPicture) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cachedUserPicture', userPicture);
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
    setState(() {
      _isLoading = true;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
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
        final String userId = currentUser.uid;
        final String photoURL = currentUser.photoURL as String;

        UserInfos userInfos = UserInfos(
          userName: displayName,
          userEmail: email,
          userId: userId,
          userPicture: photoURL,
        );
        await postClient(userInfos);
        setState(() {
          saveUserId(userId);
          saveUserName(displayName);
          saveUserPhoto(photoURL);
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  ValueNotifier userCredential = ValueNotifier('');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<User?>(
            future: checkCurrentUser(),
            builder: (context, AsyncSnapshot<User?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  //doesn't work
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasData && snapshot.data != null) {
                  // User is already authenticated
                  return const HomePage();
                } else {
                  // User is not authenticated, show login button
                  return Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          signInWithGoogle(context); // Pass the context
                        },
                        child: Text('Se connecter avec google')),
                  );
                }
              }
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
