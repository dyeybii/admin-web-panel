import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showPassword = false; // Track whether to show password or not
  bool _loading = false;
  String _errorMessage = '';

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
                              obscureText: !_showPassword, // Toggle password visibility
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                ),
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
                              child: _loading
                                  ? CircularProgressIndicator() // Show loading indicator
                                  : const Text('Login'),
                            ),
                            if (_errorMessage.isNotEmpty) // Show error message if it's not empty
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
      setState(() {
        _loading = true; // Start loading indicator
        _errorMessage = ''; // Clear previous error message
      });

      try {
        await _auth.signInWithEmailAndPassword(
          email: _usernameController.text,
          password: _passwordController.text,
        );
        print('User ${_auth.currentUser!.uid} signed in');
        Navigator.pushReplacementNamed(context, '/dashboard');
      } on FirebaseAuthException catch (e) {
        setState(() {
          _loading = false; // Stop loading indicator
          _errorMessage = 'Please check your password and account name and try again.';
        });
        print('Error signing in: $e');
      } catch (e) {
        setState(() {
          _loading = false; // Stop loading indicator
          _errorMessage = 'An unexpected error occurred. Please try again later.';
        });
        print('Error signing in: $e');
      }
    }
  }
}
