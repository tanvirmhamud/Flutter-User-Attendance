import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userattendence/homepage.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({Key? key}) : super(key: key);

  @override
  _LoginpageState createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  String? userid, userpassword;

  final formkey = GlobalKey<FormState>();

  fromvalidation() {
    final form = formkey.currentState;
    if (form!.validate()) {
      form.save();
      usersignin();
    }
  }

  usersignin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userid!, password: userpassword!);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(),
          ));
      if (userCredential.additionalUserInfo != null) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('email', userid!);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter User Id";
                      }
                    },
                    onSaved: (newValue) {
                      setState(() {
                        userid = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "User Id",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter User Password";
                      }
                    },
                    onSaved: (newValue) {
                      setState(() {
                        userpassword = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "User PAssword",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        fromvalidation();
                      },
                      child: Text("Login"),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
