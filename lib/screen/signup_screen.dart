import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/firebase_auth_service.dart';
import 'home_screen.dart';

class signUp extends StatefulWidget {
  const signUp({super.key});

  @override
  State<signUp> createState() => _SignUp();
}

class _SignUp extends State<signUp> {
  final FirebaseAuthService _authService =
      FirebaseAuthService(FirebaseAuth.instance);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _programStudiController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: null,
      ),
      body: Center(
        child: Container(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Daftar Dulu Gaes!",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormGlobal(
                  controller: _nameController,
                  text: 'Nama Mahasiswa',
                  textInputType: TextInputType.name,
                  obscureText: false,
                ),
                SizedBox(height: 5),
                TextFormGlobal(
                  controller: _nimController,
                  text: 'NIM',
                  textInputType: TextInputType.text,
                  obscureText: false,
                ),
                SizedBox(height: 5),
                TextFormGlobal(
                  controller: _programStudiController,
                  text: 'Program Studi',
                  textInputType: TextInputType.text,
                  obscureText: false,
                ),
                SizedBox(height: 5),
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
                SizedBox(height: 5),
                TextFormGlobal(
                  controller: _confirmPasswordController,
                  text: 'Konfirmasi Password',
                  textInputType: TextInputType.visiblePassword,
                  obscureText: true,
                ),
                SizedBox(height: 15),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    if (_passwordController.text ==
                        _confirmPasswordController.text) {
                      try {
                        User? user =
                            await _authService.createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                          nama: _nameController.text,
                          nim: _nimController.text,
                          programStudi: _programStudiController.text,
                        );
                        if (user != null) {
                          Navigator.of(context).push(
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
                    } else {
                      setState(() {
                        _errorMessage = "Upss Password Tidak Cocok!";
                      });
                    }
                  },
                  child: Text(
                    'Daftar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.32, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    backgroundColor: Colors.blue,
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
      height: 55,
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
