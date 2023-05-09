import 'package:chatapp/pages/HomePage.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/pages/Signuppage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
   TextEditingController emailController= TextEditingController();
   TextEditingController passwordController= TextEditingController();



  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email == "" || password == ""){
      print("Please fill all the fields!");
    }

    else {
      login(email,password);
    }
  }
  

  void login(String email,String password) async {
    UserCredential? credential;
 
    try {
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword
    (email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
      
    }
    if(credential!= null){
      String uid =credential.user!.uid;

      DocumentSnapshot userData = await FirebaseFirestore.instance.
      collection('users').doc(uid).get(); {
        UserModel userModel = UserModel.fromMap(userData.data() as Map<String,dynamic>);

        //go to homepage
        print("Log in Successful");
                Navigator.push(context, MaterialPageRoute(
          builder: (context){
            return HomePage(userModel: userModel, firebaseUser: credential!.user!);
            }
            )
            );
      };
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: () {
                        checkValues();
                      },
                      color: Theme.of(context).colorScheme.secondary,
                      child: const Text("Log In"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: TextButton(
                          child:Text("Sign up"),
                          onPressed: () {
                            Navigator.push(context,
                            MaterialPageRoute(builder: (context)
                            {  return SignupPage();
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
