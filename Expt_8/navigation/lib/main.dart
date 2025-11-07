import 'package:flutter/material.dart';

void main() {
  runApp(const MyTabApp());
}

class MyTabApp extends StatelessWidget {
  const MyTabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Tabs App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const TabNavigationPage(),
    );
  }
}

class TabNavigationPage extends StatelessWidget {
  const TabNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 4 tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Top Navigation Tabs"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: "Home"),
              Tab(icon: Icon(Icons.search), text: "Search"),
              Tab(icon: Icon(Icons.bookmark), text: "Saved"),
              Tab(icon: Icon(Icons.settings), text: "Settings"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text("Home Page", style: TextStyle(fontSize: 24))),
            Center(child: Text("Search Page", style: TextStyle(fontSize: 24))),
            Center(child: Text("Saved Page", style: TextStyle(fontSize: 24))),
            Center(
              child: Text("Settings Page", style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
