import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/firebase_auth_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginPage();
}

class _loginPage extends State<login> {
  final FirebaseAuthService _authService =
      FirebaseAuthService(FirebaseAuth.instance);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: null,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 300,
            // height: 540,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 0, top: 50),
                  child: Image.asset(
                    'asset_media/gambar/icon/login.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20.0,
                    top: 0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Login kuy!",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      TextFormGlobal(
                        controller: _emailController,
                        text: 'Email',
                        textInputType: TextInputType.emailAddress,
                        obscureText: false,
                      ),
                      SizedBox(height: 5),
                      TextFormGlobal(
                        controller: _passwordController,
                        text: 'Password',
                        textInputType: TextInputType.visiblePassword,
                        obscureText: true,
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Masukkan Email & Password yang benar dong!",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 5),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            User? user =
                                await _authService.signInWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            if (user != null) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => homepage(),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              _errorMessage = e.message!;
                            });
                          }
                        },
                        child: Text(
                          'Masuk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                              MediaQuery.of(context).size.width * 0.30, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => signUp(),
                            ),
                          );
                        },
                        child: Text(
                          'Daftar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                              MediaQuery.of(context).size.width * 0.30, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextFormGlobal extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final TextInputType textInputType;
  final bool obscureText;

  const TextFormGlobal({
    Key? key,
    required this.controller,
    required this.text,
    required this.textInputType,
    required this.obscureText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.all(10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: text,
          border: OutlineInputBorder(),
        ),
        obscureText: obscureText,
        keyboardType: textInputType,
      ),
    );
  }
}
