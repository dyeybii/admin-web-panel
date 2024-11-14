import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  static const String id = '/login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  bool _loading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double padding = constraints.maxWidth * 0.1;
            double containerSize = constraints.maxWidth - (padding * 6);
            bool isSmallScreen = constraints.maxWidth < 600;

            return Center(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Container(
                            width: isSmallScreen ? double.infinity : containerSize,
                            padding: const EdgeInsets.all(20.0),
                            child: SingleChildScrollView(
                              child: _buildLoginForm(isSmallScreen),
                            ),
                          ),
                        ),
                        if (!isSmallScreen) const SizedBox(width: 20.0),
                        if (!isSmallScreen)
                          Flexible(
                            child: Image.asset(
                              'images/LOGO.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isSmallScreen) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Administration',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isSmallScreen ? 20 : 30,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 176, 176, 176),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Panel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isSmallScreen ? 20 : 30,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 176, 176, 176),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          _buildTextField(
            controller: _usernameController,
            labelText: 'Log in using Email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
            onFieldSubmitted: (_) => _signInWithEmailAndPassword(),
          ),
          const SizedBox(height: 20.0),
          _buildPasswordField(onFieldSubmitted: (_) => _signInWithEmailAndPassword()),
          const SizedBox(height: 20.0),
          _buildLoginButton(),
          if (_errorMessage.isNotEmpty)
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    FormFieldValidator<String>? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  Widget _buildPasswordField({void Function(String)? onFieldSubmitted}) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_showPassword,
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
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            const Color.fromARGB(255, 46, 49, 146)),
        foregroundColor: MaterialStateProperty.all<Color>(
            const Color.fromARGB(255, 255, 255, 255)),
      ),
      onPressed: _loading ? null : _signInWithEmailAndPassword,
      child: _loading ? const CircularProgressIndicator() : const Text('Login'),
    );
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
        _errorMessage = '';
      });

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _usernameController.text,
          password: _passwordController.text,
        );

        QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
            .collection('admin')
            .where('email', isEqualTo: _usernameController.text)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Log the login action to Firestore
          await _addLogEntry("Login", userCredential.user!.uid);

          print('Admin user found in Firestore');
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          setState(() {
            _loading = false;
            _errorMessage = 'Access Restricted: Admins Only.';
          });
          await _auth.signOut();
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _loading = false;
          _errorMessage =
              'Please check your password and account name and try again.';
        });
        print('Error signing in: $e');
      } catch (e) {
        setState(() {
          _loading = false;
          _errorMessage =
              'An unexpected error occurred. Please try again later.';
        });
        print('Error signing in: $e');
      }
    }
  }

  Future<void> _addLogEntry(String action, String adminId) async {
    final logEntry = {
      'adminId': adminId,
      'action': action,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance.collection('audit_logs').add(logEntry);
  }
}
