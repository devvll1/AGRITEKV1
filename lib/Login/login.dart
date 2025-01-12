import 'package:agritek/homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agritek/Authentication/auth.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> with TickerProviderStateMixin {
  String? errorMessage = '';
  bool isLogin = true;

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
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  Future<void> signInWithEmailAndPassword() async {
    final email = _controllerEmail.text.trim();
    final password = _controllerPassword.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Email and password must not be empty.");
      return;
    }

    if (!isValidEmail(email)) {
      showError("Invalid email format.");
      return;
    }

    try {
      await Auth().signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushNamed(context, '/homepage');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showError("Email or Password is incorrect.");
      } else {
        showError(e.message ?? "An unknown error occurred.");
      }
    }
  }

  Future<void> resetPassword() async {
    final email = _controllerEmail.text.trim();

    if (email.isEmpty) {
      showError("Please enter your email to reset your password.");
      return;
    }

    if (!isValidEmail(email)) {
      showError("Invalid email format.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showError("Password reset email sent! Check your inbox.");
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "An error occurred while resetting password.");
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    final email = _controllerEmail.text.trim();
    final password = _controllerPassword.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Email and password must not be empty.");
      return;
    }

    if (!isValidEmail(email)) {
      showError("Invalid email format.");
      return;
    }

    if (password.length < 6) {
      showError("Password must be at least 6 characters long.");
      return;
    }

    try {
      await Auth().createUserWithEmailAndPassword(email: email, password: password);
      Navigator.pushNamed(context, '/profileSetup');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showError("This email is already in use.");
      } else if (e.code == 'weak-password') {
        showError("Password is too weak.");
      } else {
        showError(e.message ?? "An unknown error occurred.");
      }
    }
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
                    obscureText: true,
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
                    ),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: resetPassword,
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
                    onPressed: isLogin
                        ? signInWithEmailAndPassword
                        : createUserWithEmailAndPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      isLogin ? 'Login' : 'Register',
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
                        onPressed: toggleForm,
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
                  // Continue Without Logging In
                  ElevatedButton(
                    onPressed: skipLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
