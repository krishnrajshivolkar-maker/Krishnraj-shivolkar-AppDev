import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bookfinder_page.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool showLogin = true;
  final email = TextEditingController();
  final password = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 330;
    const double cardHeight = 380;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login_background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: cardWidth,
            height: cardHeight,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 16, offset: Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => showLogin = true),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: showLogin ? Colors.blue : Colors.grey.shade500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => showLogin = false),
                          child: Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: showLogin ? Colors.grey.shade500 : Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: showLogin
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(top: 30),
                        width: cardWidth / 2.6,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(child: showLogin ? loginUI() : registerUI()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loginUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: email,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Email",
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: password,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: const TextStyle(color: Colors.white),
            border: const OutlineInputBorder(),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            suffixIcon: IconButton(
              icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: forgotPassword,
            child: const Text("Forgot Password?", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: loginUser, child: const Text("Login")),
        ),
      ],
    );
  }

  Widget registerUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: email,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Email",
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: password,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: const TextStyle(color: Colors.white),
            border: const OutlineInputBorder(),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            suffixIcon: IconButton(
              icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: registerUser, child: const Text("Register")),
        ),
      ],
    );
  }

  Future<void> loginUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookFinderPage()),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> registerUser() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookFinderPage()),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> forgotPassword() async {
    if (email.text.isEmpty) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent")),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
