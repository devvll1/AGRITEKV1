import 'package:agritek/homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agritek/Authentication/auth.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage>
    with TickerProviderStateMixin {
  String? errorMessage = '';
  bool isLogin = true;
  bool _isObscured = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void showError(String message) {
    setState(() {
      errorMessage = message;
    });
    _animationController.forward(from: 0);
  }

  bool isValidEmail(String email) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  Future<void> signInWithEmailAndPassword() async {
    final email = _controllerEmail.text.trim();
    final password = _controllerPassword.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Please fill in both email and password fields.");
      return;
    }

    if (!isValidEmail(email)) {
      showError("The email address entered is not valid. Please try again.");
      return;
    }

    try {
      await Auth().signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushNamed(context, '/homepage');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showError("No account found with this email. Please sign up first.");
      } else if (e.code == 'wrong-password') {
        showError("Incorrect password. Please try again.");
      } else if (e.code == 'too-many-requests') {
        showError("Too many login attempts. Please try again later.");
      } else if (e.code == 'invalid-credential') {
        showError(
            "The credentials provided are invalid. Please check and try again.");
      } else {
        showError(
            e.message ?? "An unexpected error occurred. Please try again.");
      }
    } catch (e) {
      showError(
          "An error occurred while signing in. Please check your connection and try again.");
    }
  }

  void goToProfileSetup() {
    Navigator.pushNamed(context, '/profileSetup');
  }

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
      errorMessage = '';
      _animationController.reset();
    });
  }

  void skipLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1d4b0b), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/agritek.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Welcome to AgriTek",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                  TextField(
                    controller: _controllerEmail,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controllerPassword,
                    obscureText: _isObscured,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (errorMessage != null && errorMessage!.isNotEmpty)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        color: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.white, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed:
                        isLogin ? signInWithEmailAndPassword : goToProfileSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      isLogin ? 'Login' : 'Sign Up',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin ? "New to AgriTek? " : "Already registered? ",
                        style: const TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          if (isLogin) {
                            // Navigate to the profile setup page directly when "Sign Up" is clicked
                            goToProfileSetup();
                          } else {
                            // Toggle back to login form
                            toggleForm();
                          }
                        },
                        child: Text(
                          isLogin ? "Sign Up" : "Login",
                          style: const TextStyle(
                            color: Colors.yellowAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: skipLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: const Text(
                      'Continue Without Logging In',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
