import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register.dart';
import '../main.dart';
import '../shared/loading.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

TextEditingController _emailController = new TextEditingController();
TextEditingController _passwordController = new TextEditingController();
FirebaseAuth auth = FirebaseAuth.instance;

bool isLoading = false;
String _email = "";
String _password = "";
bool _registerSucceded = false;

class _RegisterScreenState extends State<RegisterScreen> {
  createUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      setState(() {
        _registerSucceded = true;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: isLoading
          ? LoadingScreen()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Deine Email...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  textAlign: TextAlign.left,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Dein Passwort...',
                    hintStyle: TextStyle(color: Colors.grey),
                    
                  ),
                ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _email = _emailController.text;
                        _password = _passwordController.text;
                        isLoading = true;
                      });
                      createUser();

                      if (_registerSucceded = true) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
                      }
                    },
                    child: Text("Register"))
              ],
            ),
    );
  }
}
