import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/pages/CompleteProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/pages/Loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  String errorText = '';

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if (email == "" || password == "" || cPassword == "") {
      setState(() {
        errorText = "Please fill all the fields!";
      });
    } else if (password != cPassword) {
      setState(() {
        errorText = "Passwords do not match";
      });
    }else if(password.length<6){
      setState(() {
        errorText = "weak password,enter pass more than 6 keys";
      });}
     else {
      setState(() {
        errorText = '';
      });
      signUp(email, password);
    }
  }
  

  void signUp(String email,String password) async {
    UserCredential? credential;
 
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword
    (email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
      
    }
    if(credential!= null){
      String uid =credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );
      await FirebaseFirestore.instance.collection("users").doc(uid).set(newUser.toMap()).then((value) {
        print("new User created");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context){
            return CompleteProfile(userModel: newUser, firebaseUser: credential!.user!);
          })
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (errorText.isNotEmpty) Text(errorText, style: TextStyle(color: Colors.red)),
                  SizedBox(
                    height: 120,
                    child: Image.asset(
                      "assets/images/logo.jpg",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            hintText: "Email Address",
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                          height: 1,
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            hintText: "Password",
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                          height: 1,
                        ),
                        TextFormField(
                          controller: cPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            hintText: "Confirm Password",
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: (){
                        checkValues();                     
                           } ,
                      color: Theme.of(context).colorScheme.secondary,
                      child: const Text("Sign Up"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {},
                          child: TextButton(
                          child:Text("log in"),
                          onPressed: () {
                            Navigator.push(context,
                            MaterialPageRoute(builder: (context)
                            {  return LoginPage();
                            },
                        ), 
                        );
                      },
                      
                    ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
