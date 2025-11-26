// lib/bookfinder_page.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookFinderPage extends StatefulWidget {
  const BookFinderPage({super.key});

  @override
  State<BookFinderPage> createState() => _BookFinderPageState();
}

class _BookFinderPageState extends State<BookFinderPage> {
  final searchController = TextEditingController();
  bool loading = false;

  List books = [];

  Future<void> searchBooks() async {
    String query = searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      loading = true;
      books = [];
    });

    final url = "https://www.googleapis.com/books/v1/volumes?q=$query";

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      setState(() {
        books = data["items"] ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Finder")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search TextBox
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search for books",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: loading ? null : searchBooks,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : searchBooks,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Find Books"),
              ),
            ),

            const SizedBox(height: 20),

            // Results
            Expanded(
              child: books.isEmpty
                  ? const Center(
                      child: Text(
                        "Books will appear here...",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        var info = books[index]["volumeInfo"];
                        String title = info["title"] ?? "No Title";
                        String authors =
                            info["authors"]?.join(", ") ?? "Unknown";

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.book, size: 40),
                            title: Text(title),
                            subtitle: Text(authors),
                            onTap: () {
                              // Navigate to Book Details Page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BookDetailsPage(book: info),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Book Details Page ----------------
class BookDetailsPage extends StatelessWidget {
  final Map book;
  const BookDetailsPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    String title = book["title"] ?? "No Title";
    String authors = book["authors"]?.join(", ") ?? "Unknown";
    String desc = book["description"] ?? "No description available.";

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("By: $authors", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              const Text(
                "Description:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(desc, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
