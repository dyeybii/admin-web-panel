import 'package:admin_web_panel/widgets/log_entry.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMePreference();
  }

  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  Future<void> _setRememberMePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', value);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _triggerSignIn() {
    if (!_loading) {
      _signInWithEmailAndPassword();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isSmallScreen =
                    constraints.maxWidth < 600; 
                String backgroundImage = isSmallScreen
                    ? 'images/bg_mobile.jpg' 
                    : 'images/bg.jpg'; 

                return Image.asset(
                  backgroundImage,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          // Content Overlay
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isSmallScreen = constraints.maxWidth < 600;
                double containerWidth = isSmallScreen
                    ? constraints.maxWidth * 0.95
                    : 450; // Adjust for mobile/web

                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                  child: Center(
                    child: Container(
                      width: containerWidth,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.9), // Semi-transparent for overlay
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // TRI.CO Logo and Text at the top-center
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'TRI.CO',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 70,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2E3192),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Image.asset(
                                    'images/LOGO.png',
                                    width: 70,
                                    height: 70,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Administration Login',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E3192),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          _buildLoginForm(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(
            controller: _usernameController,
            labelText: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20.0),
          _buildPasswordField(),
          const SizedBox(height: 20.0),
          _buildRememberMeCheckbox(),
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      textInputAction: TextInputAction.next, // Move to next field when Enter is pressed
    );
  }

  Widget _buildPasswordField() {
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
      textInputAction: TextInputAction.done, 
      onFieldSubmitted: (_) => _triggerSignIn(), 
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
            _setRememberMePreference(_rememberMe);
          },
        ),
        const Text(
          'Remember me',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF2E3192),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _loading ? null : _signInWithEmailAndPassword,
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
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

        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection('admin')
                .where('email', isEqualTo: _usernameController.text)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          final adminDoc = querySnapshot.docs.first;
          // Use the LogEntry class to log the action
          await LogEntry.add(
            action: "Login",
            adminId: adminDoc.id,
            fullName: adminDoc.data()['fullName'] ?? 'Unknown',
            profileImage: adminDoc.data()['profileImage'] ?? '',
          );

          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          setState(() {
            _loading = false;
            _errorMessage = 'Access Restricted: Admins Only.';
          });
          await _auth.signOut();
        }
      } on FirebaseAuthException {
        setState(() {
          _loading = false;
          _errorMessage = 'Please check your email and password and try again.';
        });
      } catch (_) {
        setState(() {
          _loading = false;
          _errorMessage = 'An unexpected error occurred.';
        });
      }
    }
  }
}
