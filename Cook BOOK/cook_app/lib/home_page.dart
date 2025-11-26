import 'package:flutter/material.dart';
import 'bookfinder_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "COOK IT",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/dash.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: const BookFinderPage(),
    );
  }
}
