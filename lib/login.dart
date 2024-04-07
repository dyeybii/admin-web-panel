import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Add this import

class LoginPage extends StatefulWidget {
  static const String id = '/login'; // Define the route identifier

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Create GoogleSignIn instance

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double padding = constraints.maxWidth * 0.1;
            double containerSize = constraints.maxWidth - (padding * 6);
            bool isSmallScreen = constraints.maxWidth < 600;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      width: isSmallScreen ? double.infinity : containerSize,
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'TRI.CO',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: isSmallScreen ? 40 : 74,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E3192),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20.0),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 46, 49, 146)),
                                foregroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 255, 255, 255)),
                              ),
                              onPressed: () {
                                _signInWithEmailAndPassword();
                              },
                              child: const Text('Login'),
                            ),
                            const SizedBox(height: 10.0), // Add spacing
                            OutlinedButton.icon(
                              icon: const Icon(Icons.login),
                              label: const Text('Sign in with Google'),
                              onPressed: () {
                                _signInWithGoogle();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isSmallScreen) const SizedBox(width: 20.0),
                  if (!isSmallScreen)
                    Flexible(
                      child: Image.asset(
                        'images/LOGO.png',
                        fit: BoxFit.contain, // or BoxFit.cover
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _usernameController.text,
          password: _passwordController.text,
        );
        print('User ${userCredential.user!.uid} signed in');
        Navigator.pushReplacementNamed(context, '/dashboard');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print('User ${userCredential.user!.uid} signed in with Google');
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      print(e);
    }
  }
}
